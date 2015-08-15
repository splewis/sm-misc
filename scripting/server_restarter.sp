#include <sourcemod>

#include "include/common.inc"

#pragma semicolon 1
#pragma newdecls required

ConVar g_PollTime;
ConVar g_MinRuntime;

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
    AutoExecConfig();
    g_InitTime = GetTime();
}

public void OnConfigsExecuted() {
    CreateTimer(g_PollTime.FloatValue, Timer_CheckServer, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

public void OnMapStart() {
    g_MapInitTime = GetTime();
}

public Action Timer_CheckServer(Handle timer) {
    int map_dt = GetTime() - g_MapInitTime;
    int dt = GetTime() - g_InitTime;

    if (dt >= g_MinRuntime.IntValue && CountPlayers() == 0 && map_dt >= 60) {
        LogMessage("Restarting the server");
        ServerCommand("_restart");
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
