/*
    Purpose-wise, this a hot mess, but these conditions always go together and apply to the same
    abilities thanks to the software nightmare that is Soul of the Architect.

    The deal is that this condition goes on abilities that the spires get by default in X2Character_Spire. 
    They can use these abilities only if the architect who summoned them has a corresponding ability. For example,
    the spire automatically gets the ability class'JsrcAbility_FieldReloadArray'.default.NAME_SPIRE_ABILITY, but it can only go off
    if the architect has class'JsrcAbility_FieldReloadArray'.default.NAME_ABILITY. When the engine evaluates this condition for
    the spire, we need to go get the architect that summoned it and check for the prerequisite ability.

    The wrinkle is Soul of the Architect. All of these abilities can also go on architects, so we need to account 
    for the case where this ability is being checked for the architect. If the source (the architect, in this case) has the 
    prerequisite ability AND SotA, the check passes.
*/
class X2Condition_SpireAbilityCondition extends X2Condition;

var name RequiredArchitectAbility;

public event name CallAbilityMeetsCondition(XComGameState_Ability kAbility, XComGameState_BaseObject kTarget)
{ 
    local XComGameState_Unit ArchitectState, SourceUnit;
    local Jammerware_JSRC_SpireService SpireService;
    local Jammerware_JSRC_SpireRegistrationService SpireRegistrationService;
    local bool bRequireSotA;

    SpireService = new class'Jammerware_JSRC_SpireService';
    SpireRegistrationService = new class'Jammerware_JSRC_SpireRegistrationService';
    SourceUnit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(kAbility.OwnerStateObject.ObjectID));

    if (SourceUnit == none)
        return 'AA_NotAUnit';

    if (SpireService.IsSpire(SourceUnit))
    {
        ArchitectState = SpireRegistrationService.GetRunnerFromSpire(SourceUnit.ObjectID);
    }
    else 
    {
        ArchitectState = SourceUnit;
        bRequireSotA = true;
    }

    if
    (
        ArchitectState == none ||
        ArchitectState.FindAbility(RequiredArchitectAbility).ObjectID == 0 ||
        (bRequireSotA && ArchitectState.FindAbility(class'X2Ability_RunnerAbilitySet'.default.NAME_SOUL_OF_THE_ARCHITECT).ObjectID == 0)
    )
    {
        return 'AA_ValueCheckFailed';
    }

    return 'AA_Success'; 
}