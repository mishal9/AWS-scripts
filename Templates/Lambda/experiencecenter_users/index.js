const AWS = require("aws-sdk");
const dynamo = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event) => {
    // TODO implement
       var users = event.users;
       let count = users.length;
       let i = 0;
       return new Promise(async function(resolve,reject) {
            users.map((asurite) => {
                let asu = asurite.trim(); 
                var params = {
                    "TableName":  "covid_experiencecenter_users",
                    "Item": {
                        "asurite": asu,
                        "role": "Admin"
                    }
                }
                let complete = dynamo.put(params).promise();
                ++i
                if (i == count) {
                  resolve(complete)
                }
            });
    });
};
