

function cloneAndAggregate(json payload, http:Client clientEP1, http:Client clientEP2) returns json[] {
    json callerPayload = payload.clone();
    
    fork {
        worker w1 returns json {
            payload.endpoint1 = "endpoint1Value";
            return invokeEndpoint(clientEP1, payload);
        } worker w2 returns json {
            callerPayload.endpoint2 = "endpoint2Value";
            return invokeEndpoint(clientEP2, callerPayload);
        }
    }
    record{json w1; json w2;} results = wait {w1, w2};
    
    json[] aggregatedResponse = [results.w1, results.w2];
    return aggregatedResponse;
}