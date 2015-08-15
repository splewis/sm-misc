#include <cstrike>
#include <sourcemod>

#include "include/common.inc"
#include "include/csgo_common.inc"

#pragma semicolon 1
#pragma newdecls required

bool g_ctUnpaused = false;
bool g_tUnpaused = false;

// TODO: also add a way to limit # of pausing

public Plugin myinfo = {
    name = "[CS:GO] Pause Commands",
    author = "splewis",
    description = "Adds simple pause/unpause commands for players",
    version = VERSION,
    url = "https://github.com/splewis/sm-misc"
};

public void OnPluginStart() {
    RegAdminCmd("sm_forcepause", Command_ForcePause, ADMFLAG_GENERIC, "Forces a pause");
    RegAdminCmd("sm_forceunpause", Command_ForceUnpause, ADMFLAG_GENERIC, "Forces an unpause");
    RegConsoleCmd("sm_pause", Command_Pause, "Requests a pause");
    RegConsoleCmd("sm_unpause", Command_Unpause, "Requests an unpause");
}

public void OnMapStart() {
    g_ctUnpaused = false;
    g_tUnpaused = false;
}

public Action Command_ForcePause(int client, int args) {
    if (IsPaused())
        return;

    ServerCommand("mp_pause_match");
    PrintToChatAll("%N has paused", client);
    LogMessage("%L force paused the game", client);
}

public Action Command_ForceUnpause(int client, int args) {
    if (!IsPaused())
        return;

    ServerCommand("mp_unpause_match");
    PrintToChatAll("%N has unpaused", client);
    LogMessage("%L force unpaused the game", client);
}

public Action Command_Pause(int client, int args) {
    if (IsPaused() || !IsValidClient(client))
        return;

    g_ctUnpaused = false;
    g_tUnpaused = false;

    ServerCommand("mp_pause_match");
    PrintToChatAll("%N has requested a pause.", client);
    LogMessage("%L requested a pause", client);
}

public Action Command_Unpause(int client, int args) {
    if (!IsPaused() || !IsValidClient(client))
        return;

    int team = GetClientTeam(client);
    if (team == CS_TEAM_T)
        g_tUnpaused = true;
    else if (team == CS_TEAM_CT)
        g_ctUnpaused = true;

    LogMessage("%L requested a unpause", client);

    if (g_tUnpaused && g_ctUnpaused)  {
        ServerCommand("mp_unpause_match");
        LogMessage("Unpausing the game", client);
    } else if (g_tUnpaused && !g_ctUnpaused) {
        PrintToChatAll("The T team wants to unpause. Waiting for the CT team to type \x05!unpause");
    } else if (!g_tUnpaused && g_ctUnpaused) {
        PrintToChatAll("The CT team wants to unpause. Waiting for the T team to type \x05!unpause");
    }
}
