class CPGamePlayerPoll extends Object;

enum ETeamOutcome
{
	ETW_Win,
	ETW_Loose,
	ETW_Draw
};

enum EIntevtoryType
{
	EIT_Weap_Glock,
	EIT_Weap_RagingBull,
	EIT_Weap_DesertEagle,
	EIT_Weap_MP5A3,
	EIT_Weap_Mossberg,
	EIT_Weap_Mac10,
	EIT_Weap_KarSR25,
	EIT_Weap_SIG552,
	EIT_Weap_ScarH,
	EIT_Weap_HK121,
	EIT_Weap_AK47,
	EIT_Ammo_Glock,
	EIT_Ammo_RagingBull,
	EIT_Ammo_DesertEagle,
	EIT_Ammo_MP5A3,
	EIT_Ammo_Mossberg,
	EIT_Ammo_Mac10,
	EIT_Ammo_KarSR25,
	EIT_Ammo_SIG552,
	EIT_Ammo_ScarH,
	EIT_Ammo_HK121,
	EIT_Ammo_AK47,
	EIT_Ammo_HEGrenade,
	EIT_Ammo_Flashbang,
	EIT_Armor_Head,
	EIT_Armor_Body,
	EIT_Armor_Legs,
	EIT_NightVision
};

enum ECashRewardReason
{
	ECR_KillPlayer,			// For killing a member of the opposite team
	ECR_PlayerDiedPrey,		// Killing a member of the opposite team and collecting cash drop
	ECR_PlayerDiedVulture,	// Collecting a cash drop from a dead player that player did not kill
	ECR_KillTeamMember,		// Killing member of same team
	ECR_KillHostage,			// Killed a hostage
	ECR_PlayerRescueHostage,	// Player rescued a hostage
	ECR_TeamRescueHostage,	// Team member rescued a hostage
	ECR_RoundWon,			// Cash reward for winning round
	ECR_RoundLost,			// Cash reward for loosing round
	ECR_Evidence				// Successfully collected evidence
};

struct AmmoBelt
{
	var EIntevtoryType Weapon;
	var int AmmoCount;
};

struct PlayerInventoryInfo
{
	var array<EIntevtoryType> PlayerInventory;	// All weapons and ammo at time
	var array<AmmoBelt> AmmoBelt;				// Ammo counts for weapon go here
	var int Wallet;							//  Cash currently carried
};

struct CashReward
{
	var int Amount;							// Amount of cash. Positive if received, negative if lost.
	var float Time;							// Time cash was received (in match time)
	var ECashRewardReason Reason;				// Reason for receiving cash drop
	var PlayerInventoryInfo PlayerInventory;	// Player inventory snapshot
};

struct MarketTransaction
{
	var int Amount;							// Amount of cash involved. Positive if sell, negative if buy.
	var float Time;							// Time transacted (in match time)
	var EIntevtoryType InventoryItem;			// Item transacted
	var PlayerInventoryInfo PlayerInventory;	// Player inventory snapshot
};


struct PlayerEventInfo
{
	var byte PlayerID;
	var byte TeamIndex;
	var float Time;							//  Time either killed or killedby
	var EIntevtoryType Weapon;				// Weapon equipped at time
	var EIntevtoryType KillInstrument;			// Weapon used to kill
	var bool Suicide;							// If the player committed suicide
	var PlayerInventoryInfo PlayerInventory;	// The players total inventory
};

struct PickupEvent
{
	var float Time;
	var EIntevtoryType InventoryItem;
	var AmmoBelt AmmoCount;					// If the pickup is a weapon, the ammo count goes here
	var PlayerEventInfo PlayerEvent;
	var PlayerInventoryInfo PlayerInventory;	// Player inventory snapshot
};

struct PlayerRoundPoll
{
	var PlayerEventInfo Me;
	var PlayerEventInfo DeathInfo;
	var array<PlayerEventInfo> KillInfo;
	var bool CompletedObjectiveMe;
	var bool CompletedObjectiveTeam;
	var ETeamOutcome TeamOutcome;
	var array<CashReward> CashRewards;
	var array<MarketTransaction> MarketHistory;
	var array<PickupEvent> Pickups;
};