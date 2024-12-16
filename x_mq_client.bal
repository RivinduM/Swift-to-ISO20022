// import ballerinax/ibm.ibmmq;

// configurable string queueManagerName = ?;
// configurable string host = ?;
// configurable int port = ?;
// configurable string channel = ?;
// configurable string userID = ?;
// configurable string password = ?;

// configurable string queueName = ?;

// // configurable string topicName = ?;
// // configurable string topicString = ?;


// ibmmq:QueueManager queueManager = check new (
//     name = queueManagerName, host = host, port = port, channel = channel, userID = userID, password = password
// );




// ibmmq:Queue queue = check queueManager.accessQueue(queueName, ibmmq:MQOO_OUTPUT | ibmmq:MQOO_INPUT_AS_Q_DEF);

// function sendToQueue(string message) returns error? {
//     check queue->put({
//         payload: message.toBytes()
// });
// }


// // ibmmq:Topic topic = check queueManager.accessTopic(
// //     topicName, topicString, ibmmq:MQOO_OUTPUT | ibmmq:MQOO_INPUT_AS_Q_DEF
// // );