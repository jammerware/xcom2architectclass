class X2Effect_SpawnSpire extends X2Effect_SpawnDestructible;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	super.OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);
	`LOG("Jammerware's Runner Class: on effect added - Spire" @ self.DestructibleArchetype);
}

DefaultProperties
{
	EffectName = "Spire"
	DuplicateResponse = eDupe_Allow
	bDestroyOnRemoval = true
	bInfiniteDuration = true
}