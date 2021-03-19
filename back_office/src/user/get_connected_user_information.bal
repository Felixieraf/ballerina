import ballerina/http;
import ballerina/io;
import ballerina/docker;


http:Client userKeycloakEP =new("http://13.232.204.228:8081");
@docker:Config {
   name: "user_information"
 }
 @docker:CopyFiles {
    files: [{sourceFile: "./Ballerina.toml", target: "/home/ballerina/Ballerina.toml", isBallerinaConf: true}]
}
 service connexion on new http:Listener(7005) {


    @http:ResourceConfig {
        methods: ["GET"]
    }
    resource function user_information(http:Caller caller, http:Request req) {
        json[] aggregatedResponse = getResult(req.getQueryParamValue("token").toString());
        var res3 = caller->respond(<@untainted> aggregatedResponse);
        //io:println(payload);
    }
}

function getResult(string token) returns json[] {
    
     
    fork {
        worker w1 returns json {
            
            return invokeUserEP(token);
        } 
    }
    record{json w1; } results = wait {w1};
    
    json[] aggregatedResponse = [results.w1];
    return aggregatedResponse;
}
// Invoke endpoint  add user in keycloak, Person add person and person adress
function invokeUserEP(string  token) returns @untainted json {
  
    http:Request request = new;
    request.addHeader("Content-Type", "application/json");
    request.addHeader("Authorization", "Bearer "+token.toString());
    
   
    var inboundResponseUserKeycloak = userKeycloakEP->get("/auth/realms/EDBM/protocol/openid-connect/userinfo", request);
                            if (inboundResponseUserKeycloak is http:Response) {
                                io:print("ok",inboundResponseUserKeycloak);
                                var user_info=inboundResponseUserKeycloak.getJsonPayload();
                                 //io:print(user_info);
                                if(inboundResponseUserKeycloak.statusCode===200)
                                {
                                    io:print(user_info.sub.toString());
                                      
                                }

                                 return {message: "ERROR"};
                            } 
  
   
}