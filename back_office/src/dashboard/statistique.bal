
import ballerina/http;
import ballerina/docker;
import ballerina/io;
import ballerina/config;


var env_wso2=config:getAsString("host.wso2");
var port_wso2=config:getAsString("port.wso2");



http:Client EP =new(env_wso2+":"+port_wso2+"/services/dossierSoumission");
@docker:Config {
   name: "get_statistique"
 }

service get_statistique_dossier on new http:Listener(7003) {


    @http:ResourceConfig {
         methods: ["GET"]
     
    }
    resource function statistique(http:Caller caller, http:Request req) {
      
        var nouveau=1;
        var en_cours=7;
        var termine=6;
        json total=0;
        json statistique={};
        http:Request request = new;
        request.addHeader("Accept", "application/json");
       var inboundResponseStat = EP->get("/getstatistiqueTotal",request);
                            if (inboundResponseStat is http:Response) {
                                var inboundPayloadStat = inboundResponseStat.getJsonPayload();
                                io:print(inboundResponseStat.getJsonPayload());
                                if (inboundPayloadStat is json) {
                                    total=inboundPayloadStat;
                                } 
                                 io:print("error when fetching society by folder");
                            } 
       
    json[] aggregatedResponse = cloneAndAggregateStatistique(nouveau,en_cours,termine,total);
    var res3 = caller->respond(<@untainted> aggregatedResponse);              
    }
 
}
function cloneAndAggregateStatistique(int nouveau,int en_cours,int termine, json total) returns json[] {
    fork {
        worker w1 returns json {
        return invoqueEndpointStatus(nouveau,"nouveau");
        }
        worker w2 returns json {
          return invoqueEndpointStatus(en_cours,"encours");
        }
        worker w3 returns json {
          return invoqueEndpointStatus(termine,"termine");
        }
         worker w4 returns json {
          return{"total":total};
        }
    }
    record{json w1; json w2;json w3;json w4;} results = wait {w1, w2,w3,w4};
    
    json[] aggregatedResponse = [results.w1, results.w2,results.w3,results.w4];
    return aggregatedResponse;
}

function invoqueEndpointStatus(int idStatut,string label) returns @untainted json{

http:Request request = new;
request.addHeader("Accept", "application/json");
    var inboundResponseStat = EP->get("/getstatistiqueDossierNouveauTermine?idStatutDossier="+idStatut.toString(),request);
                            if (inboundResponseStat is http:Response) {
                                var inboundPayloadStat = inboundResponseStat.getJsonPayload();
                                io:print(inboundResponseStat.getJsonPayload());
                                if (inboundPayloadStat is json) {

                                     return {"label":label,inboundPayloadStat};
                                     
                                } 
                                 io:print("error when fetching society by folder");
                            } 


}