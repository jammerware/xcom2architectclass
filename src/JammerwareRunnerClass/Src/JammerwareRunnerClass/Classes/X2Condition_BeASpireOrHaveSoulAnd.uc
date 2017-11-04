class X2Condition_BeASpireOrHaveSoulAnd extends X2Condition;

var name RequiredRunnerAbility;

event name CallMeetsCondition(XComGameState_BaseObject kTarget)
{
    // not totally sure why, but when this condition is evaluated for an ability with 
    // a cursor targetstyle, the target is actually the source of the ability, and 
    // CallMeetsConditionWithSource isn't evaluated
    local XComGameState_Unit Source;

    Source = XComGameState_Unit(kTarget);

    if (Source == none)
    {
        return 'AA_NotAUnit';
    }

    if 
    (
        Source.GetMyTemplate().CharacterGroupName != class'X2Character_Spire'.default.NAME_CHARACTERGROUP_SPIRE &&
        (
            Source.AffectedByEffectNames.Find(class'X2Ability_RunnerAbilitySet'.default.NAME_SOUL_OF_THE_ARCHITECT) == INDEX_NONE ||
            (RequiredRunnerAbility != 'None' && Source.AffectedByEffectNames.Find(RequiredRunnerAbility) == INDEX_NONE)
        )
    )
    {
        return 'AA_ValueCheckFailed';
    }

    return 'AA_Success';
}