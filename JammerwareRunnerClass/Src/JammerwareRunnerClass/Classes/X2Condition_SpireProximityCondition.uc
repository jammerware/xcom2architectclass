class X2Condition_SpireProximityCondition extends X2Condition;

event name CallMeetsCondition(XComGameState_BaseObject kTarget) 
{ 
	local XComGameState_Unit SpireState, TargetState;
    local XComGameStateHistory History;
    local Jammerware_UnitProximityService UnitProximityService;

    History = `XCOMHISTORY;
    TargetState = XComGameState_Unit(kTarget);
    UnitProximityService = new class'Jammerware_UnitProximityService';

    // this seems like it could be really performance-intensive, but we'll c
    foreach History.IterateByClassType(class'XComGameState_Unit', SpireState)
	{
		if(SpireState.GetMyTemplateName() == class'X2Character_Spire'.default.NAME_CHARACTER_SPIRE)
		{
            if (UnitProximityService.AreAdjacent(SpireState, TargetState))
            {
                return 'AA_Success';
            }
		}
	}

    return 'AA_NotInRange';
}