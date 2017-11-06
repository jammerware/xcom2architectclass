class X2Effect_SpirePassive extends X2Effect_GenerateCover;

function ModifyTurnStartActionPoints(XComGameState_Unit UnitState, out array<name> ActionPoints, XComGameState_Effect EffectState)
{
    ActionPoints.Length = 0;
}

DefaultProperties
{
	CoverType = CoverForce_High
	DuplicateResponse = eDupe_Ignore
	EffectName=Jammerware_JSRC_Effect_SpirePassive
	bRemoveWhenMoved = false
	bRemoveOnOtherActivation = false
}