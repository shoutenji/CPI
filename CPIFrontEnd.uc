class CPIFrontEnd extends GFxMoviePlayer 
    config(UI);

/** Reference to _root of the movie's (cpi_manager.swf) stage. */
var GFxObject RootMC;

/** Reference to the manager MovieClip (_root.manager) where views will be attached. */
var GFxObject ManagerMC;

// Mouse cursor
var GFxObject MouseCursor;

/** View declarations. */
var CPI_FrontEnd_MainMenu MainMenuView;
var CPI_FrontEnd_PrivateGame PrivateGameView, PrivateServerView;
var CPI_FrontEnd_SettingsMenu SettingsMenu;
var CPI_FrontEnd_KeyBindings KeyBindings;
var CPI_FrontEnd_Welcome WelcomeMenu;
var CPI_FrontEnd_ExitGameDialog ExitGameDialog;
var CPI_FrontEnd_MultiplayerMenu MultiplayerMenu;

var CPI_FrontEnd_PasswordBoxPrompt PasswordBoxPrompt;
var CPI_FrontEnd_DialogBoxPrompt DialogBoxPrompt;
var CPI_FrontEnd_JoinServerDialog JoinServerDialog;
var CPI_FrontEnd_CharacterSelect CharacterSelect;

var bool bInitialized;

//used to hide/show elements when ingame.
var bool bOpenedIngame;
//used to pop login box
//var bool bLoginRequested;

var bool bWelcomeRequested;

/**
 * An array of names of views which have been attachMovie()'d and loadMovie()'d. Views
 * are loaded based on their DependantViews array, defined in Default.ini.
 */
var array<name>						LoadedViews;

/** Structure which defines a unique menu view to be loaded. */
struct ViewInfo
{
	/** Unique string. */
	var name ViewName;

    /** SWF content to be loaded. */
    var string SWFName;

    /** Dependant views that should be loaded if this view is displayed. */
    var array<name> DependantViews;
};

/** 
 *  Shadow of the AS view stack. Necessary to update ( View.OnTopMostView(false) ) views that
 *  alreday exist on the stack. 
 */
var array<CPIFrontEnd_View>		ViewStack;

/** Array of all menu views to be loaded, defined in DefaultUI.ini. */
var config array<ViewInfo>			ViewData;

//var SteamProfileInfo SPI;

var bool blnOpenWelcomeMenu, blnOpenCharacterSelectMenu, blnOpenLoginMenu, blnPopupWaiting;
/**
 * A delegate for Escape/Back key press which will generally move the user backward
 * through the menu or select "Cancel".
 */
delegate EscapeDelegate();

/**
 * A delegate for Enter key press which will generally help get though some of the UI
 */
delegate EnterDelegate();
/** 
 * Used by views to set the function triggered by "escape" input. 
 *
 * @param InDelegate	The EscapeDelegate that should be called on Escape/Cancel key press.
 */
final function SetEscapeDelegate( delegate<EscapeDelegate> InDelegate )
{
	local GFxObject _global;
	_global = GetVariableObject("_global");        
	ActionScriptSetFunction(_global, "OnEscapeKeyPress");
}

/** 
 * Used by views to set the function triggered by "enter" input. 
 *
 * @param InDelegate	The EnterDelegate that should be called on Enter key press.
 */
final function SetEnterDelegate( delegate<EnterDelegate> InDelegate )
{
	local GFxObject _global;
	_global = GetVariableObject("_global");        
	ActionScriptSetFunction(_global, "OnEnterKeyPress");
}

function bool Start(optional bool StartPaused)
{
	super.Start();
	Advance(0);
	SetViewScaleMode(SM_ExactFit);
	if (!bInitialized)
	{
		CPGameViewportClient(GetGameViewportClient()).DialogMessageQueue.RemoveAllMessages();
		ConfigFrontEnd();
		LoadViews();
	}

	GetPC().SetTimer(0.1,true,nameof(Tick),self);
	return true;
}

final function ConfigFrontEnd()
{
	RootMC=GetVariableObject("_root");
	ManagerMC=RootMC.GetObject("manager");

	// Ensure the mouse cursor stays on top of all other content in the movie
	MouseCursor = GetVariableObject("_root.cursor");
	MouseCursor.SetBool("topmostLevel", true);

	bInitialized=true;
}

