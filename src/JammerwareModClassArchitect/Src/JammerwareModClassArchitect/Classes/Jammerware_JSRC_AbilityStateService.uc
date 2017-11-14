class Jammerware_JSRC_AbilityStateService extends Object;

public static function ActivateAbility(XComGameState_Ability AbilityState)
{
    local GameRulesCache_Unit UnitCache;
	local int i, j;

    if(`TACTICALRULES.GetGameRulesCache_Unit(AbilityState.OwnerStateObject, UnitCache))
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

    `REDSCREEN("JSRC: Jammerware_JSRC_AbilityStateService couldn't activate ability" @ AbilityState.GetMyTemplateName());
}