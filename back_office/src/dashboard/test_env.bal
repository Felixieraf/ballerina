import ballerina/http;
import ballerina/docker;
import ballerina/system;
import ballerina/io;


var wso2_env=system:getEnv("WSO2_HOST");


@docker:Config {
   name: "helloworld"
  
}
service hello on new http:Listener(9094) {
    resource function getsayHello (http:Caller caller,http:Request req) {
       
        io:print("system"+ system:getEnv("KEYCLOAK_HOST"));
        var resp=caller->respond("Hello!");
    }
}
