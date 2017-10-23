class X2Condition_SpireAdjacency extends X2Condition;

var name RequiredSpireEffect;

event name CallMeetsCondition(XComGameState_BaseObject kTarget) 
{
	local XComGameState_Unit TargetState;
    local Jammerware_ProximityService ProximityService;

    TargetState = XComGameState_Unit(kTarget);
    ProximityService = new class'Jammerware_ProximityService';

    if (ProximityService.IsUnitAdjacentToSpire(TargetState, RequiredSpireEffect))
    {
        return 'AA_Success';
    }

    return 'AA_NotInRange';
}