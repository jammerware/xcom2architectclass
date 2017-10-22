class X2Condition_SpireProximityCondition extends X2Condition;

event name CallMeetsCondition(XComGameState_BaseObject kTarget) 
{
	local XComGameState_Unit TargetState;
    local Jammerware_ProximityService ProximityService;

    TargetState = XComGameState_Unit(kTarget);
    ProximityService = new class'Jammerware_ProximityService';

    if (ProximityService.IsUnitAdjacentToSpire(TargetState))
    {
        return 'AA_Success';
    }

    return 'AA_NotInRange';
}