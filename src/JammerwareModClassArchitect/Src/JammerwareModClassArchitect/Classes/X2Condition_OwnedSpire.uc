class X2Condition_OwnedSpire extends X2Condition;

var bool RequireHasAvailableActions;

event name CallMeetsCondition(XComGameState_BaseObject kTarget)
{
    local XComGameState_Unit Target;
    local Jammerware_JSRC_AbilityStateService AbilityStateService;
    local Jammerware_JSRC_SpireService SpireService;
    local XComGameState_Ability AbilityStateIterator;
    local array<XComGameState_Ability> ActivatedAbilities;
    local bool CanAffordAnAbility;

    Target = XComGameState_Unit(kTarget);
    AbilityStateService = new class'Jammerware_JSRC_AbilityStateService';
    SpireService = new class'Jammerware_JSRC_SpireService';

    if (Target == none)
        return 'AA_NotAUnit';

    if (Target.IsDead())
        return 'AA_UnitIsDead';

    if (!SpireService.IsSpire(Target))
        return 'AA_UnitIsWrongType';

    // this is here to stop the architect from activating a spire that has no legal active abilities, like if they have quicksilver but not kinetic rigging
    // and the spire in question doesn't have any charges left
    ActivatedAbilities = AbilityStateService.GetActivatedAbilities(Target);
    if (RequireHasAvailableActions && ActivatedAbilities.Length > 0)
    {
        foreach ActivatedAbilities(AbilityStateIterator)
        {
            if (SpireService.SpireCanCast(AbilityStateIterator) && AbilityStateService.CanAffordNonActionPointCosts(AbilityStateIterator))
            {
                CanAffordAnAbility = true;
                break;
            }

        }

        if (!CanAffordAnAbility)
            return 'AA_ValueCheckFailed';
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