class CPMapInfo extends UDKMapInfo
	hidecategories(Object,UDKMapInfo)
	dependson(CPMapMusicInfo);

var() int RecommendedPlayersMin;
var() int RecommendedPlayersMax;

var(WelcomeScreen)  string  MapAuthor,
							MapMissionName,
							Contributors,
							RecommendedPlayerCount,
							SettingInfoRightBox,
							SettingInfoLeftBox;

var(WelcomeScreen) Texture2d MapImage;

var(Music) CPMapMusicInfo MapMusicInfo;

Defaultproperties
{
	MapImage=none
	RecommendedPlayersMin=6
	RecommendedPlayersMax=10
}
