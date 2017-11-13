class X2DownloadableContentInfo_JammerwareModClassArchitect extends X2DownloadableContentInfo;

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

    // this seems like a weird place to do this, but i didn't find anything else that says "do this when the client starts and your mod is on"
    `CONTENT.BuildPerkPackageCache();
}

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

exec function JSRC_ToggleCustomDebugOutput() {
    class'Jammerware_JSRC_DebugStateMachines'.static.GetThisScreen().ToggleVisible();
}
 
exec function JSRC_PrintPerkContentsForXCom() {
    class'Jammerware_JSRC_DebugStateMachines'.static.PrintOutPerkContentsForXComUnits();
}
 
exec function JSRC_PrintLoadedPerkContents() {
    class'Jammerware_JSRC_DebugStateMachines'.static.PrintOutLoadedPerkContents();
}
 
exec function JSRC_TryForceAppendAbilityPerks(name AbilityName) {
    class'Jammerware_JSRC_DebugStateMachines'.static.TryForceAppendAbilityPerks(AbilityName);
}
 
exec function JSRC_TryForceCachePerkContent(name AbilityName) {
    class'Jammerware_JSRC_DebugStateMachines'.static.TryForceCachePerkContent(AbilityName);
}
 
exec function JSRC_TryForceBuildPerkContentCache() {
    class'Jammerware_JSRC_DebugStateMachines'.static.TryForceBuildPerkContentCache();
}
 
exec function JSRC_ForceLoadPerkOnToUnit(name AbilityName) {
    class'Jammerware_JSRC_DebugStateMachines'.static.TryForceBuildPerkContentCache();
    class'Jammerware_JSRC_DebugStateMachines'.static.TryForceCachePerkContent(AbilityName);
    class'Jammerware_JSRC_DebugStateMachines'.static.TryForceAppendAbilityPerks(AbilityName);
}