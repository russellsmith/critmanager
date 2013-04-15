#pragma semicolon 1
#include <sourcemod>

#define PL_NAME "Crit/Spread Manager"
#define PL_DESC "Crit/Spread management plugin"
#define PL_VERSION "0.05"

public Plugin:myinfo = 
{
	name = PL_NAME,
	author = "Velsk",
	description = PL_DESC,
	version = PL_VERSION,
	url = "http://tinylittlerobots.us"
}

new Handle:g_Cvar_UpperThreshold = INVALID_HANDLE;
new Handle:g_Cvar_LowerThreshold = INVALID_HANDLE;
//new Handle:g_Cvar_ToggleBehavior = INVALID_HANDLE;
new Handle:g_Cvar_Enabled = INVALID_HANDLE;
new Handle:g_Cvar_ToggleWeaponSpread = INVALID_HANDLE;
new Handle:g_Cvar_ToggleDamageSpread = INVALID_HANDLE;
new Handle:g_Cvar_ToggleCrits = INVALID_HANDLE;
new Handle:g_Cvar_WeaponSpread = INVALID_HANDLE;
new Handle:g_Cvar_DamageSpread = INVALID_HANDLE;
new Handle:g_Cvar_Crits = INVALID_HANDLE;
new g_iNumPlayers = 0;
new bool:g_bEnabled = true;

public OnPluginStart()
{
	g_Cvar_UpperThreshold = CreateConVar("sm_cm_upperthreshold", "18", "Sets the threshold at which crits/spread are disabled.");
	g_Cvar_LowerThreshold = CreateConVar("sm_cm_lowerthreshold", "2", "Sets the threshold at which crits/spread are enabled.");
	g_Cvar_Enabled = CreateConVar("sm_cm_enabled", "1", "Enable/Disable the plugin");
	g_Cvar_ToggleWeaponSpread = CreateConVar("sm_cm_weaponspread", "1", "Manage weapon spread?");
	g_Cvar_ToggleDamageSpread = CreateConVar("sm_cm_damagespread", "1", "Manage damage spread?");
	g_Cvar_ToggleCrits = CreateConVar("sm_cm_crits", "1", "Manage crits?");

	g_Cvar_WeaponSpread = FindConVar("tf_use_fixed_weaponspreads");
	g_Cvar_DamageSpread = FindConVar("tf_damage_disablespread");
	g_Cvar_Crits = FindConVar("tf_weapon_criticals");

	AutoExecConfig(true, "plugin.critmanager");
	g_iNumPlayers = GetRealClientCount();
}

public OnConfigsExecuted()
{
	InitState();
}

public OnMapStart()
{
	AutoExecConfig(true, "plugin.critmanager");
}

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	if(late)
	{
		CreateTimer(1.0, Timer_Load);
	}

	return APLRes_Success;
}

public Action:Timer_Load(Handle:timer)
{
	InitState();
}

public InitState()
{
	g_iNumPlayers = GetRealClientCount();
	if(g_iNumPlayers >= GetConVarInt(g_Cvar_UpperThreshold))
		ToggleState(false);
	else
		ToggleState(true);
}


public OnClientPostAdminCheck(client)
{
	if(IsFakeClient(client))
	{
		return;
	}
	g_iNumPlayers = GetRealClientCount();
	if(g_iNumPlayers >= GetConVarInt(g_Cvar_UpperThreshold) && g_bEnabled && GetConVarBool(g_Cvar_Enabled))
	{
		ToggleState(false);
	}
}

public OnClientDisconnect(client)
{
	if(IsFakeClient(client))
	{
		return;
	}
	g_iNumPlayers = GetRealClientCount();
	if(g_iNumPlayers <= GetConVarInt(g_Cvar_LowerThreshold) && !g_bEnabled  && GetConVarBool(g_Cvar_Enabled))
	{
		ToggleState(true);
	}
}

public ToggleState(bool:enable)
{
	decl String:file[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, file, sizeof(file), "logs/critmanager.log");
	if(enable)
	{
		// Do something
		if(GetConVarBool(g_Cvar_ToggleWeaponSpread))
			SetConVarInt(g_Cvar_WeaponSpread, 0);
		if(GetConVarBool(g_Cvar_ToggleDamageSpread))
			SetConVarInt(g_Cvar_DamageSpread, 0);
		if(GetConVarBool(g_Cvar_ToggleCrits))
			SetConVarInt(g_Cvar_Crits, 1);

		g_bEnabled = true;
		
		LogToFile(file, "[CM] Crits enabled with %i players", g_iNumPlayers);
		PrintToChatAll("\x01\x04[SM] Random crits/spread \x01enabled \x04due to player threshold.");
	}
	else
	{
		// Do something else
		if(GetConVarBool(g_Cvar_ToggleWeaponSpread))
			SetConVarInt(g_Cvar_WeaponSpread, 1);
		if(GetConVarBool(g_Cvar_ToggleDamageSpread))
			SetConVarInt(g_Cvar_DamageSpread, 1);
		if(GetConVarBool(g_Cvar_ToggleCrits))
			SetConVarInt(g_Cvar_Crits, 0);

		g_bEnabled = false;
		LogToFile(file, "[CM] Crits disabled with %i players", g_iNumPlayers);
		PrintToChatAll("\x01\x04[SM] Random crits/spread \x01disabled \x04due to player threshold.");
	}
}

stock GetRealClientCount( bool:inGameOnly = true ) {
 	new clients = 0;
 	for( new i = 1; i <= GetMaxClients(); i++ ) {
		if( ( ( inGameOnly ) ? IsClientInGame( i ) : IsClientConnected( i ) ) && !IsFakeClient( i ) ) {
 			++clients;
 		}
 	}
 	return clients;
 }