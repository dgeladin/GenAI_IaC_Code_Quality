const AWS = require('aws-sdk');
const sns = new AWS.SNS();
const drs = new AWS.DRS();

exports.handler = async (event) => {
  const drConfigurationId = process.env.DR_CONFIGURATION_ID;
  
  try {
    // Initiate DRS failover execution
    const params = {
      sourceServerIDs: [drConfigurationId]
    };
    await drs.startFailbackLaunch(params).promise();

    // Notify administrators
    const message = 'DR failover executed successfully.';
    const subject = 'DR Failover Notification';
    const topicArn = 'arn:aws:sns:us-east-1:<your-account-id>:dr-failover-notifications';

    await sns.publish({
      Message: message,
      Subject: subject,
      TopicArn: topicArn
    }).promise();

    return {
      statusCode: 200,
      body: JSON.stringify('DR failover executed and notification sent.')
    };
  } catch (error) {
    console.error('Error executing DR failover:', error);
    throw error;
  }
};