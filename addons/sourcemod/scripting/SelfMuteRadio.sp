#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <clientprefs>
#include <multicolors>

#pragma newdecls required

Handle g_hSelfMuteRadioCookie = INVALID_HANDLE;

bool g_bSelfMuteRadioSound[MAXPLAYERS + 1] = {false, ...}, g_bSelfMuteRadioText[MAXPLAYERS + 1] = {false, ...};

bool g_bLate = false;

public Plugin myinfo =
{
	name			= "SelfMuteRadio",
	author			= "maxime1907, Nano, Kelyan3",
	description		= "Allows players to mute radio for themselves.",
	version			= "1.2.1",
	url				= ""
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	g_bLate = late;
	return APLRes_Success;
}

public void OnPluginStart()
{
	g_hSelfMuteRadioCookie = RegClientCookie("radio_mute_settings", "Radio mute settings (sound:text)", CookieAccess_Private);

	SetCookieMenuItem(CookieMenu_SelfMuteRadio, INVALID_HANDLE, "SelfMuteRadio Settings");

	UserMsg RadioText = GetUserMessageId("RadioText");
	UserMsg SendAudio = GetUserMessageId("SendAudio");

	if (RadioText == INVALID_MESSAGE_ID || SendAudio == INVALID_MESSAGE_ID)
	{
		SetFailState("This game doesnt support RadioText or SendAudio");
	}

	HookUserMessage(RadioText, Hook_UserMessageRadioText, true);
	HookUserMessage(SendAudio, Hook_UserMessageSendAudio, true);

	RegConsoleCmd("sm_smradio", Command_SelfMuteRadio, "Mute radio sounds and texts");

	// Late load
	if (!g_bLate)
		return;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientConnected(i) || IsFakeClient(i) || !AreClientCookiesCached(i))
			continue;

		ReadClientCookies(i);
	}

	g_bLate = false;
}

public void OnPluginEnd()
{
	Cleanup(true);
}

public void OnClientCookiesCached(int client)
{
	ReadClientCookies(client);
}

public void OnClientDisconnect(int client)
{
	g_bSelfMuteRadioSound[client] = false;
	g_bSelfMuteRadioText[client] = false;
}

//   .d8888b.   .d88888b.  888b     d888 888b     d888        d8888 888b    888 8888888b.   .d8888b.
//  d88P  Y88b d88P" "Y88b 8888b   d8888 8888b   d8888       d88888 8888b   888 888  "Y88b d88P  Y88b
//  888    888 888     888 88888b.d88888 88888b.d88888      d88P888 88888b  888 888    888 Y88b.
//  888        888     888 888Y88888P888 888Y88888P888     d88P 888 888Y88b 888 888    888  "Y888b.
//  888        888     888 888 Y888P 888 888 Y888P 888    d88P  888 888 Y88b888 888    888     "Y88b.
//  888    888 888     888 888  Y8P  888 888  Y8P  888   d88P   888 888  Y88888 888    888       "888
//  Y88b  d88P Y88b. .d88P 888   "   888 888   "   888  d8888888888 888   Y8888 888  .d88P Y88b  d88P
//   "Y8888P"   "Y88888P"  888       888 888       888 d88P     888 888    Y888 8888888P"   "Y8888P"
//

public Action Command_SelfMuteRadio(int client, int args)
{
	DisplayCookieMenu(client);
	return Plugin_Handled;
}

//  888b     d888 8888888888 888b    888 888     888
//  8888b   d8888 888        8888b   888 888     888
//  88888b.d88888 888        88888b  888 888     888
//  888Y88888P888 8888888    888Y88b 888 888     888
//  888 Y888P 888 888        888 Y88b888 888     888
//  888  Y8P  888 888        888  Y88888 888     888
//  888   "   888 888        888   Y8888 Y88b. .d88P
//  888       888 8888888888 888    Y888  "Y88888P"

