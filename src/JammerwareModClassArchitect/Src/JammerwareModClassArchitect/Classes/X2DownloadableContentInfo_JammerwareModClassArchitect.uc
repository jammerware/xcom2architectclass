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