/*
    Purpose-wise, this a hot mess, but these conditions always go together and apply to the same
    abilities thanks to the software nightmare that is Soul of the Architect.

    The deal is that this condition goes on abilities that the spires get by default in X2Character_Spire. 
    They can use these abilities only if the architect who summoned them has a corresponding ability. For example,
    the spire automatically gets the ability class'X2Ability_FieldReloadArray'.default.NAME_SPIRE_ABILITY, but it can only go off
    if the architect has class'X2Ability_FieldReloadArray'.default.NAME_ABILITY. When the engine evaluates this condition for
    the spire, we need to go get the architect that summoned it and check for the prerequisite ability.

    The wrinkle is Soul of the Architect. All of these abilities can also go on architects, so we need to account 
    for the case where this ability is being checked for the architect. If the source (the architect, in this case) has the 
    prerequisite ability AND SotA, the check passes.
*/
class X2Condition_SpireAbilityCondition extends X2Condition;

var name RequiredArchitectAbility;

event name CallMeetsCondition(XComGameState_BaseObject kTarget)
{
    local XComGameState_Unit ArchitectState, SourceState;
    local Jammerware_JSRC_SpireService SpireService;
    local Jammerware_JSRC_SpireRegistrationService SpireRegistrationService;
    local bool bRequireSotA;

    // not totally sure why, but when this condition is evaluated for an ability with 
    // a cursor targetstyle, the target is actually the source of the ability, and 
    // CallMeetsConditionWithSource isn't evaluated
    SourceState = XComGameState_Unit(kTarget);
    SpireService = new class'Jammerware_JSRC_SpireService';
    SpireRegistrationService = new class'Jammerware_JSRC_SpireRegistrationService';

    if (SourceState == none)
        return 'AA_NotAUnit';

    if (SpireService.IsSpire(SourceState))
    {
        ArchitectState = SpireRegistrationService.GetRunnerFromSpire(SourceState.ObjectID);
    }
    else 
    {
        ArchitectState = SourceState;
        bRequireSotA = true;
    }

    if 
    (
        ArchitectState == none ||
        ArchitectState.AffectedByEffectNames.Find(RequiredArchitectAbility) == INDEX_NONE ||
        (bRequireSotA && ArchitectState.AffectedByEffectNames.Find(class'X2Ability_RunnerAbilitySet'.default.NAME_SOUL_OF_THE_ARCHITECT) == INDEX_NONE)
    )
    {
        return 'AA_ValueCheckFailed';
    }

    return 'AA_Success';
}