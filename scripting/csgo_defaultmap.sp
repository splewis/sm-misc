#include <cstrike>
#include <sourcemod>

#include "include/common.inc"
#include "include/csgo_common.inc"

#pragma semicolon 1
#pragma newdecls required

#define DATA_FILE "data/defaultmap.txt"
#define DEFAULT_MAP "de_dust2"

bool g_DoneMapChange;
char g_DefaultMap[PLATFORM_MAX_PATH];

public Plugin myinfo = {
    name = "[CS:GO] Default map setter",
    author = "splewis",
    description = "Overrides the server's startup default map and adds command sm_defaultmap",
    version = VERSION,
    url = "https://github.com/splewis/sm-misc"
};

public void OnPluginStart() {
    g_DoneMapChange = false;
    RegAdminCmd("sm_defaultmap", Command_SetDefaultMap, ADMFLAG_CHANGEMAP);
    ReadDefaultMap();
}

public void OnMapStart() {
    if (!g_DoneMapChange) {
        char mapName[PLATFORM_MAX_PATH];
        GetCurrentMap(mapName, sizeof(mapName));
        if (!StrEqual(mapName, g_DefaultMap, false)) {
            // TODO: there's probably a better way of doing this.
            // The problem is that OnMapStart is usually called twice before the real start map
            // first on de_dust, then on the real startup default map, so checking the first
            // OnMapStart is unreliable.
            CreateTimer(10.0, Timer_ChangeToDefaultMap);
        }
        g_DoneMapChange = true;
    }
}

public Action Timer_ChangeToDefaultMap(Handle timer) {
    LogMessage("Changing to default map of %s", g_DefaultMap);
    ServerCommand("changelevel %s", g_DefaultMap);
}

public void ReadDefaultMap() {
    char path[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, path, sizeof(path), DATA_FILE);
    Handle file = OpenFile(path, "r");
    if (file == INVALID_HANDLE) {
        LogMessage("Failed to find default map file (%s)", path);
        g_DefaultMap = "de_dust2";
        WriteDefaultMap("de_dust2");
    } else {
        if (IsEndOfFile(file) || !ReadFileLine(file, g_DefaultMap, sizeof(g_DefaultMap))) {
            LogMessage("Failed to read default map file (%s)", path);
            WriteDefaultMap("de_dust2");
            g_DefaultMap = "de_dust2";
        }
        TrimString(g_DefaultMap);
        CloseHandle(file);
    }
}

public void WriteDefaultMap(const char[] map) {
    strcopy(g_DefaultMap, sizeof(g_DefaultMap), map);
    char path[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, path, sizeof(path), DATA_FILE);
    Handle file = OpenFile(path, "w");
    if (file == INVALID_HANDLE) {
        LogError("Failed to write out default map file (%s)", path);
    } else {
        WriteFileLine(file, map);
        CloseHandle(file);
    }
}

public Action Command_SetDefaultMap(int client, int args) {
    char arg1[64];
    if (args >= 1 && GetCmdArg(1, arg1, sizeof(arg1))) {
        WriteDefaultMap(arg1);
        ReplyToCommand(client, "The default map has been set to %s", arg1);
    } else {
        ReplyToCommand(client, "The current default map is %s", g_DefaultMap);
    }
}
