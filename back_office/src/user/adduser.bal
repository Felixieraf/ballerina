import ballerina/http;
import ballerina/io;
import ballerina/lang.'int as langint;
import ballerina/lang.'float;
import ballerina/docker;
import ballerina/config;
import ballerina/stringutils;

var env_wso2=config:getAsString("host.wso2");
var env_keycloak=config:getAsString("host.keycloak");
var env_keycloak_edbm=config:getAsString("host.keycloakEdbmUri");
var env_keycloak_token=config:getAsString("host.keycloakTokenUri");

var idPersonne=0;

http:Client personEP= new(env_wso2+"/services/personne");
http:Client userKeycloakEP=new(env_keycloak+env_keycloak_edbm);

@docker:Config {
   name: "add_user"
 }
 @docker:CopyFiles {
    files: [{sourceFile: "./Ballerina.toml", target: "/home/ballerina/Ballerina.toml", isBallerinaConf: true}]
}
 service user on new http:Listener(7002) {


    @http:ResourceConfig {
        body: "payload"
    }
    resource function aggregate_add_user(http:Caller caller, http:Request req, json payload) {
        json[] aggregatedResponse = cloneAndAggregate(<map<json>>payload, personEP );
        var res3 = caller->respond(<@untainted> aggregatedResponse);
    }


    @http:ResourceConfig {
        body: "payload",
        methods: ["POST"]
    }
    resource function signup(http:Caller caller, http:Request request, json payload){
        json tokens = getAdminToken();
        string? token = tokens == null ? () : tokens.token.toString();
        json[] aggregatedResponse = cloneAndAggregate(<map<json>>payload, personEP, token);
        var res = caller->respond(<@untainted> aggregatedResponse);
    }
}

function cloneAndAggregate(map<json> payload, http:Client clientEP1, string? inputToken = ()) returns json[] {
    map<json> callerPayload = payload.clone();
    
     
    fork {
        worker w1 returns json {
            
            return invokeAllEndpoint(clientEP1,payload, inputToken);
        } 
    }
    record{json w1; } results = wait {w1};
    
    json[] aggregatedResponse = [results.w1];
    return aggregatedResponse;
}
// Invoke endpoint  add user in keycloak, Person add person and person adress
function invokeAllEndpoint(http:Client clientEPPerson,  json outboundPayload, string? inputToken = ()) returns @untainted json {
    json payload=outboundPayload;
    var  token= inputToken == () ? processString(payload.credential.token) : inputToken;
  // User's information for keycloak
    var firstName=processString(payload.userInformation.firstName);
    var lastName=processString(payload.userInformation.lastName);
    var email=processString(payload.userInformation.email);
    var enabled=processString(payload.userInformation?.enabled);
    var username=processString(payload.userInformation?.username);
    var groupID=processString(payload.userInformation.groupID);
     string userID="";
    http:Request request = new;    
    json payloadUser={
        "firstName":firstName,
        "lastName":lastName, 
        "email":email, 
        "enabled":enabled, 
        "username":username

    };

    request.setPayload(payloadUser);
    request.addHeader("Content-Type", "application/json");
    request.addHeader("Authorization", "Bearer "+token.toString());

    var inboundResponseUserKeycloak = userKeycloakEP->post("/users", request);
    if (inboundResponseUserKeycloak is http:Response) {
        io:print("ok",inboundResponseUserKeycloak);
        if(inboundResponseUserKeycloak.statusCode===201){
            io:print("inboundResponseUserKeycloak.statusCode",inboundResponseUserKeycloak.statusCode);
            string header=inboundResponseUserKeycloak.getHeader("Location") ;
            string regex=env_keycloak+"/auth/admin/realms/EDBM/users/";
            
            userID=stringutils:replace(header,regex,"");
            
            http:Client userKeycloakGroupEP=new(header);

            var inboundResponseUserGroupKeycloak = userKeycloakGroupEP->put("/groups/"+groupID, request);
            if (inboundResponseUserGroupKeycloak is http:Response) {
                io:print("inboundResponseUserKeycloak.statusCode:",inboundResponseUserKeycloak.statusCode);
                if(inboundResponseUserKeycloak.statusCode===201)
                {
                    return invokePersonEP(clientEPPerson,outboundPayload,email,firstName,lastName,userID);
                    //return {message: "user added"};
                }                
                        
            }
        }

        return {message: "ERROR"};
    } 
}

