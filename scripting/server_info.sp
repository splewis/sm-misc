#include <sourcemod>
#include <smlib>

#include "include/common.inc"

#undef REQUIRE_EXTENSIONS
#include <SteamWorks>

#pragma semicolon 1
#pragma newdecls required

ConVar g_PasswordCvar;

public Plugin myinfo = {
    name = "Server !info",
    author = "splewis",
    description = "Adds sm_info command to get copy-pastable ip:port; password",
    version = VERSION,
    url = "https://github.com/splewis/sm-misc"
}

public void OnPluginStart() {
    RegConsoleCmd("sm_info", Command_Info, "Replies with the server ip:port and password");
    g_PasswordCvar = FindConVar("sv_password");
}

public Action Command_Info(int client, int args) {
    char ipString[64];
    if (GetFeatureStatus(FeatureType_Native, "SteamWorks_GetPublicIP") == FeatureStatus_Available) {
        int ipaddr[4];
        SteamWorks_GetPublicIP(ipaddr);
        Format(ipString, sizeof(ipString), "%d.%d.%d.%d",
            ipaddr[0], ipaddr[1], ipaddr[2], ipaddr[3]);

    } else {
        Server_GetIPString(ipString, sizeof(ipString));
    }

    char server[64];
    Format(server, sizeof(server), "%s:%d", ipString, Server_GetPort());

    if (g_PasswordCvar == null) {
        ReplyToCommand(client, "connect %s", server);
    } else {
        char password[64];
        g_PasswordCvar.GetString(password, sizeof(password));
        if (StrEqual(password, "")) {
            ReplyToCommand(client, "connect %s", server);
        } else {
            ReplyToCommand(client, "connect %s; password %s", server, password);
        }
    }

    return Plugin_Handled;
}
