class CPAccessControl extends AccessControl;

var string strAdminPassword;	// Password to receive bAdmin privileges.
var string strGamePassword;		// Password to receive bAdmin privileges.
var int intMaxLoginAttempts;
var string strAdminName;
var globalconfig array<string>   VotedOutIPPolicies;
var globalconfig array<string>   TempBannedIPPolicies;
var globalconfig array<UniqueNetID> BannedForMapIDs;

function bool SetAdminPassword(string P)
{
	strAdminPassword=P;
	super.SetAdminPassword(P);
	return true;
}

function SetGamePassword(string P)
{
	strGamePassword=P;
	super.SetGamePassword(P);
}

function string GetAdminPassword()
{
	return strAdminPassword;
}

function string GetGamePassword()
{
	return strGamePassword;
}

function bool AdminLogin(PlayerController P,string Password)
{
	if (strAdminPassword == "")
	{
		CPPlayerController(P).MessageToConsole("AdminLogin has failed [Password Is Empty]");
		return false;
	}
	
	if (Password == strAdminPassword)
	{
		P.PlayerReplicationInfo.bAdmin=true;
		 strAdminName=P.PlayerReplicationInfo.PlayerName;
		CPPlayerController(P).MessageToConsole("You have logged in as administrator");
		return true;
	}
	else
	{
		CPPlayerController(P).MessageToConsole("You have failed to log in as administrator - incorrect password");
	}
	
	CPPlayerReplicationInfo(P.PlayerReplicationInfo).intLoginAttempts++;
	if(CPPlayerReplicationInfo(P.PlayerReplicationInfo).intLoginAttempts < intMaxLoginAttempts)
	{
		CPPlayerController(P).MessageToConsole("Login failure attempt" @ CPPlayerReplicationInfo(P.PlayerReplicationInfo).intLoginAttempts);
	}
	else
	{
		CPPlayerController(P).MessageToConsole("Login failure attempt reached maximum TODO tempkickban here");
	}
	return false;
}

function bool AdminLogout(PlayerController P)
{
	if (P.PlayerReplicationInfo.bAdmin)
	{
		P.PlayerReplicationInfo.bAdmin=false;
		P.bGodMode=false;
		CPPlayerController(P).MessageToConsole("You have logged out as administrator");
		return true;
	}
	return false;
}

function AdminEntered(PlayerController P)
{
local string LoginString;

	LoginString=P.PlayerReplicationInfo.PlayerName@"logged in as a server administrator.";
	//`log(LoginString);
	WorldInfo.Game.Broadcast(P,LoginString,'AdminLoginEvent');
}

function AdminExited(PlayerController P)
{
local string LogoutString;

	LogoutString=P.PlayerReplicationInfo.PlayerName@"is no longer logged in as a server administrator.";
	//`log(LogoutString);
	WorldInfo.Game.Broadcast(P,LogoutString,'AdminLogoutEvent');
}

