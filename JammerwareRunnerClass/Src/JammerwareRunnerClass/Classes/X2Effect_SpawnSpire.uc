class X2Effect_SpawnSpire extends X2Effect_SpawnDestructible;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	super.OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);
	`LOG("Jammerware's Runner Class: on effect added - Spire" @ self.DestructibleArchetype);
}

simulated function bool OnEffectTicked(const out EffectAppliedData ApplyEffectParameters, XComGameState_Effect kNewEffectState, XComGameState NewGameState, bool FirstApplication, XComGameState_Player Player)
{
	`LOG("Jammerware's Runner Class: spire effect tick ");
	return true;
}

DefaultProperties
{
	EffectName = "Spire"
	DuplicateResponse = eDupe_Allow
	bCanTickEveryAction = true
	bDestroyOnRemoval = true
	bInfiniteDuration = true
}