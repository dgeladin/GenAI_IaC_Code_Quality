const AWS = require('aws-sdk');

// Initialize AWS clients
const drs = new AWS.drs();
const sns = new AWS.SNS();
const sts = new AWS.STS();

// Environment variables
const {
  ENVIRONMENT,
  PRIMARY_REGION,
  DR_REGION,
  SNS_TOPIC_ARN,
  DRS_CONFIG_ID,
  CROSS_REGION_ROLE,
  LOG_LEVEL
} = process.env;

// Logger setup
const logger = {
  info: (msg, data) => console.log(JSON.stringify({ level: 'INFO', msg, data })),
  error: (msg, err) => console.error(JSON.stringify({ level: 'ERROR', msg, error: err })),
  debug: (msg, data) => {
    if (LOG_LEVEL === 'DEBUG') {
      console.log(JSON.stringify({ level: 'DEBUG', msg, data }));
    }
  }
};

async function assumeCrossRegionRole() {
  try {
    const params = {
      RoleArn: CROSS_REGION_ROLE,
      RoleSessionName: 'DrFailoverSession'
    };
    const { Credentials } = await sts.assumeRole(params).promise();
    return new AWS.Credentials(
      Credentials.AccessKeyId,
      Credentials.SecretAccessKey,
      Credentials.SessionToken
    );
  } catch (error) {
    logger.error('Failed to assume cross-region role', error);
    throw error;
  }
}

async function startDRFailover(event) {
  try {
    logger.info('Starting DR failover process', { event });

    // Start recovery
    const startParams = {
      sourceServerID: DRS_CONFIG_ID
    };
    await drs.startRecovery(startParams).promise();
    logger.info('Recovery started successfully');

    // Send notification
    await sns.publish({
      TopicArn: SNS_TOPIC_ARN,
      Subject: `DR Failover Started - ${ENVIRONMENT}`,
      Message: JSON.stringify({
        status: 'STARTED',
        timestamp: new Date().toISOString(),
        environment: ENVIRONMENT,
        event
      })
    }).promise();

    return {
      statusCode: 200,
      body: JSON.stringify({
        message: 'DR failover process started successfully',
        timestamp: new Date().toISOString()
      })
    };
  } catch (error) {
    logger.error('Failover process failed', error);
    throw error;
  }
}

exports.handler = async (event, context) => {
  try {
    logger.debug('Received event', { event });
    return await startDRFailover(event);
  } catch (error) {
    logger.error('Handler execution failed', error);
    throw error;
  }
};
