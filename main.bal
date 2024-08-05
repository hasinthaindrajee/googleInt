import ballerinax/trigger.asgardeo;
import ballerina/log;
import ballerina/http;

configurable asgardeo:ListenerConfig config = ?;

configurable string googleToken = ?;

final string BASE_URL = "https://admin.googleapis.com/admin/directory/v1";

// Load the access token from config.toml

listener http:Listener httpListener = new(8090);
listener asgardeo:Listener webhookListener =  new(config,httpListener);
// Load the access token from config.toml

http:Client googleClient = check new ("https://admin.googleapis.com/admin/directory/v1",
        auth = {
            token: googleToken
        }
    );

service asgardeo:RegistrationService on webhookListener {

    remote function onAddUser(asgardeo:AddUserEvent event ) returns error? {

        string username =  event.eventData?.userName ?: "dummyvalue";
        string firstname = event.eventData?.claims["http://wso2.org/claims/givenname"] ?: "dummyvalue";
        string lastname = event.eventData?.claims["http://wso2.org/claims/lastname"] ?: "dummyvalue";

        log:printInfo("This is modified code");
        log:printInfo(username);
        log:printInfo(firstname);
        log:printInfo(lastname);
        log:printInfo(googleToken);

         json user = {
            "name": {
                "givenName": firstname,
                "familyName": lastname
            },
            "password": "Hasintha@123",
            "primaryEmail": username
        };

        http:Response|error response = googleClient->post("/users", user);
        if (response is error) {
            log:printError("Failed to provision user", response);
            return;
        }

        json|error result = response.getJsonPayload();
        if (result is error) {
            log:printError("Failed to parse response", result);
            return;
        } else {
            log:printInfo(result.toJsonString());
        }
        
    }

    remote function onConfirmSelfSignup(asgardeo:GenericEvent event ) returns error? {

        log:printInfo(event.toJsonString());
    }

    remote function onAcceptUserInvite(asgardeo:GenericEvent event ) returns error? {

        log:printInfo(event.toJsonString());
    }
}


service /ignore on httpListener {}

