import ballerina/http;
import ballerina/io;
import ballerina/docker;
import ballerina/lang.'int as langint;
  

var env_dev1="http://127.0.0.1:8290";
var env_prod1="http://13.232.204.228:8290";
http:Client societyEP1 = new(env_dev1+"/services/societe");
http:Client personEP1= new(env_dev1+"/services/personne");
http:Client dossierEP1 =new(env_dev1+"/services/dossierSoumission");
@docker:Config {
   name: "get_folder_information"
 }

service getSubmittedForm on new http:Listener(7001) {


    @http:ResourceConfig {
         methods: ["GET"],
         path:"information/{id}"
     
    }
    resource function information(http:Caller caller, http:Request req,string id) {
      
        var _id= <@untainted>req.getQueryParamValue("id");
     
      
        http:Request request = new;
        int|error idDossier= langint:fromString(_id.toString());
        var idPersonne=0;
        var idSociete=0;
        var idSiegeSocial=0;
        json society={};
        request.addHeader("Accept", "application/json");
        
            //GET SOCIETY BY FOLDER ID               
        var inboundResponseSociety = societyEP1->get("/getSocietyByFolderId?idDossier="+idDossier.toString(), request);
                            if (inboundResponseSociety is http:Response) {
                                var inboundPayloadSociety = inboundResponseSociety.getJsonPayload();
                                if (inboundPayloadSociety is json) {
                                     society=inboundPayloadSociety;
                                    idSociete=iprocess(inboundPayloadSociety.societies.society.idSociete);
                                    idPersonne=iprocess(inboundPayloadSociety.societies.society.idPersonne);
                                    idSiegeSocial=iprocess(inboundPayloadSociety.societies.society.idSiegeSocial);
                                  
                                } 
                                 io:print("error when fetching society by folder");
                            } 
            //GET SIEGE SOCIAL BY ID
         json siegeSociety={};
         var idadressSiege=0;
         var inboundResponseSocietySiege = societyEP1->get("/getSiegeSocial?idSiege="+idSiegeSocial.toString(), request);
                            if (inboundResponseSocietySiege is http:Response) {
                                var inboundPayloadSocietySiege = inboundResponseSocietySiege.getJsonPayload();
                                if (inboundPayloadSocietySiege is json) {
                                    siegeSociety=inboundPayloadSocietySiege;
                                    idadressSiege=iprocess(inboundPayloadSocietySiege.sieges.siege.adresseSiegeSocial);
                                    io:print("id adress"+idadressSiege.toString());
                                } 
                                 io:print("error when fetching siege social");
                            } 
        //ADRESSSE SIEGE SOCIAL
        json siegeSocietyAdress={};
   
         var inboundResponseSocietySiegeAdress = societyEP1->get("/getAdressSiegeSocial?idAdresseSiegeSocial="+idadressSiege.toString(), request);
                            if (inboundResponseSocietySiegeAdress is http:Response) {
                                var inboundPayloadSocietySiegeAdress = inboundResponseSocietySiegeAdress.getJsonPayload();
                                io:print(inboundPayloadSocietySiegeAdress);
                                if (inboundPayloadSocietySiegeAdress is json) {
                                    siegeSocietyAdress=inboundPayloadSocietySiegeAdress;
                                   
                                    
                                } 
                                 io:print("error when fetching siege social adress");
                            } 
        //PERSON INFORMATION
        json person={};
        var idAdressPerson=0;
        var inboundResponsePerson = personEP1->get("/getPersonById?idPersonne="+idPersonne.toString(), request);
                            if (inboundResponsePerson is http:Response) {
                                var inboundPayloadPerson = inboundResponsePerson.getJsonPayload();
                                if (inboundPayloadPerson is json) {
                                    person=inboundPayloadPerson;
                                    idAdressPerson=iprocess(person.personnes.personne.idadresse);
                                    
                                } 
                                 io:print("error when fetching person");
                            } 
         json personAdress={};
         var inboundResponsePersonAdress = personEP1->get("/getAdressPerson?idAdressePerson="+idAdressPerson.toString(), request);
                            if (inboundResponsePersonAdress is http:Response) {
                                var inboundPayloadPersonAdress = inboundResponsePersonAdress.getJsonPayload();
                                if (inboundPayloadPersonAdress is json) {
                                    personAdress=inboundPayloadPersonAdress;
                                  
                                    
                                } 
                                 io:print("error when fetching person");
                            } 
        json dossier={};
         var inboundResponseDossier = dossierEP1->get("/getInformationDossier?idDossier="+idDossier.toString(), request);
                            if (inboundResponseDossier is http:Response) {
                                var inboundPayloadDossier = inboundResponseDossier.getJsonPayload();
                                if (inboundPayloadDossier is json) {
                                             dossier=inboundPayloadDossier;
                                  
                                    
                                } 
                                 io:print("error when fetching Dossier");
                            } 
        json document={};

   var inboundResponseDocument = dossierEP1->get("/getListDocumentById?idDossier="+idDossier.toString(), request);
                            if (inboundResponseDocument is http:Response) {
                                var inboundPayloadDocument = inboundResponseDocument.getJsonPayload();
                                if (inboundPayloadDocument is json) {
                                             document=inboundPayloadDocument;
                                  
                                    
                                } 
                                 io:print("error when fetching Dossier");
                            } 
    json[] aggregatedResponse = cloneAndAggregateResult(<int>idDossier,{society,siegeSociety,siegeSocietyAdress},{person,personAdress},{dossier,document} );
    var res3 = caller->respond(<@untainted> aggregatedResponse);              
    }
 
}

function cloneAndAggregateResult(int payload,json societyOutPayload,json personOutPayload, json dossierOutPayload) returns json[] {
    fork {
        worker w1 returns json {
            
            return {"SocietyOutPayload":societyOutPayload};
        } worker w2 returns json {
          return {"PersonOutPayload":personOutPayload};
        }worker w3 returns json {
          return {"DossierOutPayload":dossierOutPayload};
        }
    }
    record{json w1; json w2;json w3;} results = wait {w1, w2,w3};
    
    json[] aggregatedResponse = [results.w1, results.w2,results.w3];
    return aggregatedResponse;
}
// Invoke endpoint Person add person and person adress
function invokeEndpointPersonSociety(http:Client clientEPPerson,http:Client clientEPSociety,  int outboundPayload) returns @untainted json {
   json playload=  outboundPayload;

}
function iprocess(json|error je) returns @untainted int {
    if (je is json) {
        // The type test needs to be used first, to use the resultant value
        // as a JSON value.
        io:println("JSON value: ", je);
        int|error val = langint:fromString(je.toString());
        return <int> val;
    } else {
        //io:println("Error on JSON access: ", je.detail()?.message);
        return 0;
    }
}