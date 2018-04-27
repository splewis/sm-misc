#include <cstrike>
#include <sdktools>
#include <smlib>
#include <sourcemod>

#include "include/csgo_common.inc"

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo = {
  name = "Coach deadtalk fix",
  author = "splewis",
  description = "Makes it so players can hear their coach and his chat messages",
  version = VERSION,
  url = "https://github.com/splewis/sm-misc"
}

public void OnPluginStart() {
  HookEvent("round_start", Event_FixComms);
  HookEvent("player_death", Event_FixComms);
  HookEvent("switch_team", Event_FixComms);
  HookEvent("player_spawn", Event_FixComms);
  HookEvent("round_freeze_end", Event_FixComms);
  AddCommandListener(Command_FixComms, "coach");
  AddCommandListener(Command_FixComms, "jointeam");
}

public void OnMapStart() {
  FixComms();
}

public Action Command_FixComms(int client, const char[] command, int argc) {
  FixComms();
}

public void Event_FixComms(Event event, const char[] round, bool dontBroadcast) {
  CreateTimer(0.1, Timer_FixComms);
}

public Action Timer_FixComms(Handle timer) {
  FixComms();
}

public int GetTeam(int client) {
  int csTeam = GetClientTeam(client);
  if (csTeam == CS_TEAM_SPECTATOR) {
    if (IsClientCoaching(client)) {
      return GetCoachTeam(client);
    }
  }
  return csTeam;
}

public void FixComms() {
  // i = coach, j = player
  for (int i = 1; i <= MaxClients; i++) {
    if (IsPlayer(i) && IsClientCoaching(i)) {
      int team = GetCoachTeam(i);
      for (int j = 1; j <= MaxClients; j++) {
        if (i == j || !IsPlayer(j)) {
          continue;
        }

        // same team
        if (GetTeam(j) == team) {
          if (IsPlayerAlive(j)) {
            SetListenOverride(i, j, Listen_Default);
            SetListenOverride(j, i, Listen_Default);
          } else {
            SetListenOverride(i, j, Listen_Yes);
            SetListenOverride(j, i, Listen_Yes);
          }

        // Diff team
        } else {
          if (IsPlayerAlive(j)) {
            SetListenOverride(i, j, Listen_Default);
            SetListenOverride(j, i, Listen_Default);
          } else {
            SetListenOverride(i, j, Listen_Default);
            SetListenOverride(j, i, Listen_Default);
          }
        }
      }
    }
  }
}

public Action OnClientSayCommand(int client, const char[] command, const char[] sArgs) {
  if (IsPlayer(client) && IsClientCoaching(client) && StrEqual(command, "say_team")) {
    int team = GetCoachTeam(client);
    for (int i = 1; i <= MaxClients; i++) {
      if (client != i && IsPlayer(i) && GetClientTeam(i) == team && !IsPlayerAlive(i)) {
        // We could try sending a user message here and it might look more natural ingame.
        // This works well enough, though.
        if (team == CS_TEAM_CT) {
          PrintToChat(i, "   \x0B(Counter-Terrorist) %N: \x01%s", client, sArgs);
        } else {
          PrintToChat(i, "   \x05(Terrorist) %N: \x01%s", client, sArgs);
        }
      }
    }
  }
  return Plugin_Continue;
}
