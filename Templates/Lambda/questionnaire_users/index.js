const AWS = require("aws-sdk");
const dynamo = new AWS.DynamoDB.DocumentClient();
const rp = require('request-promise');
const moment = require("moment-timezone");
let env = process.env;
const client = new AWS.SecretsManager({region: 'us-west-2'});
 let start_questionnaire = null;
 let get_questionnnaire = null;
 let save_questionnaire = null;
 let questionnaire_question = null;
 let question_name = null;
 let asurite = null;

 let admin = "zohair.zaidi@asu.edu";
 let email = null;
     
/* SAFE */
let auth_url = "https://auth.safesystems.app/oauth/token";
let auth_audience = "https://api.getchecked.health"
let safe_api = "https://api.getchecked.health/v1"
let covid_table = "covid_questionnaire_prod";
let safe_formid = "5e7b5a15197fd00617a95982";
 function getSecretValue () {
    return new Promise(async function(resolve,reject) {
    resolve ({
        client_id: "AaC3Lm3xs5qzUEbuXT2Kq4t6U0B1aN4D",
        client_secret: "IZd0LzIHj4viL4YS5--A1vMtxjCWsWqZbkiECNeMAZ8PXP5-fr-oDl89FmH4pojh"
    })
    })
 }
 
exports.handler = async (event,context) => {
     let date = new Date();
     let day = moment(date.getTime()).tz("America/Phoenix").format("YYYY/MM/DD");
     let daytime = moment(date.getTime()).format();
     console.log(JSON.stringify(event))
     let type = event.body.type;
     let modality = "mobile";
     let ec_asurite = "";
     let completion_type = "questionnaire" //not_coming_campus
     let first_name = "";
     let last_name = "";
     
    var cognitoidentity = new AWS.CognitoIdentity();
    if (event.debug) {
         event.context = {
            'cognito-identity-id': 'us-west-2:52a100ec-cecf-4898-ad18-e43afd554a61',
            'cognito-identity-pool-id': 'us-west-2:150e7cea-c85c-48e1-b422-3ac592e63394'
         }
     }
     if (event.context["web"] == true) {
        asurite = event.context["authorizer-principal-id"]
        modality = "web";
        if (event.context["ec_asurite"]) {
            ec_asurite = event.context["ec_asurite"];
            console.log("EC_ASURITE",ec_asurite)
        }
     } else {
        var param = {
            IdentityPoolId: event["context"]["cognito-identity-pool-id"],
            IdentityId: event["context"]["cognito-identity-id"],
            MaxResults: 1
         };
        asurite = await  getAsurite(cognitoidentity,param);
     }
     
     
     
     
     email = asurite + "@asu.edu"
     
     //DEBUG
     email = "abain4@asu.edu";
     
     console.log(email);
     let secrets = await getSecretValue();
     let safe_access = await getAccessTokenFromSafeHealth(secrets.client_id,secrets.client_secret,"/oauth/token")
     /* WORKING 9:11am */
     let CheckUserInSafe = await checkUserInSafeHelath(email,safe_access.access_token)
     if (typeof(CheckUserInSafe.errorMessage) != "undefined") {
        let createUserResponse = await createNewUserSignupMethod(email,safe_access.access_token);
     }
     context.succeed(CheckUserInSafe);
     //context.succeed(createUserResponse);
     let getTodaysQuestionnairesFromDynamo = await getQuestionnaire();
     /* Working 9:14am */
     let check_user_exists = await checkUserExists()
     /* Working 9:29 am */
     let isearch = await getUserInfo(asurite);
     if (typeof isearch.firstName != "undefined") {
       first_name = isearch.firstName;
       last_name = isearch.lastName;
     } 
     /* Working 9:34 am */
     console.log(check_user_exists);
     let create_user = false;
     if (typeof (check_user_exists.Count) != "undefined") {
     if (check_user_exists.Count == 0) { //They have never submitted questionnaire
        try {
            create_user = await createNewUser(first_name,last_name,safe_access.access_token)
        } catch (e) {
            console.error("CREATE NEW USER ERROR ",e);
            //create_user = await createNewUser(first_name,last_name,safe_access.access_token)
        }
     } else {
          create_user = true;
     }
     } else {
           create_user = await createNewUser(first_name,last_name,safe_access.access_token)
     }
     
     
     switch (type) {
      case "get":
      if (getTodaysQuestionnairesFromDynamo.Count == 0) {
         console.log("Status of create user before starting questionnaire...",create_user) 
         start_questionnaire = await startQuestionnaire(safe_access.access_token);
         console.log("STARTING NEW QUESTIONNAIRE FOR TODAY",start_questionnaire);
         save_questionnaire =  await saveQuestionnaire(start_questionnaire.questionnaire.id,start_questionnaire.currentQuestion,false,start_questionnaire.questionnaire.started,false,false); 
         /* Working 9:54am - Successfully saves to DB */ 
         questionnaire_question = start_questionnaire.currentQuestion.introduction
         question_name = start_questionnaire.currentQuestion.name;
         return { "question": questionnaire_question, "result": null, "question_name":question_name }
         /* Working 9:56am - Returning first question from Safe */ 
     } else {
         /* We have existing question in progress for today */
         if (!getTodaysQuestionnairesFromDynamo.Items[0]["status"]) {
           //let todaysQuestionnaire = await getCurrentQuestionnaire(safe_access.access_token)
            console.log("Status of create user before starting questionnaire...",create_user) 
            let todaysQuestionnaire = await startQuestionnaire(safe_access.access_token);
            save_questionnaire =  await saveQuestionnaire(todaysQuestionnaire.questionnaire.id,todaysQuestionnaire.currentQuestion,false,todaysQuestionnaire.questionnaire.started,false,false); 
            console.log(todaysQuestionnaire);
           if (typeof todaysQuestionnaire.questionnaire.outcome != "undefined" )  {
                questionnaire_question = todaysQuestionnaire.currentQuestion.introduction
                question_name = todaysQuestionnaire.currentQuestion.name
                return { "question": questionnaire_question, "result": null, "question_name":question_name }
           }
         } else {
             return { "question": null, "question_name": null, "result": getTodaysQuestionnairesFromDynamo.Items[0]['result']  } 
         }
         // Working 10:22am - Returning question back if existed already and not completed OR if completed returns the result
     }
        break;
        
        case "post":
            let questionnionaire_id  = null;
            let payload = event['body']['payload'];
            if (getTodaysQuestionnairesFromDynamo.Count == 0) {
               start_questionnaire = await startQuestionnaire(safe_access.access_token);
               questionnionaire_id = start_questionnaire.questionnaire.id
            } else {
                questionnionaire_id = getTodaysQuestionnairesFromDynamo.Items[0]["questionnaireId"]
            }
            console.log("POSTING PAYLOAD",payload)
            let postQuestion = await postQuestionnaire(safe_access.access_token,questionnionaire_id,payload);
            if (postQuestion.questionnaire.outcome.option == null )  {
                questionnaire_question = postQuestion.currentQuestion.introduction
                question_name = postQuestion.currentQuestion.name
                save_questionnaire =  await saveQuestionnaire(postQuestion.questionnaire.id,postQuestion.currentQuestion,false,postQuestion.questionnaire.started,false,false); 
                return { "question": questionnaire_question, "result": null, "question_name":question_name }
            }
            else {
                let result = postQuestion.questionnaire.outcome.option;
                let completedate = postQuestion.questionnaire.completed;
                let completed = true;
                save_questionnaire  = await saveQuestionnaire(postQuestion.questionnaire.id,postQuestion.currentQuestion,completedate,postQuestion.questionnaire.started,completed,result);
             return { "question": null, "question_name": null, "result": postQuestion.questionnaire.outcome.option  } 
            }
            return postQuestion;
            break;
     }
       
        //SWITCH GET ENDS HERE    

  //      case "post": 
      /*       try {
             let payload = event['body']['payload'];
             let postQuestion = await postQuestionnaire(safe_access.access_token,getTodaysQuestionnairesFromDynamo.Items[0]["questionnaireId"],payload);
             let nextQuestion = null;
             let result = null;
             let completed = false;
             let completedate = false;
             if (!postQuestion.questionnaire.outcome.completed) {
                   nextQuestion = postQuestion.currentQuestion;
                   completed = false;
                   result = false;
             } else {
                   nextQuestion = postQuestion.questionnaire.outcome.option;
                   console.log(nextQuestion);
                   result = postQuestion.questionnaire.outcome.option;
                   completedate = postQuestion.questionnaire.completed;
                   completed = true;
                   
             }
             let saving = await saveQuestionnaire(postQuestion.questionnaire.id,postQuestion.currentQuestion,completedate,postQuestion.questionnaire.started,completed,result);
             if (typeof nextQuestion.introduction != "undefined") {
                 return { "question": nextQuestion.introduction, "result": null, "question_name": nextQuestion.name }
             } else {
                 return { "question": null, "result": result, "question_name":null }
             }
             } catch (e) {
                 context.fail(e)
             }
             break;
             
     }     
         
     } catch (err) {
         context.fail(err)
     }
     */
     async function createNewUserSignupMethod(firstName,lastName,token) {
        return new Promise((resolve,reject) => {
            let path = safe_api + "/admin/user/asu/signup";
            let headers = {
                "Authorization": "Bearer " + token,
                "userId": admin,
                "password": "Test"
            }
            let body = {
                "email": email,
                "firstName": firstName,
                "lastName": lastName
            }
            var options = {
                method: 'POST',
                uri: path,
                body: body,
                headers: headers,
                json: true
            }
            rp(options).then((data) => { console.log("Checking if User exists in Safe...",data); resolve(data) }).catch((err) => { console.log("Checking User ERROR",err); reject(err) });
        });
    }
    async function checkUserInSafeHelath(email,token) {
        return new Promise((resolve,reject) => {
            let path = safe_api + "/admin/user/?id="+email;
            console.log("PATH",path)
            let headers = {
                "Authorization": "Bearer " + token,
                "userId": admin
            }
            var options = {
                method: 'GET',
                uri: path,
                headers: headers,
                json: true
            }
            rp(options).then((data) => { console.log("Checking if User exists in Safe...",data); resolve(data) }).catch((err) => { console.log("Checking User ERROR",err); reject(err) });
        });
    }
    async function getAccessTokenFromSafeHealth(client_id,client_secret,path) {
        return new Promise((resolve,reject) => {
            var options = {
                method: 'POST',
                uri: auth_url,
                body: {
                  client_id: client_id,
                  client_secret: client_secret,
                  audience: auth_audience,
                  grant_type: "client_credentials"
                },
                json: true
            };
            rp(options).then((data) => { resolve(data) }).catch((err) => { reject(err) });
        });
    }
     
     async function checkUserExists() {
         return new Promise((resolve,reject) =>{
             let param = {
                TableName: covid_table,
                KeyConditionExpression: "asurite = :asurite",
                FilterExpression: "completion_type = :completion_type",
                
                Limit: 1,
                ExpressionAttributeValues: {
                  ":asurite": asurite,
                  ":completion_type": "questionnaire"
               }
            };
            let result = dynamo.query(param, function(err, data) {
              if (err) reject(err);
              else resolve(data);
            });
         })
     }
     async function getAsurite(cognitoidentity,param){
        return new Promise((resolve,reject) =>{
            cognitoidentity.lookupDeveloperIdentity(param, function (err, data) {
                console.log("INSIDE LOOKUP")
                if (!err) {
                    let asurite_id = data["DeveloperUserIdentifierList"][0]; 
                    resolve(asurite_id)
                } 
                else {
                    reject(err)
                }
            });
        }).catch((error) => {
            console.error(error);
        });
    }

    async function createNewUser(firstname,lastname,token) {
        return new Promise((resolve,reject) => {
            let path = safe_api + "/admin/user/asu?permission=DEFAULT";
            let headers = {
                "Authorization": "Bearer " + token,
                "userId": admin
            }
            let body = {
                email: email,
                firstName: firstname,
                lastName: lastname
            }
            var options = {
                method: 'POST',
                uri: path,
                headers: headers,
                body: body,
                json: true
            }
            rp(options).then((data) => { console.log("CREATE USER",data); resolve(data) }).catch((err) => { console.log("CREATE USER ERROR",err); reject(err) });
        });
    }
    
    
    async function getUserInfo(asurite) {
        return new Promise((resolve,reject) => {
            try {
            let options = {
              uri: "https://app.m.asu.edu/user-details?asurite="+asurite,
              json: true
            }
            rp(options).then((data) => { resolve(data) }).catch((err) => reject(err));
            } catch (e) {
                reject (e);
            }
        });
    }
    

    
    async function startQuestionnaire(token) {
        return new Promise((resolve,reject) => {
            let path = safe_api + "/questionnaire/exec/start";
            let headers = {
                "Authorization": "Bearer " + token,
                "userId": email
            }
            var options = {
                method: 'POST',
                uri: path,
                headers: headers,
                json: true
            }
            setTimeout(function() {
            rp(options).then((data) => { console.log("RESULT OF START QUESTION",data); resolve(data) }).catch((err) => { console.log("ERROR FROM QUESTION",err); reject(err) });
            },3000);
        });
    }
    
    async function getCurrentQuestionnaire(token) {
        return new Promise ((resolve,reject) => {
            let path = safe_api + "/questionnaire/exec/get/byForm/"+ safe_formid
            let headers = {
                "Authorization": "Bearer " + token,
                "userId": email
            }
            var options = {
                method: 'GET',
                uri: path,
                headers: headers,
                json: true
            }
            rp(options).then((data) => { resolve(data) }).catch((err) => { reject(err) });
        })
    }
    
    async function postQuestionnaire(token,questionnaireid,payload) {
        console.log("POSTING TO QUESTIONNAIRE",payload)
        return new Promise((resolve,reject) => {
            let path = safe_api + "/questionnaire/exec/next/"+questionnaireid
            let headers = {
                "Authorization": "Bearer " + token,
                "userId": email
            }
            
            let body = payload;
            var options = {
                method: 'POST',
                uri: path,
                headers: headers,
                body: body,
                json: true
            }
            rp(options).then((data) => { console.log("RESPONSE FROM QUESTIONNAIRE",data); resolve(data) }).catch((err) => {console.error("POST QUESTIONNAIRE error"); reject(err) });
        });
    }
    
    ///******** DYNAMO ********///
    async function saveQuestionnaire(questionnaire_id,question,completed,started,status,result) {
        console.log("QUESTION",question)
        return new Promise((resolve,reject) => {
           let param = {
                TableName: covid_table,
                Item: {
                    asurite: asurite,
                    userdate: day,
                    questionnaireId: questionnaire_id,
                    currentQuestion: question,
                    status: status,
                    started: started,
                    completed: completed,
                    result: result,
                    updated: daytime,
                    modality: modality,
                    completion_type: completion_type,
                    ec_asurite: ec_asurite
                },
            };
    
            let putResult =  dynamo.put(param).promise();
            resolve(putResult);
        }).catch((error) => {
            console.error(error);
        })
    }
    
    async function getQuestionnaire() {
        return new Promise((resolve,reject) => {
           let param = {
                TableName: covid_table,
                KeyConditionExpression: "asurite = :asurite AND userdate=:day",
                ExpressionAttributeValues: {
                  ":asurite": asurite,
                  ":day": day
               }
            };
             let result = dynamo.query(param, function(err, data) {
              if (err) reject(err);
              else resolve(data);
            });
        });
    }
    
};

