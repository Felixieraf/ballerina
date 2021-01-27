import ballerina/http;
import ballerina/io;
import ballerina/lang.'int as langint;
import ballerina/docker;

http:Client legalStatusDocumentList = new("http://127.0.01:8290/services/document");
    @docker:Config {
   name: "upload_document_list"
    }
service clone on new http:Listener(9097) {

 

    @http:ResourceConfig {
        body: "payload"
    }
    resource function aggregate(http:Caller caller, http:Request req, json payload) {
        json[] aggregatedResponse = cloneAndAggregateUpload(payload, legalStatusDocumentList);
        var res3 = caller->respond(<@untainted> aggregatedResponse);
    }

    

}
function cloneAndAggregateUpload( json payload, http:Client clientEP1) returns json[] {
    json callerPayload = payload.clone();
    var idFormeJuridique=processint(payload.idFormeJuridique);
    var idTypeBailleur=processint(payload.idTypeBailleur);
    var idTypeContrat=processint(payload.idTypeContrat);
    var nombreAssociePersMorale=processint(payload.nombreAssociePersMorale);
    var nombreDirigeant=processint(payload.nombreDirigeant);
    var activite=processint(payload.activite);
    var activitegrossiste=processint(payload.activitegrossiste);
    var mandataire=processint(payload.mandataire);

    fork {
        worker w1 returns json {
           // ASSOCIATE
            var ressource="listdocumentToUploadByAssociate";
            var owner="Associate";
            return invokeEndpoint(clientEP1,ressource,owner);
        } worker w2 returns json {
           // LEADER
           var owner="Leader";
           var ressource="listdocumentToUploadByLeader";
            return invokeEndpoint(clientEP1,ressource,owner);
        }
        worker w3 returns json {
           // LEGAL STATUS;
           var owner="LegalStatus";
           var ressource="listdocumentToUploadByLegalStatus?idFormeJuridique="+idFormeJuridique.toString();
            return invokeEndpoint(clientEP1,ressource,owner);
        }
        worker w4 returns json {
           // ACTIVITE;
           var owner="Activity";
           var ressource="listdocumentToUploadByActivity";
           if(activite==1)
             {return invokeEndpoint(clientEP1,ressource,owner);}
            return null;
        
        }
        worker w5 returns json {
           // ACTIVITE GROSSITE ou REGLEMENTE;
           var owner="ActivityGrossiteOrReglemente";
           var ressource="listdocumentToUploadByWholesalerActivity";
            if(activitegrossiste==1)
             {return invokeEndpoint(clientEP1,ressource,owner);}
            return null;
        }
        worker w6 returns json {
           // SIEGE SOCIAL;
           var owner="Siege social";
           var ressource="listdocumentToUploadByTheHeadOffice";
         
             return invokeEndpoint(clientEP1,ressource,owner);
            
        }
        worker w7 returns json {
           // SIEGE SOCIAL;
           var owner="Siege social Bailleur";
           var ressource="listdocumentToUploadByTheHeadOfficeWithBailleurId?idTypeBailleur="+idTypeBailleur.toString();
         
             return invokeEndpoint(clientEP1,ressource,owner);
            
        }
        worker w8 returns json {
           // SIEGE SOCIAL;
           var owner="Siege social Contrat";
           var ressource="listdocumentToUploadByTheHeadOfficeWithContratId?idTypeContrat="+idTypeContrat.toString();
         
             return invokeEndpoint(clientEP1,ressource,owner);
            
        }
         worker w9 returns json {
           // Mandataire;
           var owner="Mandataire";
           var ressource="listdocumentToUploadByMandataire";
           if(mandataire==1)
           {
               return invokeEndpoint(clientEP1,ressource,owner);
           }
           return null;
         
        }
    }
    record{json w1; json w2;json w3;json w4;json w5;json w6;json w7; json w8;json w9;} results = wait {w1, w2,w3,w4,w5,w6,w7,w8,w9};
    
    json[] aggregatedResponse = [results.w1, results.w2,results.w3,results.w4,results.w5,results.w6,results.w7,results.w8,results.w9];
    return aggregatedResponse;
}


function invokeEndpoint(http:Client clientEP,string ressources,string owner) returns @untainted json {
    http:Request req = new;
    req.addHeader("Accept", "application/json");
    var inboundResponse = clientEP->get("/"+ressources,req);
    if (inboundResponse is http:Response) {
       io:println(inboundResponse);
        var inboundPayload = inboundResponse.getJsonPayload();
         
        if (inboundPayload is json) {
            return {owner:owner,inboundPayload};
        } 
    } 
    return {message: "error couldn't get the payload"};
}

function processint(json|error je) returns @untainted int {
    if (je is json) {
       
        // as a JSON value.
        io:println("JSON value: ", je);
        int|error val = langint:fromString(je.toString());
        return <int> val;
    } else {
        //io:println("Error on JSON access: ", je.detail()?.message);
        return 0;
    }
}