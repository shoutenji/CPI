class CPWebAdmin extends WebApplication;

const webAdmin_logTag='CPWebAdmin';

function Init()
{
	`log("INIT WebAdmin",,webAdmin_logTag);
}

event Query(WebRequest Request,WebResponse Response)
{
	if(!ValidateUserLogin(Request.Username,Request.Password))
	{
		Response.FailAuthentication("CPWebAdmin");
		return;
	}		
	if (Request.URI=="/")
		Request.URI="/index.html";
	if (!Response.FileExists(Path $ Request.URI))
	{
		Response.HTTPError(404);
		return;
	}
    SetSubstHeader(Request,Response);
    SetSubstFooter(Request,Response);
	switch(Request.URI)
	{
		case "/index.html":
			HtmlStartPage(Request,Response);
		break;
		case "/game.html":
			HtmlGamePage(Request,Response);
		break;
		case "/map.html":
			HtmlMapPage(Request,Response);
		break;
		case "/player.html":
			HtmlPlayerPage(Request,Response);
		break;
		case "/server.html":
			HtmlServerPage(Request,Response);
		break;
		case "/info.html":
			HtmlInfoPage(Request,Response);
		break;
		default:
			ImageServer(Request,Response);
		break;
	}
}

function bool ValidateUserLogin(string Username, string Password)
{
	// TODO later
	if(Username!="test" || Password!="test")
		return false;
	return true;
}

function SetSubstHeader(WebRequest Request,WebResponse Response)
{
	// TODO later
	Response.Subst("Servername","TA Dev Server");
	Response.Subst("Username",Request.Username);
}

function SetSubstFooter(WebRequest Request,WebResponse Response)
{
	// TODO later
}

function HtmlStartPage(WebRequest Request,WebResponse Response)
{
local string WebContent;

	WebContent=Response.LoadParsedUHTM(Path$"/index.html");
    Response.SendText(WebContent);
}

function HtmlGamePage(WebRequest Request,WebResponse Response)
{
local string WebContent;

	WebContent=Response.LoadParsedUHTM(Path$"/game.html");
    Response.SendText(WebContent);
}

function HtmlMapPage(WebRequest Request,WebResponse Response)
{
local string WebContent;

	WebContent=Response.LoadParsedUHTM(Path$"/map.html");
    Response.SendText(WebContent);
}

function HtmlPlayerPage(WebRequest Request,WebResponse Response)
{
local string WebContent;

	WebContent=Response.LoadParsedUHTM(Path$"/player.html");
	Response.SendText(WebContent);
}

function HtmlServerPage(WebRequest Request,WebResponse Response)
{
local string WebContent;

	WebContent=Response.LoadParsedUHTM(Path$"/server.html");
	Response.SendText(WebContent);
}

function HtmlInfoPage(WebRequest Request,WebResponse Response)
{
local string WebContent;

	WebContent=Response.LoadParsedUHTM(Path$"/info.html");
	Response.SendText(WebContent);
}

function ImageServer(WebRequest Request,WebResponse Response)
{
local string Image;

	Image=Request.URI;
	`log("Image"@Image,,webAdmin_logTag);
	`log("Path"@Path,,webAdmin_logTag);
	if (!Response.FileExists(Path$Image))
	{
		Response.HTTPError(404);
		return;
	}
	else if (Right(Caps(Image),4)==".CSS")
		Response.SendStandardHeaders("text/css",true);
	else if (Right(Caps(Image),4)==".JPG" || Right(Caps(Image),5)==".JPEG")
		Response.SendStandardHeaders("image/jpeg",true);
	else if (Right(Caps(Image),4)==".GIF")
		Response.SendStandardHeaders("image/gif",true);
	else if (Right(Caps(Image),4)==".BMP")
		Response.SendStandardHeaders("image/bmp",true);
	else if (Right(Caps(Image),4)==".PNG")
		Response.SendStandardHeaders("image/png",true);
	else
		Response.SendStandardHeaders("application/octet-stream",true);
	Response.IncludeBinaryFile(Path$Image);
}

defaultproperties
{
}
