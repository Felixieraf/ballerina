import ballerina/http;
import ballerina/docker;
import ballerina/config;
 
@docker:Config {
   push: true,
   name: "helloworld",
   tag: "v1.0.0",
   username: "$env{DOCKER_TEST}"
 
}
service hello on new http:Listener(9094) {
    resource function getsayHello (http:Caller caller) {
        caller->respond(config:getAsString("test.name"));
    }
}
