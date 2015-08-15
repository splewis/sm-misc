#if defined _sm_misc_csgo_common_included_
  #endinput
#endif
#define _sm_misc_csgo_common_included_

#include <cstrike>
#include <sdktools>
#include "common.inc"

static char _colorNames[][] = {"{NORMAL}", "{DARK_RED}", "{PINK}", "{GREEN}", "{YELLOW}", "{LIGHT_GREEN}", "{LIGHT_RED}", "{GRAY}", "{ORANGE}", "{LIGHT_BLUE}", "{DARK_BLUE}", "{PURPLE}", "{RED}"};
static char _colorCodes[][] = {"\x01",     "\x02",      "\x03",   "\x04",         "\x05",     "\x06",          "\x07",        "\x08",   "\x09",     "\x0B",         "\x0C",        "\x0E",  "\x07"};

/**
 * Switches and respawns a player onto a new team.
 */
stock void SwitchPlayerTeam(int client, int team) {
    if (GetClientTeam(client) == team)
        return;

    if (team > CS_TEAM_SPECTATOR) {
        CS_SwitchTeam(client, team);
        CS_UpdateClientModel(client);
        CS_RespawnPlayer(client);
    } else {
        ChangeClientTeam(client, team);
    }
}

/**
 * Returns if a client is valid.
 */
stock bool IsValidClient(int client) {
    return client > 0 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client);
}

stock bool IsPlayer(int client) {
    return IsValidClient(client) && !IsFakeClient(client);
}

/**
 * Returns the number of clients that are actual players in the game.
 */
stock int GetRealClientCount() {
    int clients = 0;
    for (int i = 1; i <= MaxClients; i++) {
        if (IsPlayer(i)) {
            clients++;
        }
    }
    return clients;
}

stock void Colorize(char[] msg, int size, bool stripColor=false) {
    for (int i = 0; i < sizeof(_colorNames); i ++) {
        if (stripColor)
            ReplaceString(msg, size, _colorNames[i], "\x01"); // replace with white
        else
            ReplaceString(msg, size, _colorNames[i], _colorCodes[i]);
    }
}

stock void GetCleanMapName(char[] buffer, int size) {
    char mapName[PLATFORM_MAX_PATH];
    GetCurrentMap(mapName, sizeof(mapName));
    int last_slash = 0;
    int len = strlen(mapName);
    for (int i = 0;  i < len; i++) {
        if (mapName[i] == '/' || mapName[i] == '\\')
            last_slash = i + 1;
    }
    strcopy(buffer, size, mapName[last_slash]);
}


stock bool OnActiveTeam(int client) {
    if (!IsPlayer(client))
        return false;

    int team = GetClientTeam(client);
    return team == CS_TEAM_CT || team == CS_TEAM_T;
}

stock bool InWarmup() {
    return GameRules_GetProp("m_bWarmupPeriod") != 0;
}

stock void EndWarmup() {
    ServerCommand("mp_warmup_end");
}

stock bool IsPaused() {
    return GameRules_GetProp("m_bMatchWaitingForResume") != 0;
}

stock void Pause() {
    ServerCommand("mp_pause_match");
}

stock void Unpause() {
    ServerCommand("mp_unpause_match");
}

stock void RestartGame(int delay) {
    ServerCommand("mp_restartgame %d", delay);
}
