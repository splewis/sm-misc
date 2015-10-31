#include <sourcemod>

#include "include/common.inc"

#pragma semicolon 1
#pragma newdecls required

ConVar g_PollTime;
ConVar g_MinRuntime;
ConVar g_RestartUpdateEnabled;

int g_InitTime = 0;
int g_MapInitTime = 0;

public Plugin myinfo = {
    name = "Server restarter",
    author = "splewis",
    description = "Periodically uses a _restart command when the server is empty",
    version = VERSION,
    url = "https://github.com/splewis/sm-misc"
};

public void OnPluginStart() {
    g_PollTime = CreateConVar("sm_restarter_poll_time", "60.0", "time, in seconds, between server-restart checks");
    g_MinRuntime = CreateConVar("sm_restarter_min_runtime", "14400", "minimum time, in seconds, the server must be running before it is eligible to be restarted");
    g_RestartUpdateEnabled = CreateConVar("sm_restart_restart_on_steamworks_update", "1", "Whether the plugin will autorestart the server when a game server update is found via the steamworks extension");
    AutoExecConfig();
    g_InitTime = GetTime();
    RegConsoleCmd("sm_uptime", Command_Uptime);
}

public void OnConfigsExecuted() {
    CreateTimer(g_PollTime.FloatValue, Timer_CheckServer, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

public void OnMapStart() {
    g_MapInitTime = GetTime();
}

public Action Timer_RestartServer(Handle timer) {
    RestartServer();
    return Plugin_Handled;
}

public void RestartServer() {
    LogMessage("Restarting the server");
    ServerCommand("_restart");
}

public Action Timer_CheckServer(Handle timer) {
    int map_dt = GetTime() - g_MapInitTime;
    int dt = GetTime() - g_InitTime;

    if (dt >= g_MinRuntime.IntValue && CountPlayers() == 0 && map_dt >= 60) {
        RestartServer();
    }

    return Plugin_Continue;
}

public int CountPlayers() {
    int count = 0;
    for (int i = 1; i <= MaxClients; i++) {
        if (IsPlayer(i))
            count++;
    }
    return count;
}

public bool IsPlayer(int client) {
    return IsClientConnected(client) && IsClientInGame(client) && !IsFakeClient(client);
}

public Action Command_Uptime(int client, int args) {
    int dt = GetTime() - g_InitTime;
    ReplyToCommand(client, "The server has been running for %.2f hours (%d seconds)", dt / 3600.0, dt);
    return Plugin_Handled;
}

public void SteamWorks_RestartRequested() {
    if (g_RestartUpdateEnabled.IntValue != 0) {
        LogMessage("SteamWorks_RestartRequested");
        PrintToChatAll("A game update has been found. \x04The server is being automatically updated and restarted.");
        CreateTimer(10.0, Timer_RestartServer);
    }
}
