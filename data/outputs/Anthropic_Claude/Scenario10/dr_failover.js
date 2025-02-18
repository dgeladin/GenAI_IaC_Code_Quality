// filename: dr_failover.js

const AWS = require('aws-sdk');
const drs = new AWS.drs();
const sns = new AWS.SNS();

exports.handler = async (event) => {
    console.log('Received event:', JSON.stringify(event, null, 2));
    
    try {
        // Get DRS configuration ID from environment variable
        const configId = process.env.DR_CONFIGURATION_ID;
        
        // Get source server details
        const sourceServers = await drs.describeSourceServers({
            filters: {
                isHealthy: true
            }
        }).promise();
        
        if (!sourceServers.items || sourceServers.items.length === 0) {
            throw new Error('No healthy source servers found');
        }
        
        // Start recovery for each healthy source server
        const recoveryResults = await Promise.all(sourceServers.items.map(async (server) => {
            const params = {
                sourceServerID: server.sourceServerID,
                targetInstanceTypeRightSizingMethod: 'NONE'
            };
            
            const recovery = await drs.startRecoveryJob(params).promise();
            return {
                sourceServer: server.sourceServerID,
                recoveryJob: recovery.jobID
            };
        }));
        
        // Prepare notification message
        const message = {
            subject: 'DR Failover Initiated',
            message: `DR failover process has been initiated.
                     Trigger Event: ${event.detail?.eventArn || 'Manual trigger'}
                     Recovery Jobs Started: ${recoveryResults.length}
                     Job Details: ${JSON.stringify(recoveryResults, null, 2)}
                     Time: ${new Date().toISOString()}`
        };
        
        // Send notification
        await sns.publish({
            TopicArn: process.env.SNS_TOPIC_ARN,
            Subject: message.subject,
            Message: message.message
        }).promise();
        
        return {
            statusCode: 200,
            body: JSON.stringify({
                message: 'DR failover initiated successfully',
                recoveryJobs: recoveryResults
            })
        };
        
    } catch (error) {
        console.error('Error during failover:', error);
        
        // Send error notification
        await sns.publish({
            TopicArn: process.env.SNS_TOPIC_ARN,
            Subject: 'DR Failover Error',
            Message: `Error during DR failover process: ${error.message}\nStack: ${error.stack}`
        }).promise();
        
        throw error;
    }
};