// dr_failover_function.js

const AWS = require('aws-sdk');
const DRS = new AWS.Drs();

exports.handler = async (event) => {
  const drConfigurationId = process.env.DR_CONFIGURATION_ID;

  console.log("DR Failover Lambda triggered!");
  console.log("DR Configuration ID:", drConfigurationId);
  console.log("Event:", JSON.stringify(event)); // Log the entire event for debugging

  try {

    // 1. Get the latest recovery point for the impacted source server
    const sourceServerId = event.detail.resourceId; // Extract Source Server ID from CloudWatch Event
    console.log("Source Server ID from event:", sourceServerId);

    const recoveryPoints = await DRS.listRecoveryPoints({
      SourceServerID: sourceServerId
    }).promise();

    if (!recoveryPoints.items || recoveryPoints.items.length === 0) {
      throw new Error(`No recovery points found for source server: ${sourceServerId}`);
    }

    const latestRecoveryPoint = recoveryPoints.items.sort((a, b) => new Date(b.creationDateTime) - new Date(a.creationDateTime))[0]; // Sort and get latest
    console.log("Latest Recovery Point:", latestRecoveryPoint);

    // 2. Start recovery instances (DR failover)
    const recoveryInstancesResponse = await DRS.startRecoveryInstances({
      RecoveryPointIDs: [latestRecoveryPoint.RecoveryPointID],
      ReplicationConfigurationID: drConfigurationId
    }).promise();

    console.log("DR failover initiated:", recoveryInstancesResponse);

    // 3. Notify administrators (replace with SNS or other notification)
    console.log(`DR failover process has been executed for source server ID ${sourceServerId}. Recovery Point ID: ${latestRecoveryPoint.RecoveryPointID}`);

    return {
      statusCode: 200,
      body: JSON.stringify('DR failover initiated successfully!'),
    };
  } catch (error) {
    console.error("Error during DR failover:", error);
    throw error; // Re-throw the error for CloudWatch monitoring
  }
};