final function LoadViews()
{
local byte i;

	for (i=0;i<ViewData.Length;i++) 
		LoadView(ViewData[i]);
}

/** 
 *  Create a view using existing ViewInfo. 
 *
 *  @param InViewInfo, the data for the view which includes the SWFName and the name for the view.
 */
final function LoadView(ViewInfo InViewInfo)
{
	local ASValue asval;
	local array<ASValue> args;
	local GFxObject ViewContainer, ViewLoader;

	ViewContainer = ManagerMC.CreateEmptyMovieClip( String(InViewInfo.ViewName) $ "Container" );
	ViewLoader = ViewContainer.CreateEmptyMovieClip( String(InViewInfo.ViewName) );

	asval.Type = AS_String;
	asval.s = InViewInfo.SWFName;
	args[0] = asval;

	ViewContainer.SetVisible( false );
	ViewLoader.Invoke( "loadMovie", args );
	LoadedViews.AddItem( InViewInfo.ViewName );
}

final function ConfigureView(CPIFrontEnd_View InView, name WidgetName, name WidgetPath)
{	
    SetWidgetPathBinding(InView, WidgetPath);
    InView.MenuManager = self;
    InView.ViewName = WidgetName;
    InView.OnViewLoaded();
}

/** Check whether target view is appropriate to add to the view stack. */
function bool IsViewAllowed(CPIFrontEnd_View TargetView)
{
    local byte i;	
    local name TargetViewName;

    // Check to see that we weren't passed a null view.
    if ( TargetView == none )
    {
		`log( "CPIFrontEnd:: TargetView is null. Unable to push view onto stack.");         
        return false;
    }

    // Check to see if the view is already loaded on the view stack using the view name. 
    TargetViewName = TargetView.ViewName;
    for ( i = 0; i < ViewStack.Length; i++ )
    {
        if (ViewStack[i].ViewName == TargetViewName)
        {
			`log( "CPIFrontEnd:: TargetView is already on the stack.");             
            return false;
        }
    }
    return true;
}

/** 
 * Activates, updates, and pushes a view on the stack if it is allowed.
 * This method is called when a view is created by name using PushViewByName().
 */
function ConfigureTargetView(CPIFrontEnd_View TargetView)
{
    if( IsViewAllowed( TargetView ) )
    {
        // Disable the current top most view's controls to prevent focus from escaping during the transition.
		if (ViewStack.Length > 0)
		{
			ViewStack[ViewStack.Length - 1].DisableSubComponents(true);
		}
        
        TargetView.OnViewActivated();
        TargetView.OnTopMostView( true );

        ViewStack.AddItem( TargetView );
        PushView( TargetView );      
    }    
}

/** 
 *  Callback when a CLIK widget with enableInitCallback set to TRUE is initialized.  
 *  Returns TRUE if the widget was handled, FALSE if not. 
 */
