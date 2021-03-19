import ballerina/io;
import ballerina/uuid;

public function main() {

    string uuid1String = uuid:createType1AsString();
    io:println("UUID of type 1 as a string: ", uuid1String);

    
}