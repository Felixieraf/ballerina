import ballerina/http;
import ballerina/io;
import ballerina/docker;
import ballerina/lang.'int as langint;
  

var env_dev1="http://127.0.0.1:8290";
var env_prod1="http://13.232.204.228:8290";
http:Client societyEP1 = new(env_dev1+"/services/societe");
http:Client personEP1= new(env_dev1+"/services/personne");
http:Client dossierEP1 =new(env_dev1+"/services/dossierSoumission");
http:Client localisationEP1=new(env_dev1+"/services/localisation");


@docker:Config {
   name: "get_folder_information"
 }

service getSubmitedFormById on new http:Listener(7001) {


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
        var idCategory="'";
       
        json society={};
        request.addHeader("Accept", "application/json");
        
            //GET SOCIETY BY FOLDER ID               
        var inboundResponseSociety = societyEP1->get("/getSocietyByFolderId?idDossier="+idDossier.toString(), request);
                            if (inboundResponseSociety is http:Response) {
                                var inboundPayloadSociety = inboundResponseSociety.getJsonPayload();
                                if (inboundPayloadSociety is json) {
                                     var category="";
                                    idSociete=iprocess(inboundPayloadSociety.societies.society.idSociete);
                                    idPersonne=iprocess(inboundPayloadSociety.societies.society.idPersonne);
                                    idSiegeSocial=iprocess(inboundPayloadSociety.societies.society.idSiegeSocial);
                                    idCategory=processString(inboundPayloadSociety.societies.society.activitePrincipal);
                                    http:Client siteInformationEP1=new(env_dev1+"/services/siteInformation");
                                      io:print("idcategory",idCategory);
                                    var inboundResponseActivity = siteInformationEP1->get("/getCategoryName?id="+idCategory.toString(), request);
                                    if (inboundResponseActivity is http:Response) {
                                        var inboundPayloadCategory = inboundResponseActivity.getJsonPayload();
                                        if (inboundPayloadCategory is json) {
                                            category=processString(inboundPayloadCategory.categoryNames.categoryName.descriptivesCategorie_fr);
                                        } 
                                       
                                    } 
                                        society={inboundPayloadSociety,"categorie":category};
                                    } 
                                 
                            } 
            //GET SIEGE SOCIAL BY ID
         json siegeSociety={};
         var idadressSiege=0;
         json adress_id_adress_name={};
         string adresse="";
         var inboundResponseSocietySiege = societyEP1->get("/getSiegeSocial?idSiege="+idSiegeSocial.toString(), request);
                            if (inboundResponseSocietySiege is http:Response) {
                                var inboundPayloadSocietySiege = inboundResponseSocietySiege.getJsonPayload();
                                if (inboundPayloadSocietySiege is json) {
                                    io:print("ADRDD",inboundPayloadSocietySiege);
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
                                    //adresse=processString(inboundPayloadSocietySiege.sieges.siege.adresse);
                                     io:print("id adress"+idadressSiege.toString());
                                    int id_f=iprocess(inboundPayloadSocietySiegeAdress.adresses.adresse.idFokontany);
                                    int id_b=iprocess(inboundPayloadSocietySiegeAdress.adresses.adresse.idArrondissement);
                                    int id_c=iprocess(inboundPayloadSocietySiegeAdress.adresses.adresse.idCommune);
                                    int id_d=iprocess(inboundPayloadSocietySiegeAdress.adresses.adresse.idDistrict);
                                    int id_r=iprocess(inboundPayloadSocietySiegeAdress.adresses.adresse.idRegion);
                                    int id_p=iprocess(inboundPayloadSocietySiegeAdress.adresses.adresse.idProvince);
                                    adresse=processString(inboundPayloadSocietySiegeAdress.adresses.adresse.adresse);
                                    
                                    var inboudResponseLocalisationName=localisationEP1->get("/getAdressName?fokontany_id="+id_f.toString()+"&common_id="+id_c.toString()+"&province_id="+id_p.toString()+"&borough_id="+id_b.toString()+"&region_id="+id_r.toString()+"&district_id="+id_r.toString(),request);
                                    if(inboudResponseLocalisationName is http:Response)
                                    {
                                        var inboundPayloadLocalisation=inboudResponseLocalisationName.getJsonPayload();
                                        io:print("/getAdressName?fokontany_id="+id_f.toString()+"&common_id="+id_c.toString()+"&province_id="+id_p.toString()+"&borough_id="+id_b.toString()+"&region_id="+id_r.toString()+"&district_id="+id_r.toString());
                                        if(inboundPayloadLocalisation is json){
                                            siegeSocietyAdress={"region":inboundPayloadLocalisation,"adress":adresse};
                                        }
                                    }
                                    
                                    
                                   
                                    
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
         string adresse_p="";
         var inboundResponsePersonAdress = personEP1->get("/getAdressPerson?idAdressePerson="+idAdressPerson.toString(), request);
                            if (inboundResponsePersonAdress is http:Response) {
                                var inboundPayloadPersonAdress = inboundResponsePersonAdress.getJsonPayload();
                                if (inboundPayloadPersonAdress is json) {

                                      io:print("id adress"+idadressSiege.toString());
                                    int id_f=iprocess(inboundPayloadPersonAdress.adresses.adresse.idFokontany);
                                    int id_b=iprocess(inboundPayloadPersonAdress.adresses.adresse.idArrondissement);
                                    int id_c=iprocess(inboundPayloadPersonAdress.adresses.adresse.idCommune);
                                    int id_d=iprocess(inboundPayloadPersonAdress.adresses.adresse.idDistrict);
                                    int id_r=iprocess(inboundPayloadPersonAdress.adresses.adresse.idRegion);
                                    int id_p=iprocess(inboundPayloadPersonAdress.adresses.adresse.idProvince);
                                    adresse_p=processString(inboundPayloadPersonAdress.adresses.adresse.adresse);
                                    
                                    var inboudResponseLocalisationName=localisationEP1->get("/getAdressName?fokontany_id="+id_f.toString()+"&common_id="+id_c.toString()+"&province_id="+id_p.toString()+"&borough_id="+id_b.toString()+"&region_id="+id_r.toString()+"&district_id="+id_r.toString(),request);
                                    if(inboudResponseLocalisationName is http:Response)
                                    {
                                        var inboundPayloadLocalisation=inboudResponseLocalisationName.getJsonPayload();
                                        io:print("/getAdressName?fokontany_id="+id_f.toString()+"&common_id="+id_c.toString()+"&province_id="+id_p.toString()+"&borough_id="+id_b.toString()+"&region_id="+id_r.toString()+"&district_id="+id_r.toString());
                                        if(inboundPayloadLocalisation is json){
                                            personAdress={"region":inboundPayloadLocalisation,"adress":adresse_p};
                                        }
                                    }
                                    
                                   // personAdress=inboundPayloadPersonAdress;

                                  
                                    
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