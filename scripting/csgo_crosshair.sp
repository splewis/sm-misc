#include <cstrike>
#include <sourcemod>

#include "include/common.inc"
#include "include/csgo_common.inc"

#pragma semicolon 1
#pragma newdecls required

char kClientCrosshairCvars[][] = {
    "cl_crosshair_drawoutline",
    "cl_crosshair_outlinethickness",
    "cl_crosshaircolor",
    "cl_crosshaircolor",
    "cl_crosshaircolor_b",
    "cl_crosshaircolor_g",
    "cl_crosshaircolor_r",
    "cl_crosshairdot",
    "cl_crosshairgap",
    "cl_crosshairsize",
    "cl_crosshairstyle",
    "cl_crosshairthickness",
    "cl_fixedcrosshairgap",
};
const int kNumClientCrosshairCvars = sizeof(kClientCrosshairCvars);

const int kMaxCvarValueLength = 32;
char g_OriginalClientCvarValues[MAXPLAYERS+1][kNumClientCrosshairCvars][kMaxCvarValueLength]; // values taken from on-connect to restore
char g_CurrentClientCvarValues[MAXPLAYERS+1][kNumClientCrosshairCvars][kMaxCvarValueLength]; // values updated as needed

const float kTimeBetweenUpdates = 5.0;  // time interval, in seconds, between when client crosshairs are updated

public Plugin myinfo = {
    name = "[CS:GO] Crosshair Viewer",
    author = "splewis",
    description = "",
    version = VERSION,
    url = "https://github.com/splewis/sm-misc"
};

public void OnPluginStart() {
    LoadTranslations("common.phrases");
    RegConsoleCmd("sm_crosshair", Command_Crosshair);
    RegConsoleCmd("sm_undo", Command_Undo);
    CreateTimer(kTimeBetweenUpdates, Timer_UpdateCrosshairs, _, TIMER_REPEAT);
}

public Action Timer_UpdateCrosshairs(Handle timer) {
    for (int i = 1; i <= MaxClients; i++) {
        if (IsClientConnected(i) && IsClientInGame(i) && !IsFakeClient(i)) {
            UpdateClientSettings(i, false);
        }
    }
    return Plugin_Continue;
}

public void OnClientPutInServer(int client) {
    if (client > 0 && IsClientConnected(client) && IsClientInGame(client) && !IsFakeClient(client)) {
        UpdateClientSettings(client, true);
    }
}

public Action Command_Crosshair(int client, int args) {
    if (args >= 1) {
        char arg[32];
        GetCmdArg(1, arg, sizeof(arg));
        int target = FindTarget(client, arg, true, false);
        if (target >= 1 && IsClientConnected(target) && IsClientInGame(target) && !IsFakeClient(target)) {
            PrintCrosshairSettings(client, target);
        }
    } else {
        PrintCrosshairSettings(client, client, true);
    }
}

public Action Command_Undo(int client, int args) {
    PrintCrosshairSettings(client, client, true);
}

stock void PrintCrosshairSettings(int client, int target, bool original=false) {
    PrintToChat(client, "View console for output");

    if (original) {
        PrintToConsole(client, "Your original crosshair:");
    } else {
        PrintToConsole(client, "Crosshair settings from %N:", target);
    }

    for (int i = 0; i < kNumClientCrosshairCvars; i++) {
        if (original) {
            PrintToConsole(client, "%s %s;",
                kClientCrosshairCvars[i],
                g_OriginalClientCvarValues[target][i]);
        } else {
            PrintToConsole(client, "%s %s;",
                kClientCrosshairCvars[i],
                g_CurrentClientCvarValues[target][i]);
        }
    }
}

stock void UpdateClientSettings(int client, bool savingOriginal=false) {
    for (int i = 0; i < sizeof(kClientCrosshairCvars); i++) {
        QueryClientConVar(client, kClientCrosshairCvars[i], QueryClientCvar, savingOriginal);
    }
}

public int GetCvarIndex(const char[] cvar) {
    for (int i = 0; i < kNumClientCrosshairCvars; i++) {
        if (StrEqual(cvar, kClientCrosshairCvars[i], false)) {
            return i;
        }
    }
    return -1;
}

public void QueryClientCvar(QueryCookie cookie, int client, ConVarQueryResult result,
                            const char[] cvarName, const char[] cvarValue, int savingOriginal) {
    int index = GetCvarIndex(cvarName);
    if (index < 0) {
        LogError("Failed to find cvar index for %s", cvarName);
        return;
    }

    if (savingOriginal) {
        strcopy(g_OriginalClientCvarValues[client][index], kMaxCvarValueLength, cvarValue);
    }

    strcopy(g_CurrentClientCvarValues[client][index], kMaxCvarValueLength, cvarValue);
}
