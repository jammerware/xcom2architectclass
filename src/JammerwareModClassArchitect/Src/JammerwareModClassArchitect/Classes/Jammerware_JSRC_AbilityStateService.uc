class Jammerware_JSRC_AbilityStateService extends Object;

public static function ActivateAbility(XComGameState_Ability AbilityState)
{
    local XComGameState GameState;
    local XComGameState_Unit OwnerState;
    local GameRulesCache_Unit UnitCache;
	local int i, j;

    GameState = AbilityState.GetParentGameState();
    OwnerState = XComGameState_Unit(GameState.GetGameStateForObjectID(AbilityState.OwnerStateObject.ObjectID));

    if(`TACTICALRULES.GetGameRulesCache_Unit(AbilityState.OwnerStateObject, UnitCache) && AbilityState.CanActivateAbility(OwnerState) == 'AA_Success')
    {
        for (i = 0; i < UnitCache.AvailableActions.Length; ++i)
        {
            if (UnitCache.AvailableActions[i].AbilityObjectRef.ObjectID == AbilityState.ObjectID
                && UnitCache.AvailableActions[i].AvailableTargets.Length > 0)
            {
                for (j = 0; j < UnitCache.AvailableActions[i].AvailableTargets.Length; ++j)
                {
                    class'XComGameStateContext_Ability'.static.ActivateAbility(UnitCache.AvailableActions[i], j);
                    return;
                }
            }
        }
    }
}

public function bool CanAffordNonActionPointCosts(XComGameState_Ability AbilityState)
{
    local X2AbilityCost Cost;
    local XComGameState_Unit ActivatingUnitState;
	local name AvailableCode;

	if (ActivatingUnitState == none)
		ActivatingUnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(AbilityState.OwnerStateObject.ObjectID));

	foreach AbilityState.GetMyTemplate().AbilityCosts(Cost)
	{
        if (!Cost.IsA('X2AbilityCost_ActionPoints'))
        {
            AvailableCode = Cost.CanAfford(AbilityState, ActivatingUnitState);
            if (AvailableCode != 'AA_Success')
                return false;
        }
	}
	return true;
}

public function array<XComGameState_Ability> GetActivatedAbilities(XComGameState_Unit UnitState)
{
    local XComGameStateHistory History;
    local StateObjectReference AbilityRefIterator;
    local XComGameState_Ability AbilityState;
    local X2AbilityTrigger TriggerIterator;
    local array<XComGameState_Ability> RetVal;

    History = `XCOMHISTORY;

    foreach UnitState.Abilities(AbilityRefIterator)
    {
        AbilityState = XComGameState_Ability(History.GetGameStateForObjectID(AbilityRefIterator.ObjectID));

        foreach AbilityState.GetMyTemplate().AbilityTriggers(TriggerIterator)
        {
            if (TriggerIterator.IsA('X2AbilityTrigger_PlayerInput'))
            {
                RetVal.AddItem(AbilityState);
                break;
            }
        }
    }

    return RetVal;
}