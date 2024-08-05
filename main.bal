import ballerinax/trigger.asgardeo;
import ballerina/log;
import ballerina/http;

configurable asgardeo:ListenerConfig config = ?;

configurable string googleToken = ?;

listener http:Listener httpListener = new(8090);
listener asgardeo:Listener webhookListener =  new(config,httpListener);

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
        
    }

    remote function onConfirmSelfSignup(asgardeo:GenericEvent event ) returns error? {

        log:printInfo(event.toJsonString());
    }

    remote function onAcceptUserInvite(asgardeo:GenericEvent event ) returns error? {

        log:printInfo(event.toJsonString());
    }
}

service /ignore on httpListener {}

