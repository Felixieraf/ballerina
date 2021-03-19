import ballerina/http;
import ballerina/io;
import ballerina/docker;
import ballerina/config;

var env=config:getAsString("host.keycloak");
http:Client userKeycloakEP =new(env);
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
    var user_id="";
   
    var inboundResponseUserKeycloak = userKeycloakEP->get("/auth/realms/EDBM/protocol/openid-connect/userinfo", request);
                            if (inboundResponseUserKeycloak is http:Response) {
                                io:print("ok",inboundResponseUserKeycloak);
                              var user_info=inboundResponseUserKeycloak.getJsonPayload();
                                if(user_info is json)
                                {
                                   
                                    if(inboundResponseUserKeycloak.statusCode===200)
                                    {
                                   
                                        user_id=string_process(user_info.sub);
                                       
                                        var inboundResponseUserGroupKeycloak =  userKeycloakEP->get("/auth/admin/realms/EDBM/users/"+user_id.toString()+"/groups", request);
                                        if (inboundResponseUserGroupKeycloak is http:Response) {
                                            var group_user_info=inboundResponseUserGroupKeycloak.getJsonPayload();
                                            if(group_user_info is json)
                                            {
                                            
                                                return {user_info,group_user_info};

                                            }
                                        
                                
                            } 

                                        
                                    }

                                }
                               
                                
                            } 
                             return {message: "ERROR"};
  
   
}
function string_process(json|error je) returns @untainted string {
    if (je is json) {
        // The type test needs to be used first, to use the resultant value
        // as a JSON value.
        io:println("JSON value: ", je);
        return je.toString();
    } else {
        //io:println("Error on JSON access: ", je.detail()?.message);
        return "";
    }
}