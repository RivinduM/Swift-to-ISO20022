// import ballerina/http;
// // import ballerina/log;
// import ballerinax/rabbitmq;

// // Represents the subtype of http:Ok status code record for successful conversion.
// type SwiftToIso20022Response record {|
//     *http:Ok;
//     string mediaType = "application/xml";
//     xml body;
// |};

// // type Data record {|
// //     string data;
// // |};

// // Represents the subtype of http:BadRequest status code record for invalid input.
// type SwiftToIso20022BadRequest record {|
//     *http:BadRequest;
//     string body;
// |};

// // const QUEUE_NAME = "hello";
// // configurable Protocol protocol = ?;

// // public rabbitmq:Client mqClient = check new (rabbitmq:DEFAULT_HOST, rabbitmq:DEFAULT_PORT);

// // public ftp:Client fileClient = check new({});

// // # This service converts SWIFT messages to ISO 20022 XML.
// // # The service is exposed at `/transform` and listens to HTTP requests at port `9090`.
// // #
// // @http:ServiceConfig {
// //     cors: {
// //         allowOrigins: ["http://localhost:3000"],
// //         allowCredentials: false,
// //         maxAge: 84900
// //     }
// // }
// // service / on new http:Listener(9090) {

// //     # SWIFT MT to ISO 20022 transformation service.
// //     # + return - Transformed ISO 20022 XML or an appropriate error response.
// //     resource function post mt\-mx/transform(@http:Payload string swiftMessage)
// //         returns xml|http:NotFound {

// //         if (!protocol.API.enabled) {
// //             log:printError("API is not enabled");
// //             return http:NOT_FOUND;
// //         }
// //         return transformMtToMx(swiftMessage);
// //     }

// //     # ISO 20022 to SWIFT MT transformation service.
// //     # + return - Transformed MT or an appropriate error response.
// //     resource function post mx\-mt/transform(@http:Payload xml isoMessage, string targetType)
// //         returns string|error|http:NotFound {

// //         if (!protocol.API.enabled) {
// //             log:printError("API is not enabled");
// //             return http:NOT_FOUND;
// //         }
// //         return transformMxToMt(isoMessage, targetType);
// //     }

// //     function init() returns error? {

// //         if (protocol.MQ.enabled) {
// //             // todo init with configured values
// //             // self.mqClient = check new (rabbitmq:DEFAULT_HOST, rabbitmq:DEFAULT_PORT);
// //             check mqClient->queueDeclare(QUEUE_NAME);
// //         }
// //     }

// //     resource function post sendToMQ(@http:Payload string message) returns http:Accepted|error|http:NotFound {

// //         if (!protocol.MQ.enabled) {
// //             log:printError("MQ is not enabled");
// //             return http:NOT_FOUND;
// //         }
// //         // Publishes the message using the `newClient` and the routing key named `OrderQueue`.
// //         check mqClient->publishMessage({content: message.toBytes(), routingKey: QUEUE_NAME});

// //         return http:ACCEPTED;
// //     }

// //     resource function get sendToFtp(string fileName) returns error?|http:NotFound|http:Accepted {
// //         if (!protocol.SFTP.enabled) {
// //             log:printError("SFTP is not enabled");
// //             return http:NOT_FOUND;
// //         }
// //         check sendFile(fileName);
// //         return http:ACCEPTED;
// //     }
// // }
