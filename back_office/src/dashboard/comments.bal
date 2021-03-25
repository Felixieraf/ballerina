import ballerina/http;
import ballerina/io;
import ballerina/docker;
import ballerina/config;


var env_wso2=config:getAsString("host.wso2");
var env_keycloak=config:getAsString("host.keycloak");

var idPersonne=0;

http:Client dossierSoumissionEP= new("http://127.0.0.1:8290/services/dossierSoumission");
http:Client userKeycloakEP=new(env_keycloak+"/auth/admin/realms/EDBM");
string [] group=[];
@docker:Config {
   name: "comment_list"
 }
 @docker:CopyFiles {
    files: [{sourceFile: "./Ballerina.toml", target: "/home/ballerina/Ballerina.toml", isBallerinaConf: true}]
}
 service comments on new http:Listener(7006) {


    @http:ResourceConfig {
       methods:["GET"],
       path:"/{idEntite}"
    }
    resource function aggregate_comment_list(http:Caller caller, http:Request req,string idEntite) {
         group=<@untainted><string []>req.getQueryParamValues("idGroupe");
        string [] idDossier=<string []> req.getQueryParamValues("idDossier");
        string [] token=<string []> req.getQueryParamValues("token");
       
        var request="{";
        int ln_group=group.length();
       // int i=0;
        foreach int i in  0 ..< ln_group {
           // io:println(group[i]);
          
            if(i==(ln_group-1))
            {
                request+=group[i];
            }
            else{
               request+=group[i]+",";
            }
           

        }
        request+="}"+"?idDossier="+idDossier[0];
         io:println(group);
       


        json[] aggregatedResponse = cloneAndAggregate( dossierSoumissionEP,request,token[0] );
        var res3 = caller->respond(<@untainted> aggregatedResponse);
        //io:println(payload);
    }
}

function cloneAndAggregate( http:Client clientEP1,string req,string token) returns json[] {
 
    
     
    fork {
        worker w1 returns json {
            
            return invokeDSEndpoint(clientEP1,req, token);
        } 
    }
    record{json w1; } results = wait {w1};
    
    json[] aggregatedResponse = [results.w1];
    return aggregatedResponse;
}
// Invoke endpoint  add user in keycloak, Person add person and person adress
function invokeDSEndpoint(http:Client clientEPDossierSoumission,string req,string  token) returns @untainted json {
         http:Request request = new;
         request.addHeader("Accept", "application/json");
         request.addHeader("Authorization", "Bearer "+token.toString());
        var inboundResponseComment = dossierSoumissionEP->get("/getCommentList/"+req,request);
        
            //io:println("/getCommentList/"+req+"?idDossier=12");
            if (inboundResponseComment is http:Response) {                        
                              var response=inboundResponseComment.getJsonPayload();
                              
                              
                              if(response is json){ 
                                   // io:println(response);
                                    json[] list_coms=<json []>response.comments.comment;
                                    json[] comment_list_group=[];
                                    var group_name="";
                                    var user_name="";
                                    int coms_len=list_coms.length();
                                    foreach int i in 0..<coms_len{
                                        //io:println(list_coms[i].idEntite);
                                        
                                        var inboundResponseUserGroupKeycloak =  userKeycloakEP->get("/groups/"+list_coms[i].idEntite.toString(), request);
                                        if (inboundResponseUserGroupKeycloak is http:Response) {
                                            var group_user_info=inboundResponseUserGroupKeycloak.getJsonPayload();
                                            if(group_user_info is json)
                                            {
                                                string g_info=cprocessString(group_user_info.name);
                                                io:println(g_info);
                                                group_name=g_info;
                                            
                                                //return {user_info,group_user_info};

                                            }
                                            
                                
                                        } 
                                            var inboundResponseUserKeycloak =  userKeycloakEP->get("/users/"+list_coms[i].idUtilisateur.toString(), request);
                                                        if (inboundResponseUserKeycloak is http:Response) {
                                                            var user_info=inboundResponseUserKeycloak.getJsonPayload();
                                                            if(user_info is json)
                                                            {
                                                                string u_info=cprocessString(user_info.firstName);
                                                                io:println(u_info);
                                                                user_name=u_info;
                                                            
                                                                //return {user_info,group_user_info};

                                                            }
                                                        
                                                    }
                                                    json _comment={"comment":list_coms[i],"comment_user_group":group_name,"comment_user_name":user_name};
                                                    comment_list_group.push(_comment);
                                    }
                                 return {"comment": comment_list_group}; 
                              }
                             
                      
                
            }
                

                                 
                            
  
   
}

function cprocessString(json|error je) returns @untainted string {
    if (je is json) {
        // The type test needs to be used first, to use the resultant value
        // as a JSON value.
        //io:println("JSON value: ", je);
        return je.toString();
    } else {
        //io:println("Error on JSON access: ", je.detail()?.message);
        return "";
    }
}