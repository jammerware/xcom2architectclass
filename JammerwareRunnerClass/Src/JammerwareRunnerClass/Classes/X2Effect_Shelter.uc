class X2Effect_Shelter extends X2Effect_PersistentStatChange;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	`LOG("JSRC: shelter added");
}

DefaultProperties {
	EffectName = "ShelterTrigger";
}