class CPExternalUtils extends Object
	config(CPUtils)
	hidecategories(Movement,Display,Collision,Attachment,Physics,Advanced,Debug,Object,Actor)
	DLLBind(CP_Utils);

var config string oscRouterHostIP;
var config int oscRouterHostPort;
var config array<string> oscSoundCueIndexer;

// display mode definitions
struct SDisplaySize
{
	var int X,Y;
};

struct SDisplayModeContainer
{
	var array<SDisplaySize> modeList;
	var byte bCountOnly;
	var int ItemCount;
};

enum TADLLBindResult
{
	DBR_Ok,
	DBR_InvalidParam,
	DBR_InternalError,
	DBR_InvalidInternalResult,
	DBR_QueryListIsEmpty,
};

// DLL Imports
// Display modes
dllimport private final function byte cpGetDisplayModes(out SDisplayModeContainer data);

// OSC Router
dllimport private final function byte cpOscRouterInit(string hostIP,string hostPort);
dllimport private final function byte cpOscRouterShutDown();
dllimport private final function byte cpOscRouterSendBool(string varName,byte varValue);
dllimport private final function byte cpOscRouterSendInt(string varName,int varValue);
dllimport private final function byte cpOscRouterSendFloat(string varName,float varValue);
dllimport private final function byte cpOscRouterSendString(string varName,string varValue);

// Wraper/generic functions
// Display modes
final function bool GetDisplayModes(out array<Vector2D> sizes)
{
local SDisplayModeContainer sdata;
local int j;
local TADLLBindResult result;
local Vector2D tmpVec2;

	sdata.modeList.length=0;
	sdata.bCountOnly=byte(true);
	sdata.ItemCount=0;
	result=(TADLLBindResult(cpGetDisplayModes(sdata)));
	if (result!=DBR_Ok)
	{
		`log("failed to get display modes ["$result$"]");
		return false;
	}
	if (sdata.ItemCount==0)
	{
		`log("failed to get display modes, no modes returned!");
		return false;
	}
	sdata.modeList.Add(sdata.ItemCount);
	sdata.bCountOnly=byte(false);
	sdata.ItemCount=0;
	result=(TADLLBindResult(cpGetDisplayModes(sdata)));
	if (result!=DBR_Ok)
	{
		`log("failed to get display modes ["$result$"]");
		return false;
	}
	if (sdata.modeList.length==0)
	{
		`log("failed to get display modes, no modes returned!");
		return false;
	}
	sizes.Remove(0,sizes.length);
	for (j=0;j<sdata.modeList.length;j++)
	{
		tmpVec2.X=sdata.modeList[j].X;
		tmpVec2.Y=sdata.modeList[j].Y;
		sizes.AddItem(tmpVec2);
	}
	return true;
}

// OSC router
final function bool OscRouterInit()
{
	if (oscRouterHostIP=="" || oscRouterHostPort==0)
	{
		`warn("unable to initalize OSC Router, Host IP and/or Port is missing");
		return false;
	}
	return (cpOscRouterInit(oscRouterHostIP,string(oscRouterHostPort))==0);
}

final function OscRouterShutDown()
{
	cpOscRouterShutDown();
}

final function bool OscRouterSendBool(string varName,bool varValue)
{
	if (varName=="")
		return false;
	return (cpOscRouterSendBool(varName,byte(varValue))==0);
}

final function bool OscRouterSendInt(string varName,int varValue)
{
	if (varName=="")
		return false;
	return (cpOscRouterSendInt(varName,varValue)==0);
}

final function bool OscRouterSendFloat(string varName,float varValue)
{
	if (varName=="")
		return false;
	return (cpOscRouterSendFloat(varName,varValue)==0);
}

final function bool OscRouterSendString(string varName,string varValue)
{
	if (varName=="" || varValue=="")
		return false;
	return (cpOscRouterSendString(varName,varValue)==0);
}
