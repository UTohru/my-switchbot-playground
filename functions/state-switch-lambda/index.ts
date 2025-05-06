import type {
  APIGatewayProxyEventV2,
  APIGatewayProxyResult,
  Context,
} from 'aws-lambda';

import { DynamoDBClient, PutItemCommand, GetItemCommand, UpdateItemCommand, marshall } from "@aws-sdk/client-dynamodb";
import { marshall, unmarshall } from "@aws-sdk/util-dynamodb"
import { SSMClient, GetParameterCommand } from "@aws-sdk/client-ssm";

import { SwitchBotOpenAPI } from 'node-switchbot';

interface DeviceInfo {
  DeviceId: string;
  SwitchState: boolean;
}

const STATE_TABLE_NAME = "SwitchState";
const PARAMETER_STORE_ROOT = "switchbot-api"

const getParameter = async (name: string): Promise<string> => {

  const client = new SSMClient();
  const cmd = new GetParameterCommand({
    Name: `/${PARAMETER_STORE_ROOT}/${name}`,
    WithDecryption: true
  });

  const res = await client.send(cmd);
  if (!res.Parameter?.Value) {
    throw new Error(`Parameter "${name}" is not found`);
  }
  return res.Parameter.Value;
}

const getState = async (ddbClient: DynamoDBClient, deviceId: string): Promise<boolean> => {
  const cmd = new GetItemCommand({
    TableName: STATE_TABLE_NAME,
    Key: marshall({ "DeviceId": deviceId }),
  });
  const res = await ddbClient.send(cmd);
  if (!res.Item) {
    return false;
  }
  
  const info = unmarshall(res.Item) as DeviceInfo;
  return info.SwitchState
}

const putItem = async (ddbClient: DynamoDBClient, device: DeviceInfo): Promise<void> => {
  const cmd = new PutItemCommand({
    TableName: STATE_TABLE_NAME,
    Item: marshall(device)
  });
  
  await ddbClient.send(cmd);
}

const updateAttribute = async (
  ddbClient: DynamoDBClient,
  deviceId: string,
  state: boolean
): Promise<void> => {
  const cmd = new UpdateItemCommand({
    TableName: STATE_TABLE_NAME,
    Key: marshall({ "DeviceId": deviceId }),
    UpdateExpression: `SET #state = :val`,
    ExpressionAttributeNames: {
      "#state": "SwitchState"
    },
    ExpressionAttributeValues: marshall({ ":val": state }),
    // ReturnValues: "UPDATED_NEW",
  });

  await ddbClient.send(cmd);
}


const isExistBot = async (client: SwitchBotOpenAPI, deviceId: string): Promise<boolean> => {
  const { response } = await client.getDevices();
  return response.body.deviceList.some(d => d.deviceId === deviceId);
}

const pressBot = async (client: SwitchBotOpenAPI, deviceId: string) => {
  // default is dummy
  const res = await client.controlDevice(deviceId, 'press', 'default');
}


export const handler = async (
  event: APIGatewayProxyEventV2,
  context: Context
): Promise<APIGatewayProxyResult> => {

  // route_key = "GET /switch/{deviceId}"
  const deviceId = event.pathParameters?.deviceId;
  if (!deviceId) {
    return {
      statusCode: 400,
      body: JSON.stringify({
        message: "invalid parameter",
      }),
    };
  }


  const token = await getParameter("bot-token");
  const secret = await getParameter("bot-secret");
  const botClient = new SwitchBotOpenAPI(token, secret);
  if (! await isExistBot(botClient, deviceId)) {
    return {
      statusCode: 400,
      body: JSON.stringify({
        message: "invalid device",
      }),
    };
  }


  const ddbClient = new DynamoDBClient();

  const query = event.queryStringParameters ?? {};
  const action = query["action"]
  let targetState = false;
  switch (action) {
    case "on":
      targetState = true
      break;
    case "off":
      targetState = false;
      break;
    case "add":
      const deviceInfo = { "DeviceId": deviceId, "SwitchState": query["state"] === "true" } as DeviceInfo;
      await putItem(ddbClient, deviceInfo);
      return {
        statusCode: 200,
        body: JSON.stringify({
          message: "Add device"
        }),
      };
    default:
      return {
        statusCode: 400,
        body: JSON.stringify({
          message: "invalid parameter"
        }),
      };
  }

  const nowState = await getState(ddbClient, deviceId);
  if (nowState != targetState) {
    await pressBot(botClient, deviceId);
    await updateAttribute(ddbClient, deviceId, targetState);
  }


  return {
    statusCode: 200,
    body: JSON.stringify({
      message: `${action}!`
    }),
  };
};
