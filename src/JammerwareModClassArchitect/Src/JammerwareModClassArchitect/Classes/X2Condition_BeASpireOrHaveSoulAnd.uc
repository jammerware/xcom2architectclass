class X2Condition_BeASpireOrHaveSoulAnd extends X2Condition;

var name RequiredRunnerAbility;

event name CallMeetsCondition(XComGameState_BaseObject kTarget)
{
    // not totally sure why, but when this condition is evaluated for an ability with 
    // a cursor targetstyle, the target is actually the source of the ability, and 
    // CallMeetsConditionWithSource isn't evaluated
    local XComGameState_Unit Source;
    local Jammerware_JSRC_SpireService SpireService;

    Source = XComGameState_Unit(kTarget);
    SpireService = new class'Jammerware_JSRC_SpireService';

    if (Source == none)
    {
        return 'AA_NotAUnit';
    }

    if 
    (
        !SpireService.IsSpire(Source) 
        && RequiredRunnerAbility != 'None' 
        && Source.AffectedByEffectNames.Find(RequiredRunnerAbility) == INDEX_NONE
    )
    {
        return 'AA_ValueCheckFailed';
    }

    return 'AA_Success';
}