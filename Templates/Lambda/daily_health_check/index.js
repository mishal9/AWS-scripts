//TODO
////Check if User exists in Dynamo already before calling Safe Create User API


const AWS = require("aws-sdk");
const dynamo = new AWS.DynamoDB.DocumentClient();
const moment = require("moment-timezone");
const request = require('request-promise');
// const rp = require('request-promise');
let asurite = null;
    
 
exports.handler = async (event,context) => {
     //event.type = "get";
     let date = new Date();
     let day = moment(date.getTime()).tz("America/Phoenix").format("YYYY/MM/DD");
     let daytime = moment(date.getTime()).format();
     let ec_asurite = "";
     var modality = "mobile"
     try {
     console.log(JSON.stringify(event));
     if (event.context["web"] == true) {
        asurite = event.context["authorizer-principal-id"]
        modality = "web"
        if (event.context["ec_asurite"]) {
            ec_asurite = event.context["ec_asurite"];
        }
     }
     else{
     var cognitoidentity = new AWS.CognitoIdentity();
     var param = {
        IdentityPoolId: event["context"]["cognito-identity-pool-id"],
        IdentityId: event["context"]["cognito-identity-id"],
        MaxResults: 1
    };
    console.log(day);
    
    // asurite = await  getAsurite(cognitoidentity,param);
     
        try {
              asurite = await  getAsurite(cognitoidentity,param);
              console.log(asurite,"--","Modality:",modality,"*-1- Got ASURITE from Cognito Lookup.")
          } catch (e) {
               console.log("*-2- ZERROR Looking up ASURITE from Cognito",e, event["context"]["cognito-identity-id"])
               asurite = await  getAsuriteFromDynamo();
               console.log(asurite,"*-3- Retrieved ASURITE from Dynamo Successfully")
          }
     
         
         
         
     }
     
     
     console.log("ASURITE",asurite)
     let roles = ["student"]
     try {
       roles = await getiSearchUserRoles(asurite);
     } catch (e) {
       console.log(e);  
     }
     console.log("ROLES - - ",roles)
     if(event["body"]["type"]=="coming"){
         let update = await saveQuestionnaire(event["body"]["current_question"],daytime);
         context.succeed({"updated":"true"})
     }
     else if(event["body"]["type"]=="not_coming"){
         let update_table = await saveQuestionnaire(null,daytime);
         context.succeed({"updated":"true"});
     }else if(event["body"]["type"] == "check_status"){
         console.log("User not coming today");
        let get_status = await getStatus(day);
        console.log(get_status);
        let final_data = {}
        if (get_status.Count > 0) {
          final_data = get_status.Items[0];
        } 
        if (roles.indexOf("student") > -1) {
            if (roles.indexOf("staff") > -1 || roles.indexOf("faculty") > -1) {
                roles = roles.filter(item => item !== "student")
            }
        }
        final_data.roles = roles;
        
         context.succeed( final_data );
     }
     let check_exists = await getQuestionnaire();
     console.log("checking status:",check_exists);
     console.log("JSON VAL:",check_exists.Count);
     if (check_exists.Count == 0){
         context.succeed({"status":"Not started","roles": roles});
     }
     else{
         console.log("modality:",check_exists.Items[0]["modality"]);
         context.succeed({"status":"started", "roles":roles, "modality":check_exists.Items[0]["modality"]});
     }
     
     } catch (err) {
         context.fail(err);
     }
     
    async function getiSearchUserRoles(asurite){
        return new Promise((resolve,reject) =>{
            var roleList = [];
            var directoryUrl = "https://jfirypr0vf.execute-api.us-west-2.amazonaws.com/prod/role?asurite=" + asurite
            try {
                //using a try block because in case isearch is down, exception will be trown which will cause downtime of the app
                request(directoryUrl, function (error, response, body) {
                    let roleList = JSON.parse(body);
                    if (roleList) {
                        if (roleList && roleList.length === 0) {
                             roleList = ["student"];
                        }
                    } else {
                        roleList = ["student"];
                    }
                    resolve(roleList)
                });
              } catch (err) {
                        console.log("ERROR",err)
                        roleList = ["student"];
                        reject(roleList)
              }
        });
    }
    async function getUserRoles(asurite){
        return new Promise((resolve,reject) =>{
            var roleList = [];
            var directoryUrl = "https://app.m.asu.edu/user-details?asurite=" + asurite
            try {
                //using a try block because in case isearch is down, exception will be trown which will cause downtime of the app
                request(directoryUrl, function (error, response, body) {
                    let userDetails = JSON.parse(body);
                    if (userDetails) {
                        if (userDetails.roleList && userDetails.roleList.length === 0) {
                            userDetails.roleList = ["student"];
                        }
                        roleList = userDetails.roleList
                    } else {
                        roleList = ["student"];
                    }
                    resolve(roleList)
                });
              } catch (err) {
                        console.log("ERROR",err)
                        roleList = ["student"];
                        reject(roleList)
              }
        });
    }
     async function getAsurite(cognitoidentity,param){
        return new Promise((resolve,reject) =>{
            cognitoidentity.lookupDeveloperIdentity(param, function (err, data) {
                console.log("INSIDE LOOKUP");
                if (!err) {
                    let asurite_id = data["DeveloperUserIdentifierList"][0]; 
                    resolve(asurite_id);
                } 
                else {
                    reject(err);
                }
            });
        });
    }
    async function getAsuriteFromDynamo() {
         return new Promise((resolve,reject) =>{
             let param = {
                TableName: "asumobileapp_users",
                KeyConditionExpression: "id = :id",
                Limit: 1,
                ExpressionAttributeValues: {
                  ":id": event["context"]["cognito-identity-id"]
               },
               ProjectionExpression: "asurite"
               
            };
            let result = dynamo.query(param, function(err, data) {
              if (err) reject(err);
              else {
                  if (data.Count > 0) {
                       resolve(data.Items[0]["asurite"])
                  } else {
                      resolve("guest")
                  }
                 
              }
            });
         })
     }
    
    async function getStatus(userdate) {
        return new Promise((resolve,reject) => {
           let param = {
                TableName: "covid_questionnaire_prod",
                KeyConditionExpression: "asurite = :asurite and userdate = :userdate",
                ExpressionAttributeValues: {
                  ":asurite": asurite,
                  ":userdate": userdate
               },
             //   ProjectionExpression: "completion_type" 
            };
           // let result =  dynamo.query(param).promise();
            let result = dynamo.query(param, function(err, data) {
              if (err) { 
                  console.log("ERROR",err)
                  reject(err)
              }
              else { 
                 resolve(data)
              }
            });
           // resolve(result);
        });
    }
    
    async function getQuestionnaire() {
        return new Promise((resolve,reject) => {
           let param = {
                TableName: "covid_questionnaire_prod",
                KeyConditionExpression: "asurite = :asurite AND userdate=:day",
                ExpressionAttributeValues: {
                  ":asurite": asurite,
                  ":day": day
                  
               }
            };
            let result =  dynamo.query(param).promise();
            resolve(result);
        });
    }
    async function saveQuestionnaire(curr_question,daytime) {
        return new Promise((resolve,reject) => {
           let param = {
                TableName: "covid_questionnaire_prod",
                Item: {
                    asurite: asurite,
                    userdate: day,
                    questionnaireId: null,
                    currentQuestion: curr_question,
                    status: true,
                    started: daytime,
                    completed: daytime,
                    result: false,
                    updated: daytime,
                    modality: modality,
                    completion_type: "not_coming_today",
                    ec_asurite: ec_asurite
                },
            };
    
            let putResult =  dynamo.put(param).promise();
            resolve(putResult);
        })
    }
    
    
    
};

