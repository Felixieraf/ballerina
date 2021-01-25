import ballerina/http;
//import ballerina/io;
import ballerina/log;

http:Client clientEP = new ("http://127.0.0.1:8290/services");

listener http:Listener helloWorldEP = new(9090);
// By default, Ballerina assumes that the service is to be exposed via HTTP/1.1.
@http:ServiceConfig { basePath: "/helloWorld" }
service helloWorld on helloWorldEP {
 
   // All resource functions are invoked with arguments of server connector and request.
   @http:ResourceConfig {
       methods: ["POST"],
       path: "/{name}",
       body: "message"
   }
   resource function sayHello(http:Caller caller, http:Request req, string name, string message) {
       http:Response res = new;
       // A util method that can be used to set string payload.
       res.setPayload("Hello, World! I’m " + <@untainted> name + ". " + <@untainted> message);
       // Sends the response back to the client.
       var result = caller->respond(res);
       if (result is http:ListenerError) {
            error err = result;
            log:printError("Error sending response", err = err);
       }
   }
}