event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{    
	local bool bWasHandled;
	bWasHandled = false;
	
	//`log( "CPI_FrontEnd::WidgetInit: " @ WidgetName @ " : " @ WidgetPath @ " : " @ Widget);
	switch(WidgetName)
    {           
        case ('MainMenu'):
            if (MainMenuView == none)
            {
                MainMenuView = CPI_FrontEnd_MainMenu(Widget);

				MainMenuView.bOpenedIngame = bOpenedIngame;
                ConfigureView(MainMenuView, WidgetName, WidgetPath);

                // Currently here because need to ensure MainMenuView has loaded.
                ConfigureTargetView(MainMenuView);      
                bWasHandled = true;
            }            
            break;
        case ('PrivateGame'):
            if (PrivateGameView == none)
            {
                PrivateGameView = CPI_FrontEnd_PrivateGame(Widget);
                ConfigureView(PrivateGameView, WidgetName, WidgetPath); 
            }
            bWasHandled = true;
            break;
        case ('PrivateServerView'):
            if (PrivateServerView == none)
            {
                PrivateServerView = CPI_FrontEnd_PrivateGame(Widget);
				PrivateServerView.blnPrivateServer = true;
                ConfigureView(PrivateServerView, WidgetName, WidgetPath); 
                bWasHandled = true;
            }			
            break;	
        case ('SettingsMenu'):
            if (SettingsMenu == none)
            {
                SettingsMenu = CPI_FrontEnd_SettingsMenu(Widget);
                ConfigureView(SettingsMenu, WidgetName, WidgetPath); 
                bWasHandled = true;
            }			
            break;	
        case ('MultiplayerMenu'):
            if (MultiplayerMenu == none)
            {
                MultiplayerMenu = CPI_FrontEnd_MultiplayerMenu(Widget);
                ConfigureView(MultiplayerMenu, WidgetName, WidgetPath); 
                bWasHandled = true;
            }			
            break;	
        case ('PasswordBoxPrompt'):
            if (PasswordBoxPrompt == none)
            {
                PasswordBoxPrompt = CPI_FrontEnd_PasswordBoxPrompt(Widget);
                ConfigureView(PasswordBoxPrompt, WidgetName, WidgetPath); 
                bWasHandled = true;
            }			
            break;	
        case ('DialogBoxPrompt'):
            if (DialogBoxPrompt == none)
            {
                DialogBoxPrompt = CPI_FrontEnd_DialogBoxPrompt(Widget);
                ConfigureView(DialogBoxPrompt, WidgetName, WidgetPath); 
                bWasHandled = true;
            }			
            break;	
        case ('JoinServerDialog'):
            if (JoinServerDialog == none)
            {
                JoinServerDialog = CPI_FrontEnd_JoinServerDialog(Widget);
                ConfigureView(JoinServerDialog, WidgetName, WidgetPath); 
                bWasHandled = true;
            }			
            break;	
        case ('CharacterSelect'):
            if (CharacterSelect == none)
            {
                CharacterSelect = CPI_FrontEnd_CharacterSelect(Widget);
                ConfigureView(CharacterSelect, WidgetName, WidgetPath); 
                bWasHandled = true;
            }			
            break;	
        case ('KeyBindings'):
            if (KeyBindings == none)
            {
                KeyBindings = CPI_FrontEnd_KeyBindings(Widget);
                ConfigureView(KeyBindings, WidgetName, WidgetPath); 
                bWasHandled = true;
            }			
            break;		
        case ('WelcomeMenu'):
            if (WelcomeMenu == none)
            {
                WelcomeMenu = CPI_FrontEnd_Welcome(Widget);
                ConfigureView(WelcomeMenu, WidgetName, WidgetPath); 
                bWasHandled = true;
            }			
            break;		
         case('ExitGameDialog'):
			if (ExitGameDialog == none)
            {
				ExitGameDialog = CPI_FrontEnd_ExitGameDialog(Widget);
				ConfigureView(ExitGameDialog, WidgetName, WidgetPath);
				bWasHandled = true;
            }
			break;
   //      case('LoginDialog'):
			//if (LoginDialog == none)
   //         {
			//	LoginDialog = CPI_FrontEnd_LoginDialog(Widget);
			//	ConfigureView(LoginDialog, WidgetName, WidgetPath);

			//	//if(!bOpenedIngame)
			//	//{
			//	//	class'Engine'.static.BasicLoadObject(SPI, "steam_api.bin", false, 1);

			//	//	if(SPI.steamID == "")
			//	//	{
			//	//		// Currently here because need to ensure MainMenuView has loaded.
			//	//		ConfigureTargetView(LoginDialog);  
			//	//	}
			//	//}

			//	bWasHandled = true;
   //         }
			break;			
        default:
            break;
    }
 
    return bWasHandled;
}

