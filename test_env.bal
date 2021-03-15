import ballerina/http;
import ballerina/docker;
 
@docker:Config {
   push: true,
   name: "helloworld",
   tag: "v1.0.0"
 
 
}
service http:Service hello on new http:Listener(9090) {
    resource function getsayHello(http:Caller caller) {
        caller->respond("Hello World!",$env{DOCKER_TEST});
    }
}
