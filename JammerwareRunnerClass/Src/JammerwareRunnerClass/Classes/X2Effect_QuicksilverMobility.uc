class X2Effect_QuicksilverMobility extends X2Effect_PersistentStatChange;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Unit TargetGameState;

	super.OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);
	`LOG("JSRC: quicksilver applied");
	TargetGameState = XComGameState_Unit(kNewTargetState);
	`LOG("JSRC: target mobility" @ TargetGameState.GetCurrentStat(eStat_Mobility));
}

defaultproperties 
{
	DuplicateResponse=eDupe_Refresh
	EffectName=Jammerware_JSRC_Effect_QuicksilverMobility    
}