final function PushViewByName(name TargetViewName, optional CPIFrontEnd_Screen ParentView)
{
	//`log( "CPIFrontEnd::PushViewByName(" @ string(TargetViewName) @ ")");    
	switch (TargetViewName)
	{
		case ('MainMenuView'): 
			ConfigureTargetView(MainMenuView);
			break;
		case ('PrivateServerView'): 
			ConfigureTargetView(PrivateServerView);
			break;
		case ('PrivateGameView'): 
			ConfigureTargetView(PrivateGameView);
			break;
		case ('ExitGameDialog'):
			ConfigureTargetView(ExitGameDialog);
			break;
		//case ('LoginDialog'):
		//	ConfigureTargetView(LoginDialog);
		//	break;
		case ('SettingsMenu'):
			ConfigureTargetView(SettingsMenu);
			SettingsMenu.UpdateCrosshairColourAndScale();
			break;
		case ('MultiplayerMenu'):
			ConfigureTargetView(MultiplayerMenu);
			break;			
		case ('KeyBindings'):
			CPConsole(CPGameViewportClient(GetGameViewportClient()).ViewportConsole).blnToggleConsole = false;
			ConfigureTargetView(KeyBindings);
			break;		
		case ('WelcomeMenu'):
			ConfigureTargetView(WelcomeMenu);
			break;	
		case ('PasswordBoxPrompt'):
			ConfigureTargetView(PasswordBoxPrompt);
			break;	
		case ('DialogBoxPrompt'):
			ConfigureTargetView(DialogBoxPrompt);
			break;	
		case ('JoinServerDialog'):
			ConfigureTargetView(JoinServerDialog);
			break;	
		case ('CharacterSelect'):
			ConfigureTargetView(CharacterSelect);
			break;	
		default:
			`log( "View ["$TargetViewName$"] not found.");  
			break;
	}
}

/** Pushes a view onto MenuManager.as view stack. */
function PushView(coerce CPIFrontEnd_View targetView) 
{     
    ActionScriptVoid("pushStandardView"); 
}

/** Pops a view from the view stack and handles update/close of existing views. */
function GFxObject PopView() 
{       
    if ( ViewStack.Length <= 1 ) 
    {
        return none;
    }

    // Call OnViewClosed() for the popped view. 
    // Generally, this will disable the view's list to prevent accidental mouse rollOvers that cause
    // focus to change undesirably as the view is tweened out.
    ViewStack[ViewStack.Length-1].OnViewClosed();

    // Remove the view from the stack in US so we know what's still on top.   
    ViewStack.Remove(ViewStack.Length-1, 1);     

    // Update the new top most view.    
    ViewStack[ViewStack.Length-1].OnTopMostView( false ); 

    return PopViewStub();
}

/** Pops a view from the MenuManager.as view stack. */
final function GFxObject PopViewStub() { return ActionScriptObject("popView"); }


function bool FilterButtonInput(int ControllerId, name ButtonName, EInputEvent InputEvent)
{
	if(ViewStack.Length != 0)
	{
		if (ViewStack[ViewStack.Length-1] != none)
		{
			//`Log("FilterButtonInput "@ButtonName@"Filtered to"@ViewStack[ViewStack.Length-1]);
			return ViewStack[ViewStack.Length-1].OnFilterButtonInput(ControllerId, ButtonName, InputEvent);
		}
	}

	return False;
}

function Tick()
{
	ShouldOpenWelcomeMenu();
	ShouldOpenCharacterSelectMenu();
	ShouldOpenPopupMenu();

	//require tick for views - add views here.
	if(MultiplayerMenu != none)
	{
		if(MultiplayerMenu.bMovieShowing)
		{
			MultiplayerMenu.Tick();
		}
	}

	if(WelcomeMenu != none)
	{
		if(WelcomeMenu.bMovieShowing)
		{
			WelcomeMenu.Tick();
		}
	}

	if(SettingsMenu != none)
	{
		SettingsMenu.Tick();
	}
}

function ShouldOpenPopupMenu()
{
	local string strTitle, strBody;
	if (CPGameViewportClient(GetGameViewportClient()).DialogMessageQueue != none)
	{				
		if(CPGameViewportClient(GetGameViewportClient()).DialogMessageQueue.HasMessages())
		{
			Start();
			strTitle = CPGameViewportClient(GetGameViewportClient()).DialogMessageQueue.GetLastMessage().MessageTitle;
			strBody = CPGameViewportClient(GetGameViewportClient()).DialogMessageQueue.GetLastMessage().MessageBody;
			//no point in showing messages if the menu is not open...
			if(MainMenuView != none)
			{
				if(strBody != "You need to enter a password to join this game.")
				{
					//Make sure we do not put duplicate dialog boxes onto the stack (thats bad!)
					if(DialogBoxPrompt != none  && !DialogBoxPrompt.bMovieShowing)
					{
						PushViewByName('DialogBoxPrompt');
					}
				}
				else
				{
					if(PasswordBoxPrompt != none  && !PasswordBoxPrompt.bMovieShowing)
					{
						PushViewByName('PasswordBoxPrompt');
					}
				}
			}
			
			//set the text of dialog elements
			DialogBoxPrompt.SetTitle(strTitle);
			DialogBoxPrompt.SetBody(strBody);
		}
	}
}

