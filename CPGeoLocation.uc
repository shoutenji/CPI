class CPGeoLocation extends TcpLink;

const geoLoacation_logTag='CPGeoLocation';

var string TargetHost;
var string TargetURL;
var int TargetPort;

var string Country;
var string City;
var string Region;

event PreBeginPlay()
{
    super.PreBeginPlay();
    if (WorldInfo.NetMode==NM_DedicatedServer || WorldInfo.NetMode==NM_ListenServer)
	{
		Country="Unknown";
        resolve(TargetHost);
    }
	else
    	Country="Local";
}

event Resolved(IpAddr Addr)
{
    Addr.Port=TargetPort;

	BindPort(); //this MUST go here or we have issues.
    if (!Open(Addr))
        `Log("Open failed",,geoLoacation_logTag);
}

event ResolveFailed()
{
    `Log("Unable to resolve "$TargetHost,,geoLoacation_logTag);
}

event Opened()
{
    SendText("GET "$TargetURL$" HTTP/1.0"$chr(13)$chr(10));
    SendText("Host: "$TargetHost$chr(13)$chr(10));
    SendText("Connection: Close"$chr(13)$chr(10));
    SendText(chr(13)$chr(10));
}

event ReceivedText(string Text)
{
    Country=GetXMLValue("geoplugin_countryName", Text);
    City=GetXMLValue("geoplugin_city", Text);
    Region=GetXMLValue("geoplugin_region", Text);	// or geoplugin_regionName
}

function string GetXMLValue(string XMLTag,string Text)
{
local int XMLTagStart;
local int XMLTagEnd;

	XMLTagStart=InStr(Text,"<"$XMLTag$">");
    if (XMLTagStart<0)
		return "";
    XMLTagStart+=Len(XMLTag)+2;
	XMLTagEnd=InStr(Text,"</"$XMLTag$">");
    if (XMLTagEnd<XMLTagStart)
		return "";
    return Mid(Text,XMLTagStart,XMLTagEnd-XMLTagStart);
}

defaultproperties
{
    TargetHost="www.geoplugin.net"
    TargetURL="/xml.gp"
    TargetPort=80    
}
