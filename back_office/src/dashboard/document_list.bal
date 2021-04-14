
import ballerina/http;
import ballerina/docker;
import ballerina/io;
import ballerina/lang.'int as langint;





http:Client EP_DOSSIER =new("http://127.0.0.1:8290/services/dossierSoumission");
http:Client EP_SOCIETY= new("http://127.0.0.1:8290/services/societe");
http:Client EP_PERSON= new("http://127.0.0.1:8290/services/personne");
@docker:Config {
   name: "get_folder_list"
 }

service get_list_dossier on new http:Listener(7004) {


    @http:ResourceConfig {
         methods: ["GET"]
     
    }
    resource function folder_list(http:Caller caller, http:Request req) {

        var _limit= <@untainted>req.getQueryParamValue("limit");
        var _offset= <@untainted>req.getQueryParamValue("offset");
        var _tri=<@untainted>req.getQueryParamValue("tri");
        int _endValue=<int>langint:fromString(_limit.toString());
        int _triValue=<int>langint:fromString(_tri.toString());
        json [] folder_list=[];
        http:Request request = new;
        request.addHeader("Accept", "application/json");
        json folder={};
             if(_triValue==1){

                                var inboundResponseFolder = EP_DOSSIER->get("/getListFolderASC?offset="+_offset.toString()+"&limit="+_limit.toString(),request);
                                if(inboundResponseFolder is http:Response){

                                
                                var inboundPayloadFolder = inboundResponseFolder.getJsonPayload();
                                
                                if (inboundPayloadFolder is json) {
                                   // folder=inboundPayloadFolder;
                                    //var obj = JSON.parse(inboundPayloadFolder);
                                    json []resp=json_process(inboundPayloadFolder.folders.folder);
                                    json[] j2 = <json[]>resp;
                                    if (_endValue>j2.length())
                                    {
                                              _endValue=j2.length();
                                    }
                                      
            

                                    foreach var i in 0 ..< _endValue {
                                                                  //io:print(i.toString()+" "+j2[i].idDossier.toString()+" ");
                                                                  var idDossier=j2[i].idDossier;
                                                                  var idSociete=0;
                                                                  var idPersonne=0;
                                                                  var company_name="";
                                                                  json societe={};
                                                                  json rdv={};
                                                                  json dossier={"idDossier":j2[i].idDossier.toString(),"numeroDossier":j2[i].numeroDossier.toString(),"dateSoumission":j2[i].dateSoumission.toString(),"statutDossier":j2[i].idStatutDossier.toString(),"statutDepot":j2[i].idStatutDepot.toString()};

                                                                  var inboundResponseSociety = EP_SOCIETY->get("/getSocietyByFolderId?idDossier="+idDossier.toString(), request);
                                                                                                                if (inboundResponseSociety is http:Response) {
                                                                                                                  
                                                                                                                    var inboundPayloadSociety = inboundResponseSociety.getJsonPayload();
                                                                                                                      //io:print("status",inboundPayloadSociety);
                                                                                                                    if (inboundPayloadSociety is json) {
                                                                                                                          //society=inboundPayloadSociety;
                                                                                                                          idSociete=int_process(inboundPayloadSociety.societies.society.idSociete);
                                                                                                                          idPersonne=int_process(inboundPayloadSociety.societies.society.idPersonne);
                                                                                                                          company_name=string_process(inboundPayloadSociety.societies.society.denominationSocial);
                                                                                                                            societe={"idSociete":idSociete,"company_name":company_name};

                                                                                                                    } 
                                                                                                                   
                                                                                                                } 
                                                                var inboundRdv = EP_DOSSIER->get("/getListRdv?idDossier="+idDossier.toString(), request);
                                                                if (inboundRdv is http:Response) {
                                                                    var inboundPayloadRdv = inboundRdv.getJsonPayload();
                                                                    if (inboundPayloadRdv is json) {
                                                                           
                                                                           rdv=inboundPayloadRdv;

                                                                    } 
                                                                    
                                                                } 



                                                                json person={};
                                                                
                                                                var inboundResponsePerson = EP_PERSON->get("/getPersonInformationByPersonId?idPersonne="+idPersonne.toString(), request);
                                                                                    if (inboundResponsePerson is http:Response) {
                                                                                        var inboundPayloadPerson = inboundResponsePerson.getJsonPayload();
                                                                                        // io:print("status",inboundPayloadPerson);
                                                                                        if (inboundPayloadPerson is json) {
                                                                                            person=inboundPayloadPerson;
                                                                                        
                                                                                        } 
                                                                                        //io:print("error when fetching person");
                                                                                    } 
                                                                                    folder_list[i]={"dossier":dossier,"societe":societe,"personne":person,"rdv":rdv};
                                                                }
                                                                                                                                                    
                                                                                        
                                
                            
                            } 
                            
                            }
                                }
                                else
                                {
                              var inboundResponseFolder =EP_DOSSIER->get("/getListFolderDESC?offset="+_offset.toString()+"&limit="+_limit.toString(),request);               
                              if(inboundResponseFolder is http:Response)
                              {

                              
                              var inboundPayloadFolder = inboundResponseFolder.getJsonPayload();
                                
                                if (inboundPayloadFolder is json) {
                                   // folder=inboundPayloadFolder;
                                    //var obj = JSON.parse(inboundPayloadFolder);
                                    json []resp=json_process(inboundPayloadFolder.folders.folder);
                                    json[] j2 = <json[]>resp;
                                    if (_endValue>j2.length())
                                    {
                                              _endValue=j2.length();
                                    }
                                      
            

                                    foreach var i in 0 ..< _endValue {
                                                                  //io:print(i.toString()+" "+j2[i].idDossier.toString()+" ");
                                                                  var idDossier=j2[i].idDossier;
                                                                  var idSociete=0;
                                                                  var idPersonne=0;
                                                                  var company_name="";
                                                                  json societe={};
                                                                  json dossier={"idDossier":j2[i].idDossier.toString(),"numeroDossier":j2[i].numeroDossier.toString(),"dateSoumission":j2[i].dateSoumission.toString(),"statutDossier":j2[i].idStatutDossier.toString()};

                                                                  var inboundResponseSociety = EP_SOCIETY->get("/getSocietyByFolderId?idDossier="+idDossier.toString(), request);
                                                                                                                if (inboundResponseSociety is http:Response) {
                                                                                                                  
                                                                                                                    var inboundPayloadSociety = inboundResponseSociety.getJsonPayload();
                                                                                                                      //io:print("status",inboundPayloadSociety);
                                                                                                                    if (inboundPayloadSociety is json) {
                                                                                                                          //society=inboundPayloadSociety;
                                                                                                                          idSociete=int_process(inboundPayloadSociety.societies.society.idSociete);
                                                                                                                          idPersonne=int_process(inboundPayloadSociety.societies.society.idPersonne);
                                                                                                                          company_name=string_process(inboundPayloadSociety.societies.society.denominationSocial);
                                                                                                                            societe={"idSociete":idSociete,"company_name":company_name};

                                                                                                                    } 
                                                                                                                   
                                                                                                                } 



                                                                json person={};
                                                                
                                                                var inboundResponsePerson = EP_PERSON->get("/getPersonInformationByPersonId?idPersonne="+idPersonne.toString(), request);
                                                                                    if (inboundResponsePerson is http:Response) {
                                                                                        var inboundPayloadPerson = inboundResponsePerson.getJsonPayload();
                                                                                        // io:print("status",inboundPayloadPerson);
                                                                                        if (inboundPayloadPerson is json) {
                                                                                            person=inboundPayloadPerson;
                                                                                        
                                                                                        } 
                                                                                        //io:print("error when fetching person");
                                                                                    } 
                                                                                    folder_list[i]={"dossier":dossier,"societe":societe,"personne":person};
                                                                }
                                                                                                                                                    
                                                                                        
                                
                            
                            } 
                              }
                            }
       
    json [] aggregatedResponse = folder_list;
    io:print(aggregatedResponse);
    var res3 = caller->respond(<@untainted> aggregatedResponse);              
    }
 
}
function json_process(json|error  je) returns @untainted json[] {
    if (je is json[]) {
        // The type test needs to be used first, to use the resultant value
        // as a JSON value.
       // io:println("JSON value: ", je);
        return <json[]> je;
    } else {
        //io:println("Error on JSON access: ", je.detail()?.message);
        return [{"json":null}];
    }
}

function int_process(json|error je) returns @untainted int {
    if (je is json) {
        // The type test needs to be used first, to use the resultant value
        // as a JSON value.
        //io:println("JSON value: ", je);
        int|error val = langint:fromString(je.toString());
        return <int> val;
    } else {
        //io:println("Error on JSON access: ", je.detail()?.message);
        return 0;
    }
    }

    function string_process(json|error je) returns @untainted string {
    if (je is json) {
        // The type test needs to be used first, to use the resultant value
        // as a JSON value.
        io:println("JSON value: ", je);
        string|error val = je.toString();
        return <string> val;
    } else {
        //io:println("Error on JSON access: ", je.detail()?.message);
        return " ";
    }
    }