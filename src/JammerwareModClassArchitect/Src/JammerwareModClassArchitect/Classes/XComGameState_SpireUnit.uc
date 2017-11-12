class XComGameState_SpireUnit extends XComGameState_Unit;

function string GetName(ENameType eType)
{
    local string UnitName;
    local XComGameState_Unit ArchitectState;
    local Jammerware_JSRC_SpireRegistrationService SpireRegistrationService;

    SpireRegistrationService = new class'Jammerware_JSRC_SpireRegistrationService';
    ArchitectState = SpireRegistrationService.GetRunnerFromSpire(self.ObjectID);
    UnitName = GetMyTemplate().strCharacterName;

    if (ArchitectState == none)
        return UnitName;
    
    UnitName = UnitName @ "(" $ ResolveArchitectName(ArchitectState) $ ")";

    return UnitName;
}

private function string ResolveArchitectName(XComGameState_Unit ArchitectState)
{
    local string ArchitectName;

    ArchitectName = ArchitectState.strNickName;
    if (ArchitectName != "") return ArchitectName;

    return ArchitectState.strLastName;
}

DefaultProperties
{
    bHasSuperConcealment=true
}