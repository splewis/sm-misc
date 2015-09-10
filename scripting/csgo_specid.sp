#include <cstrike>
#include <sourcemod>

#include "include/common.inc"
#include "include/csgo_common.inc"

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo = {
    name = "[CS:GO] sm_specid",
    author = "splewis",
    description = "Displays the steamid of a client's spectator target",
    version = VERSION,
    url = "https://github.com/splewis/sm-misc"
};

public void OnPluginStart() {
    RegConsoleCmd("sm_specid", Command_SpecId, "Reports who you are currently spectating, including their steam id");
}

public Action Command_SpecId(int client, int args) {
    int target = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
    if (IsPlayer(target)) {
        ReplyToCommand(client, "Currently spectating target %L", target);
    } else {
        ReplyToCommand(client, "Not spectating a valid target");
    }
    return Plugin_Handled;
}
