class X2Condition_OwnedSpire extends X2Condition;

event name CallMeetsCondition(XComGameState_BaseObject kTarget)
{
    local XComGameState_Unit Target;

    Target = XComGameState_Unit(kTarget);

    if (Target == none)
    {
        return 'AA_NotAUnit';
    }
    if (Target.IsDead())
    {
        return 'AA_UnitIsDead';
    }
    if (Target.GetMyTemplate().CharacterGroupName != class'X2Character_Spire'.default.NAME_CHARACTERGROUP_SPIRE)
    {
        return 'AA_UnitIsWrongType';
    }

    return 'AA_Success';
}

event name CallMeetsConditionWithSource(XComGameState_BaseObject kTarget, XComGameState_BaseObject kSource)
{
    local XComGameState_Unit Source, Target, SpireOwner;
    local Jammerware_JSRC_SpireRegistrationService SpireRegistrationService;

    Source = XComGameState_Unit(kSource);
    Target = XComGameState_Unit(kTarget);

    if (Source.GetTeam() != Target.GetTeam())
    {
        return 'AA_UnitIsHostile';
    }

    SpireRegistrationService = new class'Jammerware_JSRC_SpireRegistrationService';
    SpireOwner = SpireRegistrationService.GetRunnerFromSpire(kTarget.ObjectID);

    if (SpireOwner == none || SpireOwner.ObjectID != Source.ObjectID)
    {
        return 'AA_ValueCheckFailed';
    }

    return 'AA_Success';
}