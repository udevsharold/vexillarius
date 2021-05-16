//  Copyright (c) 2021 udevs
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.

#import "Common.h"
#import "Vexillarius.h"
#include <stdio.h>
#include <mach/mach.h>

const struct VXXPCKey VXKey =
{
    .timeout = "timeout",
    .identifier = "identifier",
    .type = "type",
    .icon = "icon",
    .title = "title",
    .subtitle = "subtitle",
    .leadingImageName = "leadingImageName",
    .leadingImagePath = "leadingImagePath",
    .trailingImageName = "trailingImageName",
    .trailingImagePath = "trailingImagePath",
    .trailingText = "trailingText",
    .backgroundColor = "backgroundColor"
};

const struct VXBSUIXPCKey BSUIKey =
{
    .timeout = "BUISKeyBannerTimeout",
    .identifier = "BUISKeyIdentifier",
    .type = "BUISKeyType",
    .icon = "BUISKeyCCItemsIcon",
    .title = "BUISKeyCCText",
    .subtitle = "BUISKeyCCItemsText",
    .leadingImageName = "BUISKeyLAImageName",
    .leadingImagePath = "BUISKeyLAImagePath",
    .trailingImageName = "BUISKeyTAImageName",
    .trailingImagePath = "BUISKeyTAImagePath",
    .trailingText = "BUISKeyTAText",
    .backgroundColor = "BUISKeyBackgroundColor",
    .lowBatteryLevel = "BUISKeyLowBatteryLevel"
};



static xpc_connection_t btuisXPCConnection(){
    xpc_connection_t connection =
    xpc_connection_create_mach_service("com.apple.BluetoothUIService", NULL, 0);
    xpc_connection_set_event_handler(connection, ^(xpc_object_t event) {
    });
    xpc_connection_resume(connection);
    return connection;
}

static void sendBannerMessage(xpc_object_t message){
    xpc_connection_t btuisConnection = btuisXPCConnection();
    if (btuisConnection){
        xpc_connection_send_message(btuisConnection, message);
    }
}


static void handleXPCObject(xpc_object_t object) {
    xpc_object_t message = xpc_dictionary_create(NULL, NULL, 0);
    
    xpc_dictionary_set_double(message, BSUIKey.timeout, xpc_dictionary_get_double(object, VXKey.timeout)?:4.0);
    xpc_dictionary_set_string(message, BSUIKey.type, xpc_dictionary_get_string(object, VXKey.type)?:"BUISKeyArgType");
    
    const char* icon = xpc_dictionary_get_string(object, VXKey.icon);
    if (icon){
        xpc_dictionary_set_string(message, BSUIKey.icon, icon);
    }
    
    const char* identifier = xpc_dictionary_get_string(object, VXKey.identifier);
    if (identifier){
        xpc_dictionary_set_string(message, BSUIKey.identifier, identifier);
    }
    
    const char* title = xpc_dictionary_get_string(object, VXKey.title);
    if (title){
        xpc_dictionary_set_string(message, BSUIKey.title, title);
    }
    
    const char* subtitle = xpc_dictionary_get_string(object, VXKey.subtitle);
    if (subtitle){
        xpc_dictionary_set_string(message, BSUIKey.subtitle, subtitle);
    }
    
    const char* leadingImageName = xpc_dictionary_get_string(object, VXKey.leadingImageName);
    if (leadingImageName){
        xpc_dictionary_set_string(message, BSUIKey.leadingImageName, leadingImageName);
    }
    
    const char* leadingImagePath = xpc_dictionary_get_string(object, VXKey.leadingImagePath);
    if (leadingImagePath){
        xpc_dictionary_set_string(message, BSUIKey.leadingImagePath, leadingImagePath);
    }
    
    const char* trailingImageName = xpc_dictionary_get_string(object, VXKey.trailingImageName);
    if (trailingImageName){
        xpc_dictionary_set_string(message, BSUIKey.trailingImageName, trailingImageName);
    }
    
    const char* trailingImagePath = xpc_dictionary_get_string(object, VXKey.trailingImagePath);
    if (trailingImagePath){
        xpc_dictionary_set_string(message, BSUIKey.trailingImagePath, trailingImagePath);
    }
    
    const char* trailingText = xpc_dictionary_get_string(object, VXKey.trailingText);
    if (trailingText){
        xpc_dictionary_set_string(message, BSUIKey.trailingText, trailingText);
    }
    
    int64_t backgroundColor = xpc_dictionary_get_int64(object, VXKey.backgroundColor);
    if (backgroundColor != 0){
        xpc_dictionary_set_int64(message, BSUIKey.backgroundColor, backgroundColor);
    }
    
    /*
    double lowBatteryLevel = xpc_dictionary_get_double(object, VXKey.lowBatteryLevel);
    if (lowBatteryLevel){
        xpc_dictionary_set_double(message, BSUIKey.lowBatteryLevel, lowBatteryLevel);
    }
`   */

    sendBannerMessage(message);
}

static void vx_peer_event_handler(xpc_connection_t peer, xpc_object_t event){
    xpc_type_t type = xpc_get_type(event);
    if (type == XPC_TYPE_ERROR) {
        if (event == XPC_ERROR_CONNECTION_INVALID) {
            // The client process on the other end of the connection has either
            // crashed or cancelled the connection. After receiving this error,
            // the connection is in an invalid state, and you do not need to
            // call xpc_connection_cancel(). Just tear down any associated state
            // here.
        } else if (event == XPC_ERROR_TERMINATION_IMMINENT) {
            // Handle per-connection termination cleanup.
        }
    } else {
        assert(type == XPC_TYPE_DICTIONARY);
        handleXPCObject(event);
    }
}

static void vx_event_handler(xpc_connection_t peer){
    // By defaults, new connections will target the default dispatch concurrent queue.
    xpc_connection_set_event_handler(peer, ^(xpc_object_t event) {
        vx_peer_event_handler(peer, event);
    });
    
    // This will tell the connection to begin listening for events. If you
    // have some other initialization that must be done asynchronously, then
    // you can defer this call until after that initialization is done.
    xpc_connection_resume(peer);
}

int main(int argc, char *argv[], char *envp[]) {
    
    xpc_connection_t service = xpc_connection_create_mach_service("com.udevs.vexillarius", dispatch_get_main_queue(), XPC_CONNECTION_MACH_SERVICE_LISTENER);
    
    if (!service) {
        HBLogDebug(@"Failed to create mach service.");
        exit(EXIT_FAILURE);
    }
    
    xpc_connection_set_event_handler(service, ^(xpc_object_t connection) {
        vx_event_handler(connection);
    });
    
    xpc_connection_resume(service);
    dispatch_main();
    
    return EXIT_SUCCESS;
}