public void DisplayCookieMenu(int client)
{
	Menu menu = new Menu(MenuHandler_SelfMuteRadio, MENU_ACTIONS_DEFAULT | MenuAction_DisplayItem);
	menu.ExitBackButton = true;
	menu.ExitButton = true;
	SetMenuTitle(menu, "SelfMuteRadio Settings");
	AddMenuItem(menu, NULL_STRING, "Radio sounds");
	AddMenuItem(menu, NULL_STRING, "Radio texts");
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public void CookieMenu_SelfMuteRadio(int client, CookieMenuAction action, any info, char[] buffer, int maxlen)
{
	switch(action)
	{
		case CookieMenuAction_SelectOption:
		{
			DisplayCookieMenu(client);
		}
	}
}

public int MenuHandler_SelfMuteRadio(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End:
		{
			if(param1 != MenuEnd_Selected)
				delete menu;
		}
		case MenuAction_Cancel:
		{
			if(param2 == MenuCancel_ExitBack)
				ShowCookieMenu(param1);
		}
		case MenuAction_Select:
		{
			switch(param2)
			{
				case 0:
				{
					g_bSelfMuteRadioSound[param1] = !g_bSelfMuteRadioSound[param1];
				}
				case 1:
				{
					g_bSelfMuteRadioText[param1] = !g_bSelfMuteRadioText[param1];
				}
				default: return 0;
			}
			SetClientCookies(param1);
			DisplayMenu(menu, param1, MENU_TIME_FOREVER);
		}
		case MenuAction_DisplayItem:
		{
			char sBuffer[32];
			switch(param2)
			{
				case 0:
				{
					Format(sBuffer, sizeof(sBuffer), "Radio sounds: %s", g_bSelfMuteRadioSound[param1] ? "Disabled" : "Enabled");
				}
				case 1:
				{
					Format(sBuffer, sizeof(sBuffer), "Radio texts: %s", g_bSelfMuteRadioText[param1] ? "Disabled" : "Enabled");
				}
				default: return 0;
			}
			return RedrawMenuItem(sBuffer);
		}
	}
	return 0;
}

// ##     ##  #######   #######  ##    ##  ######  
// ##     ## ##     ## ##     ## ##   ##  ##    ## 
// ##     ## ##     ## ##     ## ##  ##   ##       
// ######### ##     ## ##     ## #####     ######  
// ##     ## ##     ## ##     ## ##  ##         ## 
// ##     ## ##     ## ##     ## ##   ##  ##    ## 
// ##     ##  #######   #######  ##    ##  ######  

public Action Hook_UserMessageSendAudio(UserMsg msg_id, Handle bf, const int[] players, int playersNum, bool reliable, bool init)
{
	return HandleSelfMuteSound(bf, players, playersNum);
}

public Action Hook_UserMessageRadioText(UserMsg msg_id, Handle bf, const int[] players, int playersNum, bool reliable, bool init)
{
	return HandleSelfMuteText(bf, players, playersNum);
}

// ######## ##     ## ##    ##  ######  ######## ####  #######  ##    ##  ######  
// ##       ##     ## ###   ## ##    ##    ##     ##  ##     ## ###   ## ##    ## 
// ##       ##     ## ####  ## ##          ##     ##  ##     ## ####  ## ##       
// ######   ##     ## ## ## ## ##          ##     ##  ##     ## ## ## ##  ######  
// ##       ##     ## ##  #### ##          ##     ##  ##     ## ##  ####       ## 
// ##       ##     ## ##   ### ##    ##    ##     ##  ##     ## ##   ### ##    ## 
// ##        #######  ##    ##  ######     ##    ####  #######  ##    ##  ######

stock Action HandleSelfMuteSound(Handle bf, const int[] players, int playersNum)
{
	char sSound[128];
	BfReadString(bf, sSound, sizeof(sSound), false);

	if (StrContains(sSound, "Radio.", false) == -1)
		return Plugin_Continue;

	int[] newPlayers = new int[playersNum];
	int newPlayersNumSound = 0;

	for (int i = 0; i < playersNum; i++)
	{
		if (IsValidClient(players[i]) && !g_bSelfMuteRadioSound[players[i]])
		{
			newPlayers[newPlayersNumSound++] = players[i];
		}
	}

	EmitGameSound(newPlayers, newPlayersNumSound, sSound);

	return Plugin_Handled;
}