function ShouldOpenCharacterSelectMenu()
{
	if (blnOpenCharacterSelectMenu)
	{
		if(MainMenuView != none)
		{
			if(CharacterSelect != none)
			{
				//`Log("Request to open character select menu");
				blnOpenCharacterSelectMenu = false;
				PushViewByName('CharacterSelect');
				CharacterSelect.InitChar();
			}
		}
	}
}

function ShouldOpenWelcomeMenu()
{
	local WorldInfo WorldInfo;

	//never open welcome screen if not ingame
	if(!bOpenedIngame)
		return;

	WorldInfo = class'WorldInfo'.static.GetWorldInfo();

	if(WorldInfo.GetMapName() == "cpfrontendmap")
	{
		//never open welcome sceen on this map.
		blnOpenWelcomeMenu = false;
		return;
	}

	if (blnOpenWelcomeMenu)
	{
		if(MainMenuView != none)
		{
			if(WelcomeMenu != none)
			{
				//`Log("Request to open welcome menu");
				blnOpenWelcomeMenu = false;
				PushViewByName('WelcomeMenu');
			}
		}
	}
}

defaultproperties
{    
    WidgetBindings.Add((WidgetName="MainMenu",WidgetClass=class'CriticalPoint.CPI_FrontEnd_MainMenu'))
    WidgetBindings.Add((WidgetName="PrivateGame",WidgetClass=class'CriticalPoint.CPI_FrontEnd_PrivateGame'))
    WidgetBindings.Add((WidgetName="ExitGameDialog",WidgetClass=class'CriticalPoint.CPI_FrontEnd_ExitGameDialog'))
    WidgetBindings.Add((WidgetName="PrivateServerView",WidgetClass=class'CriticalPoint.CPI_FrontEnd_PrivateGame'))
//    WidgetBindings.Add((WidgetName="LoginDialog",WidgetClass=class'CriticalPoint.CPI_FrontEnd_LoginDialog'))
    WidgetBindings.Add((WidgetName="SettingsMenu",WidgetClass=class'CriticalPoint.CPI_FrontEnd_SettingsMenu'))
	WidgetBindings.Add((WidgetName="KeyBindings",WidgetClass=class'CriticalPoint.CPI_FrontEnd_KeyBindings'))
	WidgetBindings.Add((WidgetName="WelcomeMenu",WidgetClass=class'CriticalPoint.CPI_FrontEnd_Welcome'))
    WidgetBindings.Add((WidgetName="MultiplayerMenu",WidgetClass=class'CriticalPoint.CPI_FrontEnd_MultiplayerMenu'))
	WidgetBindings.Add((WidgetName="PasswordBoxPrompt",WidgetClass=class'CriticalPoint.CPI_FrontEnd_PasswordBoxPrompt'))
	WidgetBindings.Add((WidgetName="DialogBoxPrompt",WidgetClass=class'CriticalPoint.CPI_FrontEnd_DialogBoxPrompt'))
	WidgetBindings.Add((WidgetName="JoinServerDialog",WidgetClass=class'CriticalPoint.CPI_FrontEnd_JoinServerDialog'))
	WidgetBindings.Add((WidgetName="CharacterSelect",WidgetClass=class'CriticalPoint.CPI_FrontEnd_CharacterSelect'))



	//SoundThemes(0)=(ThemeName=default,Theme=UISoundTheme'GFxTAFrontEnd.Sounds.TA_UISoundTheme')

    bDisplayWithHudOff=true   
    TimingMode=TM_Real
    bInitialized=false 
	MovieInfo=SwfMovie'CPI_FrontEnd.CPI_manager'
	bPauseGameWhileActive=false
	bCaptureInput=true
}