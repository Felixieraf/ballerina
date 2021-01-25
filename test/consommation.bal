import ballerina/http;
import ballerina/io;

public function main() returns @tainted error? {

    http:Client clientEP = new ("http://127.0.0.1:8290/services");

    http:Response resp = check clientEP->post("/societe/addSocietyForm",{
     "_postaddaddSocietyForm":{
        "denominationSocial":"add from ballerina",
        "activitePrincipal":532,
        "formeJuridique":"SARL",
        "dateStatut":"2020-02-07",
        "capital":100000.00,  
        "activiteImportExport":1, 
        "activiteIndustrielCollecteur":1, 
        "objetSocial":"Sa test", 
        "activiteGrossiste":1, 
        "autreActiviteReglemente":1,
        "choixImposition":1, 
        "nombreAssociePersPhysique":2,
        "nombreAssociePersMorale":6, 
        "nombreDirigeant":3, 
        "idPersonne":4
     }
 });

    string payload = check resp.getTextPayload();

    io:println(payload);
}