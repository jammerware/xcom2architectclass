class X2DownloadableContentInfo_JammerwareModClassArchitect extends X2DownloadableContentInfo;

/// <summary>
/// This method is run if the player loads a saved game that was created prior to this DLC / Mod being installed, and allows the 
/// DLC / Mod to perform custom processing in response. This will only be called once the first time a player loads a save that was
/// create without the content installed. Subsequent saves will record that the content was installed.
/// </summary>
static event OnLoadedSavedGame()
{}

/// <summary>
/// Called when the player starts a new campaign while this DLC / Mod is installed
/// </summary>
static event InstallNewCampaign(XComGameState StartState)
{}

/// <summary>
/// Called when all base game templates are loaded
/// </summary>
static event OnPostTemplatesCreated()
{
    local Jammerware_JSRC_GtsUnlockService GtsUnlockService;
    local Jammerware_JSRC_TransmatNetworkService TransmatNetworkService;

    TransmatNetworkService = new class'Jammerware_JSRC_TransmatNetworkService';
    TransmatNetworkService.RegisterTransmatAbilityToCharacterTemplates();

    GtsUnlockService = new class'Jammerware_JSRC_GtsUnlockService';
    GtsUnlockService.AddUnlock(class'X2SoldierAbilityUnlockTemplate_Deadbolt'.default.NAME_DEADBOLT);
}

/// <summary>
/// Called from XComGameState_Unit:GatherUnitAbilitiesForInit after the game has built what it believes is the full list of
/// abilities for the unit based on character, class, equipment, et cetera. You can add or remove abilities in SetupData.
/// </summary>
static function FinalizeUnitAbilitiesForInit(XComGameState_Unit UnitState, out array<AbilitySetupData> SetupData, optional XComGameState StartState, optional XComGameState_Player PlayerState, optional bool bMultiplayerDisplay)
{}

/// <summary>
/// Called from X2AbilityTag:ExpandHandler after processing the base game tags. Return true (and fill OutString correctly)
/// to indicate the tag has been expanded properly and no further processing is needed.
/// </summary>
static function bool AbilityTagExpandHandler(string InString, out string OutString)
{
    local Jammerware_JSRC_TagExpansionService TagService;

    TagService = new class'Jammerware_JSRC_TagExpansionService';
    OutString = TagService.ExpandAbilityTag(InString);
    return (OutString != "");
}