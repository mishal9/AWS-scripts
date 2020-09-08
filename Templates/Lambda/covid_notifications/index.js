"use-strict";
const AWS = require('aws-sdk');
const dynamo = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event) => {
    // TODO implement
    console.log(event);
    
    let cognitoidentity = new AWS.CognitoIdentity();
    let asurite = "";
    let param = {
      IdentityPoolId: event.context["cognito-identity-pool-id"],
      IdentityId: event.context["cognito-identity-id"],
      MaxResults: 1
    };
    
    asurite = await getAsurite(cognitoidentity,param);
    await putCovidNotificationAnalytics(asurite);
    const response = {
        statusCode: 200,
        body: JSON.stringify('Success'),
    };
    return response;

    
    function getAsurite(cognitoidentity,param){
        return new Promise(async function(resolve,reject) {
            cognitoidentity.lookupDeveloperIdentity(param, function (err, data) {
                if (err) {reject(err)} // an error occurred
                else {
                    let asurite_id = data["DeveloperUserIdentifierList"][0]; 
                    console.log(asurite_id)
                    resolve(asurite_id)
                }
            });
        });
    }
    
    function putCovidNotificationAnalytics(asurite){
        return new Promise(async function(resolve, reject) {
            console.log("inside promise");
            let send_params = {
                eventid: Date.now().toString() + asurite,
                pushid: event.params.querystring.id,
                timestamp: Date.now(),
                asurite
            };
            let items = {
                TableName: "covid_notification_analytics",
                Item: send_params
            };
            console.log(items);
            let result = await dynamo.put(items).promise();
            console.log('RESULT', result)
            resolve(result)
        })
    }
};