stock Action HandleSelfMuteText(Handle bf, const int[] players, int playersNum)
{
	int dest = BfReadByte(bf);
	int client = BfReadByte(bf);

	char sSoundType[128];
	BfReadString(bf, sSoundType, sizeof(sSoundType), false);

	if (StrContains(sSoundType, "Game_radio", false) == -1)
		return Plugin_Continue;

	char sSoundName[128];
	BfReadString(bf, sSoundName, sizeof(sSoundName), false);

	char sSoundFile[128];
	BfReadString(bf, sSoundFile, sizeof(sSoundFile), false);

	int[] newPlayers = new int[playersNum];
	int newPlayersNum = 0;

	for (int i = 0; i < playersNum; i++)
	{
		if (IsValidClient(players[i]) && !g_bSelfMuteRadioText[players[i]])
		{
			newPlayers[newPlayersNum++] = players[i];
		}
	}

	if (newPlayersNum == playersNum)
	{
		return Plugin_Continue;
	}
	else if (newPlayersNum == 0)
	{
		return Plugin_Handled;
	}

	DataPack pack = new DataPack();
	pack.WriteString(sSoundType);
	pack.WriteString(sSoundName);
	pack.WriteString(sSoundFile);
	pack.WriteCell(dest);
	pack.WriteCell(client);
	pack.WriteCell(newPlayersNum);

	for (int i = 0; i < newPlayersNum; i++)
	{
		pack.WriteCell(newPlayers[i]);
	}

	RequestFrame(RequestFrame_OnRadioText, pack);

	return Plugin_Handled;
}

public void RequestFrame_OnRadioText(DataPack pack)
{
	pack.Reset();

	char sSoundType[128];
	pack.ReadString(sSoundType, sizeof(sSoundType));

	char sSoundName[128];
	pack.ReadString(sSoundName, sizeof(sSoundName));

	char sSoundFile[128];
	pack.ReadString(sSoundFile, sizeof(sSoundFile));

	int dest = pack.ReadCell();
	int client = pack.ReadCell();
	int newPlayersNum = pack.ReadCell();

	int[] players = new int[newPlayersNum];
	int playersNum = 0;

	for(int i = 0; i < newPlayersNum; i++)
	{
		int player = pack.ReadCell();

		if(IsValidClient(player))
		{
			players[playersNum++] = player;
		}
	}

	CloseHandle(pack);

	Handle RadioText = StartMessage("RadioText", players, playersNum, USERMSG_RELIABLE | USERMSG_BLOCKHOOKS);

	if (RadioText != INVALID_HANDLE)
	{
		BfWriteByte(RadioText, dest);
		BfWriteByte(RadioText, client);
		BfWriteString(RadioText, sSoundType);
		BfWriteString(RadioText, sSoundName);
		BfWriteString(RadioText, sSoundFile);
	}

	EndMessage();
}

void Cleanup(bool bPluginEnd = false)
{
	if (bPluginEnd && g_hSelfMuteRadioCookie != INVALID_HANDLE)
		CloseHandle(g_hSelfMuteRadioCookie);
}

void ReadClientCookies(int client)
{
	char sBuffer[8];

	GetClientCookie(client, g_hSelfMuteRadioCookie, sBuffer, sizeof(sBuffer));

	if (strlen(sBuffer) >= 2)
	{
		g_bSelfMuteRadioSound[client] = (sBuffer[0] == '1');
		g_bSelfMuteRadioText[client] = (sBuffer[1] == '1');
	}
	else
	{
		g_bSelfMuteRadioSound[client] = false;
		g_bSelfMuteRadioText[client] = false;
	}
}

void SetClientCookies(int client)
{
	char sValue[8];

	// Use chained format "%d%d" where first digit is sound, second is text
	Format(sValue, sizeof(sValue), "%d%d", g_bSelfMuteRadioSound[client] ? 1 : 0, g_bSelfMuteRadioText[client] ? 1 : 0);
	SetClientCookie(client, g_hSelfMuteRadioCookie, sValue);
}

bool IsValidClient(int client, bool nobots = true)
{
	if (client <= 0 || client > MaxClients || !IsClientConnected(client) || (nobots && IsFakeClient(client)))
	{
		return false;
	}
	return IsClientInGame(client);
}
