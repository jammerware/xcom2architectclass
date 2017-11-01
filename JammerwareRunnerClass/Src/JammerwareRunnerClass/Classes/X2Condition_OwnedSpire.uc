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
    local XComGameState_Unit Source, Target;

    Source = XComGameState_Unit(kSource);
    Target = XComGameState_Unit(kTarget);

    if (Source.GetTeam() != Target.GetTeam())
    {
        return 'AA_UnitIsHostile';
    }

    return 'AA_Success';
}

event name CallAbilityMeetsCondition(XComGameState_Ability kAbility, XComGameState_BaseObject kTarget)
{
    local Jammerware_SpireRegistrationService SpireRegistrationService;
    local XComGameState GameState;
    local XComGameState_Unit Source, SpireOwner;

    SpireRegistrationService = new class'Jammerware_SpireRegistrationService';
    GameState = kAbility.GetParentGameState();
    Source = XComGameState_Unit(GameState.GetGameStateForObjectID(kAbility.OwnerStateObject.ObjectID));
    SpireOwner = SpireRegistrationService.GetRunnerFromSpire(kTarget.ObjectID);

    if (SpireOwner == none || SpireOwner.ObjectID != Source.ObjectID)
    {
        `LOG("JSRC: spire owner isn't right" @ SpireOwner.ObjectID);
        `LOG("JSRC: source is" @ Source.ObjectID);
        return 'AA_ValueCheckFailed';
    }

    return 'AA_Success';
}