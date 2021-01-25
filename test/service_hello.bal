import ballerina/http;
import ballerina/io;

service hello on new http:Listener(9090) {

    resource function sayHello(http:Caller caller,
        http:Request req) returns error? {

        check caller->respond("Hello, World!");
    }

    resource function parallel(http:Caller caller,http:Request req)returns error ?{
        @strand {thread: "any"}
            worker w1 {
                io:println("Hello, World! #m");
              
            }

            @strand {thread: "any"}
            worker w2 {
                io:println("Hello, World! #n");
            }

            @strand {thread: "any"}
            worker w3 {
                io:println("Hello, World! #k");
            }
            check caller->respond("Hello, World!");
    }
}