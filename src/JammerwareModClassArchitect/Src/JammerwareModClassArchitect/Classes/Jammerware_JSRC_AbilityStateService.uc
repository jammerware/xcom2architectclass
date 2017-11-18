class Jammerware_JSRC_AbilityStateService extends Object;

public static function ActivateAbility(XComGameState_Ability AbilityState)
{
    local XComGameState GameState;
    local XComGameState_Unit OwnerState;
    local GameRulesCache_Unit UnitCache;
	local int i, j;
    local name Availability;

    GameState = AbilityState.GetParentGameState();
    OwnerState = XComGameState_Unit(GameState.GetGameStateForObjectID(AbilityState.OwnerStateObject.ObjectID));
    Availability = AbilityState.CanActivateAbility(OwnerState);

    if(`TACTICALRULES.GetGameRulesCache_Unit(AbilityState.OwnerStateObject, UnitCache) && AbilityState.CanActivateAbility(OwnerState) != 'AA_Success')
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