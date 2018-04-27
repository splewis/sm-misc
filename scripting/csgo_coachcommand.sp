#include <cstrike>
#include <sdktools>
#include <smlib>
#include <sourcemod>

#include "include/csgo_common.inc"

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo = {
  name = "Coach command",
  author = "splewis",
  description = "",
  version = VERSION,
  url = "https://github.com/splewis/sm-misc"
}

public void OnPluginStart() {
}

public void OnClientSayCommand_Post(int client, const char[] command, const char[] sArgs) {
  if (StrEqual(sArgs, ".coach", false)) {
    int team = GetClientTeam(client);
    if (team == CS_TEAM_CT || team == CS_TEAM_T) {
      ChangeClientTeam(client, CS_TEAM_SPECTATOR);
      UpdateCoachTarget(client, team);
    } else {
      PrintToChat(client, "Join CT or T first, then type .coach again");
    }
  }
}