function invokePersonEP(http:Client clientEPPerson,  json outboundPayload,string email,string firstName,string lastName,string userID)returns @untainted json
{   json payload=outboundPayload;
     // Adresse Personne setting outbound
    int idFokontany=process(payload.personInformation.adresse.idFokontany);
    var idCommune=process(payload.personInformation.adresse.idCommune);
    var idDistrict=process(payload.personInformation.adresse.idDistrict);
    var idProvince=process(payload.personInformation.adresse.idProvince);
    var idRegion=process(payload.personInformation.adresse.idRegion);
    var adresse=processString(payload.personInformation.adresse.adresse);
    var idArrondissement=process(payload.personInformation.adresse.idArrondissement);
    // Personne information

    //var idRole=process(payload.personInformation.personne.idRole);             
    var tel=processString(payload.personInformation.personne.tel);
    var e_mail=email;
    // var societe_mandataire=processString(payload.personInformation.personne.societe_mandataire); 
     
               
    json payloadAdress=     {
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
    var inboundResponsePersonAdress = clientEPPerson->post("/addAdressPerson", payloadAdress);
        if (inboundResponsePersonAdress is http:Response) {
            var inboundPayloadAdressId = inboundResponsePersonAdress.getJsonPayload();
                if (inboundPayloadAdressId is json) {
                    idAdressPerson=process(inboundPayloadAdressId.idAdresses.idAdresse);
                    io:println(idAdressPerson);
                    json payloadPerson= {
                                            "_postaddPersonOnOnlineForm": {
                                                
                                                        "nom": lastName,
                                                        "prenom": firstName,
                                                        "idAdresse":idAdressPerson,
                                                        "tel":tel,
                                                        "idRole":null,
                                                        "e_mail":e_mail,
                                                        "idUtilisateur":userID,
                                                        "societe_mandataire":null
                                            }
                                        };
                                        //CALL API ADD PERSON
                            var inboundResponsePerson = clientEPPerson->post("/addPersonOnOnlineForm", payloadPerson);
                            if (inboundResponsePerson is http:Response) {
                                var inboundPayloadPerson = inboundResponsePerson.getJsonPayload();
                                if (inboundPayloadPerson is json) {
                                    io:print(inboundPayloadPerson);
                                    idPersonne=process(inboundPayloadPerson.person_ids.person_id);
                                  
                                    return   {message:"person user added successfuly"};
                                } 
                            } 
                   



                    return {message:inboundPayloadAdressId};
                } 
                return {message:"error add Person"};
    }
    
                             



}

// get admin token
function getAdminToken() returns json {
    string tokenUri = env_keycloak+""+env_keycloak_token;
    http:Client tokenClient = new(tokenUri);
    string keycloakUser = config:getAsString("user.keycloak");
    string keycloakPassword = config:getAsString("user.password");
    string keycloakGrantType = config:getAsString("user.grantType");
    string keycloakClientId = config:getAsString("user.clientId");

    string[] keycloakRequestData=[
        "username=" + keycloakUser,
        "password=" + keycloakPassword,
        "grant_type=" + keycloakGrantType,
        "client_id=" + keycloakClientId
    ];

    string formData = joinData(keycloakRequestData, "&");

    http:Request request = new;
    request.setPayload(formData);
    request.setHeader("Content-Type","application/x-www-form-urlencoded");
    var response = tokenClient->post("/", request);

    if(response is http:Response) {
        var data = response.getJsonPayload();
        if(data is json){
            string token = processString(data.access_token);
            string refreshToken = processString(data.refresh_token);

            if(token == "no" || refreshToken == "no"){
                io:println("Error: An error occured while accessing keycloak auth token :(");
                return null;
            }

            return {
                token,
                refreshToken
            };
        }
        io:println("Error: 'data' token is not json type :(");
        return null;
    }

    io:println("Error: 'response' token is not http:Response type :(");
    return null;
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
        return je.toString();
    } else {
        //io:println("Error on JSON access: ", je.detail()?.message);
        return "no";
    }
}

function joinData(any[] array, string separator) returns string {
    string result = "";
    int counter = 0;
    foreach any data in array {
        if (counter == (array.length() - 1)) {
            result += data.toString();
        } else {
            result += data.toString() + separator;
        }
        counter += 1;
    }
    return result;
}
