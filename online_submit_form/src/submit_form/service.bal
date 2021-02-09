import ballerina/http;
import ballerina/io;
import ballerina/lang.'int as langint;
import ballerina/lang.'float;
import ballerina/docker;

var env_dev="http://127.0.0.1:8290";
var env_prod="http://13.232.204.228:8290";
http:Client societyEP = new(env_dev+"/services/societe");
http:Client personEP= new(env_dev+"/services/personne");
http:Client dossierEP =new(env_dev+"/services/dossierSoumission");

var idPersonne=0;
var idSiegeSocial=0;

@docker:Config {
   name: "submit_form"
 }

service submitForm on new http:Listener(9096) {


    @http:ResourceConfig {
        body: "payload"
    }
    resource function aggregate(http:Caller caller, http:Request req, json payload) {
        json[] aggregatedResponse = cloneAndAggregate(<map<json>>payload, personEP,societyEP );
        var res3 = caller->respond(<@untainted> aggregatedResponse);
        //io:println(payload);
    }
}

function cloneAndAggregate(map<json> payload, http:Client clientEP1, http:Client clientEP2) returns json[] {
    map<json> callerPayload = payload.clone();
    
     
    fork {
        worker w1 returns json {
            
            return invokeAllEndpoint(clientEP1, clientEP2,payload);
        } worker w2 returns json {
            callerPayload["endpoint2"] = "endpoint2Value";
            
            //return invokeEndpointSociety(clientEP2, callerPayload);
        }
    }
    record{json w1; json w2;} results = wait {w1, w2};
    
    json[] aggregatedResponse = [results.w1, results.w2];
    return aggregatedResponse;
}
// Invoke endpoint Person add person and person adress
function invokeAllEndpoint(http:Client clientEPPerson,http:Client clientEPSociety,  json outboundPayload) returns @untainted json {
   json playload=  outboundPayload;
   // Adresse Personne setting outbound
    int idFokontany=process(playload.step1.adresse.idFokontany);
    var idCommune=process(playload.step1.adresse.idCommune);
    var idDistrict=process(playload.step1.adresse.idDistrict);
    var idProvince=process(playload.step1.adresse.idProvince);
    var idRegion=process(playload.step1.adresse.idRegion);
    var adresse=processString(playload.step1.adresse.adresse);
    var idArrondissement=process(playload.step1.adresse.idArrondissement);
    // Personne information
    var nom=processString(playload.step1.personne.nom);
    var prenom=processString(playload.step1.personne.prenom);
    var idRole=process(playload.step1.personne.idRole);             
    var tel=processString(playload.step1.personne.tel);
    var e_mail=processString(playload.step1.personne.e_mail);
    var societe_mandataire=processString(playload.step1.personne.societe_mandataire);                 
    json playloadAdress=     {
                                    "_postaddAdressPerson": {
                                        
                                            "idFokontany":idFokontany,
                                            "idCommune":idCommune,
                                            "idDistrict":idDistrict, 
                                            "idProvince":idProvince,
                                            "idRegion":idRegion,
                                            "adresse":adresse,
                                            "idArrondissement":idArrondissement
                                    }
                                };
    var idAdressPerson=0;
    // CALL API ADD PERSON ADRESS
    var inboundResponsePersonAdress = clientEPPerson->post("/addAdressPerson", playloadAdress);
        if (inboundResponsePersonAdress is http:Response) {
            var inboundPayloadAdressId = inboundResponsePersonAdress.getJsonPayload();
                if (inboundPayloadAdressId is json) {
                    idAdressPerson=process(inboundPayloadAdressId.idAdresses.idAdresse);
                    io:println(idAdressPerson);
                    json playloadPerson= {
                                            "_postaddPersonOnOnlineForm": {
                                                
                                                        "nom": nom,
                                                        "prenom": prenom,
                                                        "idAdresse":idAdressPerson,
                                                        "idRole":idRole,
                                                        "tel":tel,
                                                        "e_mail":e_mail,
                                                        "societe_mandataire":societe_mandataire 
                                            }
                                        };
                                        //CALL API ADD PERSON
                            var inboundResponsePerson = clientEPPerson->post("/addPersonOnOnlineForm", playloadPerson);
                            if (inboundResponsePerson is http:Response) {
                                var inboundPayloadPerson = inboundResponsePerson.getJsonPayload();
                                if (inboundPayloadPerson is json) {
                                    idPersonne=process(inboundPayloadPerson.person_ids.person_id);
                                  
                                    return   invokeEndpointSociety(clientEPSociety,outboundPayload,idPersonne);
                                } 
                            } 
                   



                    return {message:inboundPayloadAdressId};
                } 
                return {message:"error add Person"};
    }
    

    return {message: "erreur"};
}

