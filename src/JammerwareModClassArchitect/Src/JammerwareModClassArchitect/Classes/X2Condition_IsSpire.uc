class X2Condition_IsSpire extends X2Condition;

var bool AllowSotA;
var bool IsNegated;

event name CallMeetsCondition(XComGameState_BaseObject kTarget) 
{ 
    local Jammerware_JSRC_SpireService SpireService;
	local XComGameState_Unit UnitState;

    SpireService = new class'Jammerware_JSRC_SpireService';
	UnitState = XComGameState_Unit(kTarget);
    
    if (UnitState == none)
        return 'AA_ValueCheckFailed';

	if (IsNegated ^^ SpireService.IsSpire(UnitState, AllowSotA))
        return 'AA_Success';

	return 'AA_UnitIsWrongType';
}