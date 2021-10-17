#include <sourcemod>
#include <tf2_stocks>

#pragma semicolon 1

#define PLUGIN_VERSION "1.10"

bool g_bTouched[MAXPLAYERS+1];
bool g_bMVM;
bool g_bLateLoad;
ConVar g_hCVTimer;
ConVar g_hCVEnabled;
ConVar g_hCVTeam;
Handle g_hWearableEquip;
Handle g_hGameConfig;

public Plugin myinfo = 
{
	name = "Give Bots Cosmetics",
	author = "SenpaiKisser",
	description = "Gives TF2 bots cosmetics",
	version = PLUGIN_VERSION,
	url = "https://github.com/SenpaiKisser/TF2-BOT-Cosmetics"
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) 
{
	if (GetEngineVersion() != Engine_TF2) 
	{
		Format(error, err_max, "This plugin only works for Team Fortress 2.");
		return APLRes_Failure;
	}
	
	g_bLateLoad = late;
	return APLRes_Success;
}

public void OnPluginStart() 
{
	ConVar hCVversioncvar = CreateConVar("sm_gbc_version", PLUGIN_VERSION, "Give Bots Cosmetics version cvar", FCVAR_NOTIFY|FCVAR_DONTRECORD); 
	g_hCVEnabled = CreateConVar("sm_gbc_enabled", "1", "Enables/disables this plugin", FCVAR_NONE, true, 0.0, true, 1.0);
	g_hCVTimer = CreateConVar("sm_gbc_delay", "0.1", "Delay for giving cosmetics to bots", FCVAR_NONE, true, 0.1, true, 30.0);
	g_hCVTeam = CreateConVar("sm_gbc_team", "1", "Team to give cosmetics to: 1-both, 2-red, 3-blu", FCVAR_NONE, true, 1.0, true, 3.0);

	HookEvent("post_inventory_application", player_inv);
	HookConVarChange(g_hCVEnabled, OnEnabledChanged);
	
	SetConVarString(hCVversioncvar, PLUGIN_VERSION);
	AutoExecConfig(true, "Give_Bots_Cosmetics");

	if (g_bLateLoad)
	{
		OnMapStart();
	}
	
	g_hGameConfig = LoadGameConfigFile("give.bots.cosmetics");
	
	if (!g_hGameConfig)
	{
		SetFailState("Failed to find give.bots.cosmetics.txt gamedata! Can't continue.");
	}	
	
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(g_hGameConfig, SDKConf_Virtual, "EquipWearable");
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	g_hWearableEquip = EndPrepSDKCall();
	
	if (!g_hWearableEquip)
	{
		SetFailState("Failed to prepare the SDKCall for giving cosmetics. Try updating gamedata or restarting your server.");
	}
}

public void OnEnabledChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	if (GetConVarBool(g_hCVEnabled))
	{
		HookEvent("post_inventory_application", player_inv);
	}
	else
	{
		UnhookEvent("post_inventory_application", player_inv);
	}
}

public void OnMapStart()
{
	if (GameRules_GetProp("m_bPlayingMannVsMachine"))
	{
		g_bMVM = true;
	}
}

public void OnClientDisconnect(int client)
{
	g_bTouched[client] = false;
}

public void player_inv(Handle event, const char[] name, bool dontBroadcast) 
{
	if (!GetConVarInt(g_hCVEnabled))
	{
		return;
	}

	int userd = GetEventInt(event, "userid");
	int client = GetClientOfUserId(userd);
	
	if (!g_bTouched[client] && !g_bMVM && IsPlayerHere(client))
	{
		g_bTouched[client] = true;
		int team = GetClientTeam(client);
		int team2 = GetConVarInt(g_hCVTeam);
		float timer = GetConVarFloat(g_hCVTimer);
		
		switch (team2)
		{
			case 1:
			{
				CreateTimer(timer, Timer_GiveHat, userd, TIMER_FLAG_NO_MAPCHANGE);
			}
			case 2:
			{
				if (team == 2)
				{
					CreateTimer(timer, Timer_GiveHat, userd, TIMER_FLAG_NO_MAPCHANGE);
				}
			}
			case 3:
			{
				if (team == 3)
				{
					CreateTimer(timer, Timer_GiveHat, userd, TIMER_FLAG_NO_MAPCHANGE);
				}
			}
		}
	}
}