function invokeEndpointSociety(http:Client clientEPSociety,json outboundPayload,int idPersonne) returns @untainted json {
json playload=  outboundPayload;
    // Siège Social
     var dureebail=process(playload.step3.siege.dureebail);
     var montantBail=process(playload.step3.siege.montantBail);
    
     var idTypeBailleur=process(playload.step3.siege.idTypeBailleur);
     var idTypeContrat=process(playload.step3.siege.idTypeContrat);

     // Society information
     var denominationSocial=processString(playload.step2.denominationSocial);
     var activitePrincipal=processString(playload.step2.activitePrincipal);
     var formeJuridique=processString(playload.step2.formeJuridique);
     var idFormeJuridique=process(playload.step2.idFormeJuridique);
     var dateStatut=processString(playload.step2.dateStatut);
     var capital=processFloat(playload.step2.capital);
     var activiteImportExport=process(playload.step2.activiteImportExport);
     var activiteIndustrielCollecteur=process(playload.step2.activiteIndustrielCollecteur);
     var objetSocial= processString(playload.step2.objetSocial);
     var activiteGrossiste= process(playload.step2.activiteGrossiste);
     var autreActiviteReglemente=process(playload.step2.autreActiviteReglemente);
     var choixImposition=process(playload.step2.choixImposition);
     var nombreAssociePersPhysique= process(playload.step2.nombreAssociePersPhysique);
     var nombreAssociePersMorale= process(playload.step2.nombreAssociePersMorale);
     var nombreDirigeant= process(playload.step2.nombreDirigeant);
     // "idPersonne":4           
    
    // CALL API ADD SIEGE SOCIAL ADDRESS
    // Adresse Siege Social setting outbound
    int idFokontany=process(playload.step3.adresse.idFokontany);
    var idCommune=process(playload.step3.adresse.idCommune);
    var idDistrict=process(playload.step3.adresse.idDistrict);
    var idProvince=process(playload.step3.adresse.idProvince);
    var idRegion=process(playload.step3.adresse.idRegion);
    var adresse=processString(playload.step3.adresse.adresse);
    var idArrondissement=process(playload.step3.adresse.idArrondissement);
     json playloadAdress=     {
                                    "_postaddAdressSociety": {
                                        
                                            "idFokontany":idFokontany,
                                            "idCommune":idCommune,
                                            "idDistrict":idDistrict, 
                                            "idProvince":idProvince,
                                            "idRegion":idRegion,
                                            "adresse":adresse,
                                            "idArrondissement":idArrondissement
                                    }
                                };
    // CALL API ADD SOCIETY ADRESS

    var inboundResponseSocietyAdress = clientEPSociety->post("/addAdressSociety", playloadAdress);
        if (inboundResponseSocietyAdress is http:Response) {
            var inboundPayloadAdressId = inboundResponseSocietyAdress.getJsonPayload();
                if (inboundPayloadAdressId is json) {
                    var adresseSiegeSocial=process(inboundPayloadAdressId.idAdresses.idAdresse);
                     //playload idSiegeSocial
                    json playloadSiegeSocial={
                                                "_postaddSiegeSocial":{
                                                    "dureebail":dureebail,
                                                    "montantBail":montantBail,
                                                    "adresseSiegeSocial":adresseSiegeSocial,
                                                    "idTypeBailleur":idTypeBailleur,
                                                    "idTypeContrat":idTypeContrat
                                                }
                                            };
                    io:println(adresseSiegeSocial);
                    
                                        //CALL API ADD SIEGE SOCIAL
                           var inboundResponseSiegeSocial = clientEPSociety->post("/addSiegeSocial", playloadSiegeSocial);
                            if (inboundResponseSiegeSocial is http:Response) {
                                var inboundPayloadSiegeSocial = inboundResponseSiegeSocial.getJsonPayload();
                                if (inboundPayloadSiegeSocial is json) {
                                    var idSiegeSocial=process(inboundPayloadSiegeSocial.idSiege.idSiege);
                                    json playloadSociety= {
                                                        "_postaddaddSocietyForm":{
                                                            "denominationSocial":denominationSocial,
                                                            "activitePrincipal":activitePrincipal,
                                                            "formeJuridique":formeJuridique,
                                                            "dateStatut":dateStatut,
                                                            "capital":capital,  
                                                            "activiteImportExport":activiteImportExport, 
                                                            "activiteIndustrielCollecteur":activiteIndustrielCollecteur, 
                                                            "objetSocial":objetSocial, 
                                                            "activiteGrossiste":activiteGrossiste, 
                                                            "autreActiviteReglemente":autreActiviteReglemente,
                                                            "choixImposition":choixImposition, 
                                                            "nombreAssociePersPhysique":nombreAssociePersPhysique,
                                                            "nombreAssociePersMorale":nombreAssociePersMorale, 
                                                            "nombreDirigeant":nombreDirigeant, 
                                                            "idPersonne":idPersonne,
                                                            "idSiegeSocial":idSiegeSocial
                                                            
                                                        }
                                                    } ;
                                                    // CALL API ADD SOCIETY
                                   var inboundResponseSociety = clientEPSociety->post("/addSocietyForm", playloadSociety);
                                   var idSociety=0;
                                        if (inboundResponseSociety is http:Response) {
                                            var inboundPayloadSociety = inboundResponseSociety.getJsonPayload();
                                            if (inboundPayloadSociety is json) {
                                                 idSociety=process(inboundPayloadSociety.idSocietes.idSociete);
                                                var document_id=idFormeJuridique.toString()+idSociety.toString()+idSiegeSocial.toString();
                                                int|error val = langint:fromString(document_id.toString());
                                                io:println("id_document:",val);
                                                json idDossierSoc={"id_document:":""+val.toString()};
                                                json inboundPlayloadDossier={};
                                                json payloadNumDossier={
                                                                            "_postaddFolderNumber":{
                                                                            
                                                                                "numeroDossier":process(val)
                                                                            }
                                                                        };

                                                var inboundResponseDossier = dossierEP->post("/addFolderNumber", payloadNumDossier);
                                                    if (inboundResponseDossier is http:Response) {
                                                        var inboundPayloadDossier = inboundResponseDossier.getJsonPayload();
                                                        if (inboundPayloadDossier is json) {
                                                            
                                                            //json idDossierSoc={"id_document:":""+val.toString()};
                                                            inboundPlayloadDossier=inboundPayloadDossier;
                                                            var idDossier=process(inboundPayloadDossier.idDossiers.idDossier);
                                                            json payloadPutFolderNumber={"_putsetsocetyfolder":
                                                                                            {
                                                                                                "idSociete":idSociety,
                                                                                                "idDossier":idDossier

                                                                                            }
                                                                                        };
                                                                                         io:println("test....");
                                                             var inboundResponceUpdateSociety=clientEPSociety->put("/setSocetyFolder",payloadPutFolderNumber);
                                                             if(inboundResponceUpdateSociety is http:Response){
                                                                 io:println("Folder updated");
                                                             }
                                                        return inboundPayloadDossier;
                                                        } 
                                                    } 

                                             return {inboundPayloadSociety};
                                            } 
                                        } 
                                         return inboundPayloadSiegeSocial;
                                } 
                                 //return inboundPayloadSiegeSocial;
                            } 
                           

                    return{message:inboundPayloadAdressId};
                   
                } 
                 return {message: "erreur step2&step3"};
    }

   
    
                             
  
}

function process(json|error je) returns @untainted int {
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

function processFloat(json|error je) returns @untainted float {
    if (je is json) {
        // The type test needs to be used first, to use the resultant value
        // as a JSON value.
        io:println("JSON value: ", je);
        float|error val = 'float:fromString(je.toString());
        return <float> val;
    } else {
        //io:println("Error on JSON access: ", je.detail()?.message);
        return 0;
    }
}
function processString(json|error je) returns @untainted string {
    if (je is json) {
        // The type test needs to be used first, to use the resultant value
        // as a JSON value.
        io:println("JSON value: ", je);
        return je.toString();
    } else {
        //io:println("Error on JSON access: ", je.detail()?.message);
        return "no";
    }
}