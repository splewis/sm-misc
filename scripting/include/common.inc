#if defined _sm_misc_common_included_
  #endinput
#endif
#define _sm_misc_common_included_

#tryinclude "version.inc"
#if !defined VERSION
#define VERSION "1.0.0"
#endif

#define MAX_INTEGER_STRING_LENGTH 16
#define MAX_FLOAT_STRING_LENGTH 32

/**
 * Adds an integer to a menu as a string choice.
 */
stock void AddMenuInt(Menu menu, int value, const char[] display, any:...) {
    char formattedDisplay[128];
    VFormat(formattedDisplay, sizeof(formattedDisplay), display, 4);
    char buffer[MAX_INTEGER_STRING_LENGTH];
    IntToString(value, buffer, sizeof(buffer));
    menu.AddItem(buffer, formattedDisplay);
}

/**
 * Adds an integer to a menu, named by the integer itself.
 */
stock void AddMenuInt2(Menu menu, int value) {
    char buffer[MAX_INTEGER_STRING_LENGTH];
    IntToString(value, buffer, sizeof(buffer));
    menu.AddItem(buffer, buffer);
}

/**
 * Gets an integer to a menu from a string choice.
 */
stock int GetMenuInt(Menu menu, int param2) {
    char buffer[MAX_INTEGER_STRING_LENGTH];
    menu.GetItem(param2, buffer, sizeof(buffer));
    return StringToInt(buffer);
}

/**
 * Adds a boolean to a menu as a string choice.
 */
stock void AddMenuBool(Menu menu, bool value, const char[] display, any:...) {
    char formattedDisplay[128];
    VFormat(formattedDisplay, sizeof(formattedDisplay), display, 4);
    int convertedInt = value ? 1 : 0;
    AddMenuInt(menu, convertedInt, formattedDisplay);
}

/**
 * Gets a boolean to a menu from a string choice.
 */
stock bool GetMenuBool(Menu menu, int param2) {
    return GetMenuInt(menu, param2) != 0;
}

stock void ReplaceStringWithInt(char[] buffer, int len, const char[] replace, int value, bool caseSensitive=true) {
    char intString[MAX_INTEGER_STRING_LENGTH];
    IntToString(value, intString, sizeof(intString));
    ReplaceString(buffer, len, replace, intString, caseSensitive);
}