function bool ForceKickPlayer(PlayerController C,string KickReason)
{
	if (C!=none && NetConnection(C.Player)!=none)
	{
		//if (C.Pawn!=none)
		//	C.Pawn.Suicide();

		if(KickReason == "You have been voted out of the map.")
		{
			CPPlayerController(C).ClientWasVoteKicked();
		}
		else
		{
			`log("Player " @ C.PlayerReplicationInfo.PlayerName $ " kicked from the server.");
		}
		
		

		if (C!=none)
			C.Destroy();
		// See if round should end because the player left
		CriticalPointGame(WorldInfo.Game).CheckMaxLives(none,true);

		return true;
	}
	return false;
}

function VoteKick( string Target )
{
	local PlayerController P;
	local string IP; 

	P =  PlayerController( GetControllerFromString(Target) );
	if(P == None) {`log("No Player Was Found."); return;}
	
	if ( NetConnection(P.Player) != None )
	{
		if (!WorldInfo.IsConsoleBuild())
		{
			IP = P.GetPlayerNetworkAddress();
			if( CheckIfVotedOutIPPolicy(IP) )
			{
				if(InStr(IP,":") != -1)
				{
					IP = Left(IP, InStr(IP, ":"));
				}
				`Log("Adding Vote IP Ban for: "$IP);
				VotedOutIPPolicies[VotedOutIPPolicies.length] = "DENY," $ IP;
				SaveConfig();
			}
		}
 
		if ( P.PlayerReplicationInfo.UniqueId != P.PlayerReplicationInfo.default.UniqueId &&
			!IsIDMapBanned(P.PlayerReplicationInfo.UniqueID) )
		{
			BannedForMapIDs.AddItem(P.PlayerReplicationInfo.UniqueId);
			SaveConfig();
		}
		
		CPPlayerController(P).LogAndOutMessage("[Admin Kick] You have been voted out of the map.");
		KickPlayer(P, "You have been voted out of the map.");
		return;
	}
}

function TempBan(string Target, string reason )
{
	local PlayerController P;
	local string IP; 

	P =  PlayerController( GetControllerFromString(Target) );
	if(P == None) {`log("No Player Was Found."); return;}
	
    if ( NetConnection(P.Player) != None )
	{
		if (!WorldInfo.IsConsoleBuild())
		{
			IP = P.GetPlayerNetworkAddress();
			if( CheckIfTempBannedIPPolicy(IP) )
			{
				if(InStr(IP,":") != -1)
				{
					IP = Left(IP, InStr(IP, ":"));
				}
				`Log("Adding Temp Ban for: "$IP);
				TempBannedIPPolicies[TempBannedIPPolicies.length] = "DENY," $ IP;
				SaveConfig();
			}
		}
 
		if ( P.PlayerReplicationInfo.UniqueId != P.PlayerReplicationInfo.default.UniqueId &&
			!IsIDMapBanned(P.PlayerReplicationInfo.UniqueID) )
		{
			BannedForMapIDs.AddItem(P.PlayerReplicationInfo.UniqueId);
			SaveConfig();
		}

		CPPlayerController(P).LogAndOutMessage("[Admin Ban] You have been temp banned for" @ reason @ ".");
		KickPlayer(P, "You have been temp banned for" @ reason @ ".");

		return;
	}
}

function KickBan( string Target )
{
	local PlayerController P;
	local string IP;

	P = PlayerController( GetControllerFromString(Target) );

	if(P == none)
	{
		`log("KickBan: No player was found!");
		return;
	}
	
	if (NetConnection(P.Player) != None )
	{
		if (!WorldInfo.IsConsoleBuild())
		{
			IP = P.GetPlayerNetworkAddress();
			if( CheckIPPolicy(IP) )
			{
				if(InStr(IP,":") != -1)
				{
					IP = Left(IP, InStr(IP, ":"));
				}
				`Log("Adding IP Ban for: "$IP);
				IPPolicies[IPPolicies.length] = "DENY," $ IP;
				SaveConfig();
			}
		}

		if ( P.PlayerReplicationInfo.UniqueId != P.PlayerReplicationInfo.default.UniqueId &&
			!IsIDBanned(P.PlayerReplicationInfo.UniqueID) )
		{
			BannedIDs.AddItem(P.PlayerReplicationInfo.UniqueId);
			SaveConfig();
		}
		CPPlayerController(P).LogAndOutMessage("[Admin Ban] " @ DefaultKickReason);
		KickPlayer(P, DefaultKickReason);
		return;
	}
}

function Kick( string Target )
{
	local Controller C;

	C = GetControllerFromString(Target);
	if ( C != none && C.PlayerReplicationInfo != None )
	{
		if (PlayerController(C) != None)
		{
			KickPlayer(PlayerController(C), DefaultKickReason);
		}
		else if (C.PlayerReplicationInfo != None)
		{
			if (C.Pawn != None)
			{
				if (C.PlayerReplicationInfo.bBot == true)
					CriticalPointGame(WorldInfo.Game).NumBots--;
				
				C.Pawn.Destroy();
			}
			if (C != None)
			{
				C.Destroy();
			}
		}
	}
//			

}

event PreLogin(string Options, string Address, const UniqueNetId UniqueId, bool bSupportsAuth, out string OutError, bool bSpectator)
{
	super.PreLogin(Options,Address,UniqueId,bSupportsAuth,OutError,bSpectator);
	if (!CheckIfVotedOutIPPolicy(Address))
	{
		OutError = "You have been voted out for the entire map.";
	}
	else if(!CheckIfTempBannedIPPolicy(Address))
	{
		OutError = "You have been temp banned for the entire map.";
	}
}

function bool CheckIfVotedOutIPPolicy(string Address)
{
	local int i, j;
`if(`notdefined(FINAL_RELEASE))
	local int LastMatchingPolicy;
`endif
	local string Policy, Mask;
	local bool bAcceptAddress, bAcceptPolicy;

	// strip port number
	j = InStr(Address, ":");
	if(j != -1)
		Address = Left(Address, j);

	bAcceptAddress = True;
	for(i=0; i<VotedOutIPPolicies.Length; i++)
	{
		j = InStr(VotedOutIPPolicies[i], ",");
		if(j==-1)
			continue;
		Policy = Left(VotedOutIPPolicies[i], j);
		Mask = Mid(VotedOutIPPolicies[i], j+1);
		if(Policy ~= "ACCEPT")
			bAcceptPolicy = True;
			else if(Policy ~= "DENY")
			bAcceptPolicy = False;
		else
			continue;

		j = InStr(Mask, "*");
		if(j != -1)
		{
			if(Left(Mask, j) == Left(Address, j))
			{
				bAcceptAddress = bAcceptPolicy;
				`if(`notdefined(FINAL_RELEASE))
				LastMatchingPolicy = i;
				`endif
			}
		}
		else
		{
			if(Mask == Address)
			{
				bAcceptAddress = bAcceptPolicy;
				`if(`notdefined(FINAL_RELEASE))
				LastMatchingPolicy = i;
				`endif
			}
		}
	}

	if(!bAcceptAddress)
	{
		`Log("Denied connection for "$Address$" with IP policy "$VotedOutIPPolicies[LastMatchingPolicy] $ " user banned for the duration of the map");
	}
	return bAcceptAddress;
}

function bool CheckIfTempBannedIPPolicy(string Address)
{
	local int i, j;
`if(`notdefined(FINAL_RELEASE))
	local int LastMatchingPolicy;
`endif
	local string Policy, Mask;
	local bool bAcceptAddress, bAcceptPolicy;

	// strip port number
	j = InStr(Address, ":");
	if(j != -1)
		Address = Left(Address, j);

	bAcceptAddress = True;
	for(i=0; i<TempBannedIPPolicies.Length; i++)
	{
		j = InStr(TempBannedIPPolicies[i], ",");
		if(j==-1)
			continue;
		Policy = Left(TempBannedIPPolicies[i], j);
		Mask = Mid(TempBannedIPPolicies[i], j+1);
		if(Policy ~= "ACCEPT")
			bAcceptPolicy = True;
			else if(Policy ~= "DENY")
			bAcceptPolicy = False;
		else
			continue;

		j = InStr(Mask, "*");
		if(j != -1)
		{
			if(Left(Mask, j) == Left(Address, j))
			{
				bAcceptAddress = bAcceptPolicy;
				`if(`notdefined(FINAL_RELEASE))
				LastMatchingPolicy = i;
				`endif
			}
		}
		else
		{
			if(Mask == Address)
			{
				bAcceptAddress = bAcceptPolicy;
				`if(`notdefined(FINAL_RELEASE))
				LastMatchingPolicy = i;
				`endif
			}
		}
	}

	if(!bAcceptAddress)
	{
		`Log("Denied connection for "$Address$" with IP policy "$TempBannedIPPolicies[LastMatchingPolicy] $ " user banned for the duration of the map");
	}
	return bAcceptAddress;
}

function bool IsIDMapBanned(const out UniqueNetID NetID)
{
	local int i;

	for (i = 0; i < BannedForMapIDs.length; i++)
	{
		if (BannedForMapIDs[i] == NetID)
		{
			return true;
		}
	}
	return false;
}

function CleanUpVotes()
{
	local array<string> BlankString;
	local array<UniqueNetId> BlankUID;

	BlankString = BlankString;
	BlankUID = BlankUID;

	`Log("Cleaning out votebans");
	CPAccessControl(WorldInfo.Game.AccessControl).VotedOutIPPolicies = BlankString;
	CPAccessControl(WorldInfo.Game.AccessControl).TempBannedIPPolicies = BlankString;
	CPAccessControl(WorldInfo.Game.AccessControl).BannedForMapIDs = BlankUID;
	SaveConfig();
}

function Controller GetControllerFromString(string Target)
{
	local Controller C,FinalC;
	local int i;

	FinalC = none;
	foreach WorldInfo.AllControllers(class'Controller', C)
	{
		if (C.PlayerReplicationInfo != None && (C.PlayerReplicationInfo.PlayerName ~= Target || C.PlayerReplicationInfo.PlayerName ~= Target))
		{
			FinalC = C;
			break;
		}
	}

	// if we didn't find it by name, attempt to convert the target to a player index and look him up if possible.
	if ( C == none && WorldInfo != none && WorldInfo.GRI != none )
	{
		for (i=0;i<WorldInfo.GRI.PRIArray.Length;i++)
		{
			if ( String(CPPlayerReplicationInfo(WorldInfo.GRI.PRIArray[i]).CPPlayerID) == Target )
			{
				FinalC = Controller(WorldInfo.GRI.PRIArray[i].Owner);
				break;
			}
		}
	}

	return FinalC;
}

DefaultProperties
{
	intMaxLoginAttempts=3
}
