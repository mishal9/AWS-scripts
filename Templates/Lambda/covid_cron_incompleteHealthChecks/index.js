const AWS = require('aws-sdk')
const sqs = new AWS.SQS();
const dynamo = new AWS.DynamoDB.DocumentClient();
const moment = require('moment-timezone')
const accountId = '456214169279';
const queueName = process.env.sqs_queue;

exports.handler = (event, context, callback) => {
  let date = new Date();
  let day = moment(date.getTime()).tz("America/Phoenix").subtract(0,'day').format("YYYY/MM/DD");
  let question_map = {};
  let asurites = [];
  let finals = [];
  let getMapping = (typeof(event.mapping) != "undefined") ? true : false;
  getQuestionnaireMappingFromDynamo();
 
  function getQuestionnaireMappingFromDynamo(){
    var TABLE_NAME = 'covid_questionnaire_mapping';
    var params = {
      TableName: TABLE_NAME,
    };
    console.log("Params:");
    console.log(params);
    dynamo.scan(params, function(err, data) {
      if (!err) {
        //console.log(data);
        let finalobjs = []
        data.Items.forEach(function(item) {
          let obj = {}
          question_map[item.name] = item.screen;
          obj.id = item.screen;
          obj.name = item.name;
          obj.question_text = item.question;
          obj.response_options = item.responses;
          finalobjs.push(obj);
        });
        if (getMapping) {
          context.succeed(finalobjs)
        }
        getQuestionnairesFromDynamo('');
      } else {
        context.fail(err);
      }
    });
  }
  
  function getQuestionnairesFromDynamo(lastEvaluatedKey){
    var TABLE_NAME = 'covid_questionnaire_prod';
    var params = {
      TableName: TABLE_NAME,
      IndexName: "userdate-index",
      KeyConditionExpression: "userdate = :userdate",
      FilterExpression: "completed = :completed",
      ExpressionAttributeValues: {
        ":userdate": day,
        ":completed": false
      },
      ExclusiveStartKey:lastEvaluatedKey
    }
     
    let obj = {};
    if (params.ExclusiveStartKey == '') {
      delete params.ExclusiveStartKey;
    }
    dynamo.query(params, function(err, data) {
      if (!err) {
       // console.log(JSON.stringify(data));
        //context.succeed(data.Items.length);
        data.Items.forEach(function(item) {
          if(!item.completed){
            asurites.push(item.asurite);
            obj.asurite_id = item.asurite;
            obj.origin = item.modality? item.modality: null;
            obj.date = item.updated;
            if (typeof(item.currentQuestion) != "undefined" && item.currentQuestion) {
              obj.last_question_id = question_map.hasOwnProperty(item.currentQuestion.name) ? question_map[item.currentQuestion.name] : -1;
            } else {
              obj.last_question_id = null;
            }
            obj.TableName = "asu_health_checkin.health_check_incomplete";
            console.log("Final Object",obj)
            finals.push(obj);
          }
        });
        if (data.LastEvaluatedKey) {
          getQuestionnairesFromDynamo(data.LastEvaluatedKey);
        } else {
          context.succeed(finals.length)
          //sendToSQS(obj);
           
        }
      } else {
        context.fail(err);
        
      }
    });
  }
  
  function sendToSQS(obj) { 
    console.log(JSON.stringify(obj));
    const params = {
      MessageBody: JSON.stringify(obj),
      QueueUrl: `https://sqs.us-west-2.amazonaws.com/${accountId}/${queueName}`
    };
    sqs.sendMessage(params, (err, data) => {
      if (err) {
        console.log("Error", err);
        context.fail(err)
      } else {
        console.log("Successfully added message", data.MessageId);
        context.succeed(data);
      }
    });
  }
};

     
