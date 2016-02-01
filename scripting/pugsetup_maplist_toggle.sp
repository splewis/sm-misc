#include <cstrike>
#include <sourcemod>
#include <pugsetup>

#include "include/common.inc"
#include "include/csgo_common.inc"

#pragma semicolon 1
#pragma newdecls required

ConVar g_MapListName1;
ConVar g_MapListName2;

public Plugin myinfo = {
    name = "[CS:GO] Pause Commands",
    author = "splewis",
    description = "Adds a maplist toggle for pugsetup's .setup menu",
    version = VERSION,
    url = "https://github.com/splewis/sm-misc"
};

public void OnPluginStart() {
    g_MapListName1 = CreateConVar("sm_pugsetup_maplist_option1", "maps.txt");
    g_MapListName2 = CreateConVar("sm_pugsetup_maplist_option2", "maps.txt");
    AutoExecConfig(true, "pugsetup_maplist_toggle", "sourcemod/pugsetup");
}

public Action PugSetup_OnSetupMenuOpen(int client, Menu menu, bool displayOnly) {
    char curMapList[255];
    ConVar maplist = FindConVar("sm_pugsetup_maplist");
    maplist.GetString(curMapList, sizeof(curMapList));

    char display[255];
    Format(display, sizeof(display), "Maplist: %s", curMapList);

    menu.AddItem("toggle_maplist", display);
}

public void PugSetup_OnSetupMenuSelect(Menu menu, int client, const char[] selected_info, int selected_position) {
    if (StrEqual(selected_info, "toggle_maplist")) {
        ToggleMapList();
        PugSetup_GiveSetupMenu(client, false, GetMenuSelectionPosition());
    }
}

public void ToggleMapList() {
    char curMapList[255];
    ConVar maplist = FindConVar("sm_pugsetup_maplist");
    maplist.GetString(curMapList, sizeof(curMapList));

    char option1List[255];
    char option2List[255];
    g_MapListName1.GetString(option1List, sizeof(option1List));
    g_MapListName2.GetString(option2List, sizeof(option2List));

    if (StrEqual(option1List, curMapList)) {
        maplist.SetString(option2List);
        PugSetup_MessageToAll("Updated maplist to %s", option2List);
    } else {
        maplist.SetString(option1List);
        PugSetup_MessageToAll("Updated maplist to %s", option1List);
    }

}