public Action Timer_GiveHat(Handle timer, any data)
{
	int client = GetClientOfUserId(data);
	g_bTouched[client] = false;
	
	if (!GetConVarInt(g_hCVEnabled) || !IsPlayerHere(client))
	{
		return;
	}

	int team = GetClientTeam(client);
	int team2 = GetConVarInt(g_hCVTeam);
	
	switch (team2)
	{
		case 2:
		{
			if (team != 2)
			{
				return;
			}
		}
		case 3:
		{
			if (team != 3)
			{
				return;
			}
		}
	}
	if (!g_bMVM)
	{
		bool face = false;
		int rnd = GetRandomUInt(0,1);
		switch (rnd)
		{
			case 0:
			{
			TFClassType class = TF2_GetPlayerClass(client);
			switch (class)
			{
				case TFClass_Sniper:
				{
					int kwi = GetRandomUInt(0,1);
					switch (kwi)
					{
						case 0:
						{
							CreateHat(client, 518, 6); //Sniper Outfit Edgy
							CreateHat(client, 30599, 6); //Sniper Outfit Edgy
							CreateHat(client, 738, 6); //Sniper Outfit Edgy
							face = true;
						}
						case 1:
						{
							CreateHat(client, 783, 11); //Weird Sniper
							CreateHat(client, 744, 11); //Weird Sniper
							CreateHat(client, 30066, 11); //Weird Sniper
							face = true;
						}
					}
				}
				case TFClass_Medic:
				{
					int X = GetRandomUInt(0,2);
					switch (X)
					{
						case 0:
						{
							CreateHat(client, 30626, 6); //Medic Bulletproof
							CreateHat(client, 30323, 6); //Medic Bulletproof
							CreateHat(client, 30085, 6); //Medic Bulletproof
							face = true;
						}
						case 1:
						{
							CreateHat(client, 769, 6); //The Quadwranlger
							CreateHat(client, 30121, 6); //Das Maddendoktor
							CreateHat(client, 828, 6); //Archimedes
							face = true;
						}
						case 2:
						{
							CreateHat(client, 30171, 6); //The Medical Mystery
							CreateHat(client, 30323, 6); //The Ruffled Ruprecht
							face = true;
						}
					}
				}
				case TFClass_Spy:
				{
					int Y = GetRandomUInt(0,1);
					switch (Y)
					{
						case 0:
						{
							CreateHat(client, 30397, 6); //Spy overval
							CreateHat(client, 55, 6); //Spy overval
							CreateHat(client, 30389, 6); //Spy overval
							face = true;
						}
						case 1:
						{
							CreateHat(client, 30177, 6); //Weeb Spy
							CreateHat(client, 361, 6); //Weeb Spy
							CreateHat(client, 30389, 6); //Weeb Spy
							face = true;
						}
					}
				}
				case TFClass_Scout:
				{
					int Z = GetRandomUInt(0,1);
					switch (Z)
					{
						case 0:
						{
							CreateHat(client, 1016, 6); //Buck Turner All-Stars
							CreateHat(client, 30066, 6); //The Brotherhood of Arms
							CreateHat(client, 30076, 6); //The Bigg Mann on Campus
							face = true;
						}
						case 1:
						{
							CreateHat(client, 30394, 6); //The Frickin' Sweet Ninja Hood
							CreateHat(client, 30395, 6); //The Southie Shinobi
							CreateHat(client, 30396, 6); //	The Red Socks
							face = true;
						}
					}
				}
				case TFClass_Soldier:
				{
					int V = GetRandomUInt(0,1);
					switch (V)
					{
						case 0:
						{
							CreateHat(client, 30477, 6); //The Lone Survivor
							CreateHat(client, 30390, 6); //The Spook Specs
							CreateHat(client, 30388, 6); //The Classified Coif
							face = true;
						}
						case 1:
						{
							CreateHat(client, 54, 6); //Soldier's Stash
							CreateHat(client, 650, 6); //The Kringle Collection
							CreateHat(client, 30339, 6); //The Killer's Kit
							face = true;
						}
					}
				}
				case TFClass_DemoMan:
				{
					int F = GetRandomUInt(0,1);
					switch (F)
					{
						case 0:
						{
							CreateHat(client, 359, 6); //Samur-Eye
							CreateHat(client, 30073, 6); //The Dark Age Defender
							face = true;
						}
						case 1:
						{
							CreateHat(client, 30305, 6); //The Sub Zero Suit
							CreateHat(client, 30177, 6); //Hong Kong Cone
							face = true;
						}
						case 2:
						{
							CreateHat(client, 30305, 6); //The Cool Breeze
							CreateHat(client, 30064, 6); //The Tartan Shade
						}
					}
				}
				case TFClass_Heavy:
				{
					int S = GetRandomUInt(0,1);
					switch (S)
					{
						case 0:
						{
							CreateHat(client, 757, 6); //Heavy Towel
							CreateHat(client, 246, 6);
							face = true;
						}
						case 1:
						{
							CreateHat(client, 97, 6); //Tough Guy's Toque
							CreateHat(client, 647, 6); //The All-Father
							CreateHat(client, 738, 6); //Pet Balloonicorn
							face = true;
						}
					}
				}
				case TFClass_Pyro:
				{
					int H = GetRandomUInt(0,1);
					switch (H)
					{
						case 0:
						{
							CreateHat(client, 387, 6); //Sight for Sore Eyes
							CreateHat(client, 30367, 6); //The Cute Suit
							CreateHat(client, 30580, 6); //Pyromancer's Hood
							face = true;
						}
						case 1:
						{
							CreateHat(client, 632, 6); //The Cremator's Conscience
							CreateHat(client, 30119, 6); //The Federal Casemaker
							CreateHat(client, 30305, 6); //The Sub Zero Suit
							face = true;
						}
					}
				}
				case TFClass_Engineer:
				{
					int U = GetRandomUInt(0,1);
					switch (U)
					{
						case 0:
						{
							CreateHat(client, 30070, 6); //The Pocket Pyro
							CreateHat(client, 30330, 6); //The Dogfighter
							CreateHat(client, 640, 6); //The Top Notch
							face = true;
						}
						case 1:
						{
							CreateHat(client, 30172, 6); //Uncle Dane
							CreateHat(client, 30539, 6); //Uncle Dane
							CreateHat(client, 30420, 6); //Uncle Dane
							face = true;
						}
					}
				}
			}
		}
			case 1:
		{
		int N = GetRandomUInt(0,51);
		switch (N)
		{
			case 1:
			{
				CreateHat(client, 940, 6, 10); //Ghostly Gibus
			}
			case 2:
			{
				CreateHat(client, 668, 6); //The Full Head of Steam
			}
			case 3:
			{
				CreateHat(client, 774, 6); //The Gentle Munitionne of Leisure
			}
			case 4:
			{
				CreateHat(client, 941, 6, 31); //The Skull Island Topper
			}
			case 5:
			{
				CreateHat(client, 30357, 6); //Dark Falkirk Helm
			}
			case 6:
			{
				CreateHat(client, 538, 6); //Killer Exclusive
			}	
			case 7:
			{
				CreateHat(client, 139, 6); //Modest Pile of Hat
			}
			case 8:
			{
				CreateHat(client, 137, 6); //Noble Amassment of Hats
			}
			case 9:
			{
				CreateHat(client, 135, 6); //Towering Pillar of Hats
			}	
			case 10:
			{
				CreateHat(client, 30119, 6); //The Federal Casemaker
			}
			case 11:
			{
				CreateHat(client, 252, 6); //Dr's Dapper Topper
			}
			case 12:
			{
				CreateHat(client, 341, 6); //A Rather Festive Tree
			}
			case 13:
			{
				CreateHat(client, 523, 6, 10); //The Sarif Cap
			}
			case 14:
			{
				CreateHat(client, 614, 6); //The Hot Dogger
			}
			case 15:
			{
				CreateHat(client, 611, 6); //The Salty Dog
			}
			case 16:
			{
				CreateHat(client, 671, 6); //The Brown Bomber
			}
			case 17:
			{
				CreateHat(client, 817, 6); //The Human Cannonball
			}
			case 18:
			{
				CreateHat(client, 993, 6); //Antlers
			}
			case 19:
			{
				CreateHat(client, 984, 6); //Tough Stuff Muffs
			}
			case 20:
			{
				CreateHat(client, 1014, 6); //The Brutal Bouffant
			}
			case 21:
			{
				CreateHat(client, 30066, 6); //The Brotherhood of Arms
			}	
			case 22:
			{
				CreateHat(client, 30067, 6); //The Well-Rounded Rifleman
			}
			case 23:
			{
				CreateHat(client, 30175, 6); //The Cotton Head
			}
			case 24:
			{
				CreateHat(client, 30177, 6); //Hong Kong Cone
			}
			case 25:
			{
				CreateHat(client, 30313, 6); //The Kiss King
			}
			case 26:
			{
				CreateHat(client, 30307, 6); //Neckwear Headwear
			}
			case 27:
			{
				CreateHat(client, 30329, 6); //The Polar Pullover
			}
			case 28:
			{
				CreateHat(client, 30362, 6); //The Law
			}
			case 29:
			{
				CreateHat(client, 30567, 6); //The Crown of the Old Kingdom
			}
			case 30:
			{
				CreateHat(client, 1164, 6, 50); //Civilian Grade JACK Hat
			}
			case 31:
			{
				CreateHat(client, 920, 6); //The Crone's Dome
			}
			case 32:
			{
				CreateHat(client, 30425, 6); //Tipped Lid
			}
			case 33:
			{
				CreateHat(client, 30413, 6); //The Merc's Mohawk
			}
			case 34:
			{
				CreateHat(client, 921, 6); //The Executioner
				face = true;
			}
			case 35:
			{
				CreateHat(client, 30422, 6); //Vive La France
				face = true;
			}
			case 36:
			{
				CreateHat(client, 291, 6); //Horrific Headsplitter
			}
			case 37:
			{
				CreateHat(client, 345, 6, 10); //MNC hat
			}
			case 38:
			{
				CreateHat(client, 785, 6, 10); //Robot Chicken Hat
			}
			case 39:
			{
				CreateHat(client, 702, 6); //Warsworn Helmet
				face = true;
			}
			case 40:
			{
				CreateHat(client, 634, 6); //Point and Shoot
			}
			case 41:
			{
				CreateHat(client, 942, 6); //Cockfighter
			}
			case 42:
			{
				CreateHat(client, 944, 6); //That 70s Chapeau
				face = true;
			}
			case 43:
			{
				CreateHat(client, 30065, 6); //Hardy Laurel
			}
			case 44:
			{
				CreateHat(client, 30571, 6); //Brimstone
			}
			case 45:
			{
				CreateHat(client, 30473, 6); //MK 50
			}
			case 46:
			{
				CreateHat(client, 817, 6); //The Human Cannonball
			}
			case 47:
			{
				CreateHat(client, 1122, 6); //Towering Pillar of Summer Shades
			}
			case 48:
			{
				CreateHat(client, 30306, 6); //The Dictator
			}
			case 49:
			{
				CreateHat(client, 30309, 6); //Dead of Night
			}
			case 50:
			{
				CreateHat(client, 30397, 6); //The Bruiser's Bandana
			}
			case 51:
			{
				CreateHat(client, 30643, 6); //Potassium Bonnett
			}
		}
		
		if ( !face )
		{
			int rnd2 = GetRandomUInt(0,12);
			switch (rnd2)
			{
				case 1:
				{
					CreateHat(client, 30569, 6); //The Tomb Readers
				}
				case 2:
				{
					CreateHat(client, 744, 6); //Pyrovision Goggles
				}
				case 3:
				{
					CreateHat(client, 522, 6); //The Deus Specs
				}
				case 4:
				{
					CreateHat(client, 816, 6); //The Marxman
				}
				case 5:
				{
					CreateHat(client, 30104, 6); //Graybanns
				}
				case 6:
				{
					CreateHat(client, 30306, 6); //The Dictator
				}
				case 7:
				{
					CreateHat(client, 30352, 6); //The Mustachioed Mann
				}
				case 8:
				{
					CreateHat(client, 30414, 6); //The Eye-Catcher
				}
				case 9:
				{
					CreateHat(client, 30140, 6); //The Virtual Viewfinder
				}
				case 10:
				{
					CreateHat(client, 30397, 6); //The Bruiser's Bandanna
				}		
				case 11:
				{
					CreateHat(client, 582, 6); //Seal Mask
				}		
				case 12:
				{
					CreateHat(client, 30522, 6); //Supernatural Stalker
				}	
			}
		}
		
		int rnd3 = GetRandomUInt(0,25);
		switch (rnd3)
		{
			case 1:
			{
				CreateHat(client, 868, 6, 20); //Heroic Companion Badge
			}
			case 2:
			{
				CreateHat(client, 583, 6, 20); //Bombinomicon
			}
			case 3:
			{
				CreateHat(client, 586, 6); //Mark of the Saint
			}
			case 4:
			{
				CreateHat(client, 625, 6, 20); //Clan Pride
			}
			case 5:
			{
				CreateHat(client, 619, 6, 20); //Flair!
			}
			case 6:
			{
				CreateHat(client, 1025, 6); //The Fortune Hunter
			}
			case 7:
			{
				CreateHat(client, 623, 6, 20); //Photo Badge
			}
			case 8:
			{
				CreateHat(client, 738, 6); //Pet Balloonicorn
			}
			case 9:
			{
				CreateHat(client, 955, 6); //The Tuxxy
			}
			case 10:
			{
				CreateHat(client, 995, 6, 20); //Pet Reindoonicorn
			}
			case 11:
			{
				CreateHat(client, 987, 6); //The Merc's Muffler
			}
			case 12:
			{
				CreateHat(client, 1096, 6); //The Baronial Badge
			}
			case 13:
			{
				CreateHat(client, 30607, 6); //The Pocket Raiders
			}
			case 14:
			{
				CreateHat(client, 30068, 6); //The Breakneck Baggies
			}
			case 15:
			{
				CreateHat(client, 869, 6); //The Rump-o-Lantern
			}
			case 16:
			{
				CreateHat(client, 30309, 6); //Dead of Night
			}
			case 17:
			{
				CreateHat(client, 1024, 6); //Crofts Crest
			}
			case 18:
			{
				CreateHat(client, 992, 6); //Smissmas Wreath
			}
			case 19:
			{
				CreateHat(client, 956, 6); //Faerie Solitaire Pin
			}
			case 20:
			{
				CreateHat(client, 943, 6); //Hitt Mann Badge
			}
			case 21:
			{
				CreateHat(client, 873, 6, 20); //Whale Bone Charm
			}
			case 22:
			{
				CreateHat(client, 855, 6); //Vigilant Pin
			}
			case 23:
			{
				CreateHat(client, 818, 6); //Awesomenauts Badge
			}
			case 24:
			{
				CreateHat(client, 767, 6); //Atomic Accolade
			}
			case 25:
			{
				CreateHat(client, 718, 6); //Merc Medal
			}
		}
	}	
}
}
}

bool CreateHat(int client, int itemindex, int quality, int level = 0)
{
	int hat = CreateEntityByName("tf_wearable");
	
	if (!IsValidEntity(hat))
	{
		return false;
	}
	
	char entclass[64];
	GetEntityNetClass(hat, entclass, sizeof(entclass));
	SetEntData(hat, FindSendPropInfo(entclass, "m_iItemDefinitionIndex"), itemindex);
	SetEntData(hat, FindSendPropInfo(entclass, "m_bInitialized"), 1);
	SetEntData(hat, FindSendPropInfo(entclass, "m_iEntityQuality"), quality);

	if (level)
	{
		SetEntData(hat, FindSendPropInfo(entclass, "m_iEntityLevel"), level);
	}
	else
	{
		SetEntData(hat, FindSendPropInfo(entclass, "m_iEntityLevel"), GetRandomUInt(1,100));
	}
	
	DispatchSpawn(hat);
	SDKCall(g_hWearableEquip, client, hat);
	return true;
} 

bool IsPlayerHere(int client)
{
	return (client && IsClientInGame(client) && IsFakeClient(client));
}

int GetRandomUInt(int min, int max)
{
	return RoundToFloor(GetURandomFloat() * (max - min + 1)) + min;
}
