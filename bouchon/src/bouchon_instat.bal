import ballerina/http;
import ballerina/docker;




@docker:Config {
   name: "get_bouchon"
 }

service getBouchon on new http:Listener(9086) {


    @http:ResourceConfig {
         methods: ["GET"],
         path:"society_list"
    }
    resource function information(http:Caller caller, http:Request req) {
         req.addHeader("Accept", "application/json");
      
       json payload_1={
           "societes":{
               "societe_list":[
                   {
                       "District":"ANTANANARIVO",
                       "Denomination":"société A",
                       "Siege":"Siege société A",
                       "NomCommerciale":"Nom commericale societe A",
                       "SiegeSocial":"Siège sociale societe A",
                       "LieuExploitation":"Lieu d'exploitation societe A",
                       "Mail":"mailsocietea@mailesia.com",
                       "Forme Juridique":"SARL",
                       "Contact":"320000152",
                       "Activites":"activite societe A",
                       "EmploiCree":"emploi1 de societe A",
                       "Secteur":"Primaire",
                       "CodeActivite":"Exploitation minière",
                       "RCS":"rcs societe 1",
                       "DateRCS":"14/02/2021",
                       "Statistique":"11223335588844",
                       "DateStatistique":"14/02/2021",
                       "NIF":"nif societe A",
                       "DateNIF":"14/02/2021",
                       "DateReception":"13/02/2021",
                       "DateDelivrance":"15/02/20201"

                   }
               ]
           }
       };
       json payload_2={
           "societes":{
               "societe_list":[
                   {
                       "District":"ANTANANARIVO",
                       "Denomination":"société B",
                       "Siege":"Siege société B",
                       "NomCommerciale":"Nom commericale societe B",
                       "SiegeSocial":"Siège sociale societe B",
                       "LieuExploitation":"Lieu d'exploitation societe B",
                       "Mail":"mailsocietea@mailesia.com",
                       "Forme Juridique":"SARL",
                       "Contact":"320000152",
                       "Activites":"activite societe B",
                       "EmploiCree":"emploi1 de societe B",
                       "Secteur":"Primaire",
                       "CodeActivite":"Exploitation minière",
                       "RCS":"rcs societe 1",
                       "DateRCS":"14/02/2021",
                       "Statistique":"11223335588844",
                       "DateStatistique":"14/02/2021",
                       "NIF":"nif societe B",
                       "DateNIF":"14/02/2021",
                       "DateReception":"13/02/2021",
                       "DateDelivrance":"15/02/20201"

                   },
                    {
                       "District":"ANTANANARIVO",
                       "Denomination":"société B",
                       "Siege":"Siege société B",
                       "NomCommerciale":"Nom commericale societe B",
                       "SiegeSocial":"Siège sociale societe B",
                       "LieuExploitation":"Lieu d'exploitation societe B",
                       "Mail":"mailsocietea@mailesia.com",
                       "Forme Juridique":"SARL",
                       "Contact":"320000152",
                       "Activites":"activite societe B",
                       "EmploiCree":"emploi1 de societe B",
                       "Secteur":"Primaire",
                       "CodeActivite":"Exploitation minière",
                       "RCS":"rcs societe 1",
                       "DateRCS":"14/02/2021",
                       "Statistique":"11223335588844",
                       "DateStatistique":"14/02/2021",
                       "NIF":"nif societe B",
                       "DateNIF":"14/02/2021",
                       "DateReception":"13/02/2021",
                       "DateDelivrance":"15/02/20201"

                   }
               ]
           }
       };
     
    json[] aggregatedResponse = cloneAndAggregate( payload_1, payload_2);
    var res3 = caller->respond(<@untainted> aggregatedResponse);              
    }
 
}

function cloneAndAggregate(json payload1,json payload2) returns json[] {
    fork {
        worker w1 returns json {
            
            return payload2;
        } worker w2 returns json {
            //return payload2;
        }
    }
    record{json w1; json w2;} results = wait {w1, w2};
    
    json[] aggregatedResponse = [results.w1, results.w2];
    return aggregatedResponse;
}
