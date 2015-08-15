#include <sourcemod>
#include <smlib>

#include "include/common.inc"

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
    char ip[64];
    Server_GetIPString(ip, sizeof(ip));

    char server[64];
    Format(server, sizeof(server), "%s:%d", ip, Server_GetPort());

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
}
