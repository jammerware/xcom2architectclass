class X2Effect_SpawnSpire extends X2Effect_SpawnUnit;

function vector GetSpawnLocation(const out EffectAppliedData ApplyEffectParameters, XComGameState NewGameState)
{
	local vector SpawnLocation;
	local XComGameState_Unit SourceUnitGameState, TargetUnitGameState;

	SourceUnitGameState = XComGameState_Unit(NewGameState.GetGameStateForObjectID(ApplyEffectParameters.SourceStateObjectRef.ObjectID));
	TargetUnitGameState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));

	if (SourceUnitGameState.GetReference().ObjectID != TargetUnitGameState.GetReference().ObjectID)
	{
		// if this effect is cast on a target (like it is when Headstone is used), use the location of the target unit
		SpawnLocation = `XWorld.GetPositionFromTileCoordinates(TargetUnitGameState.TileLocation);
	}
	else
	{
		// otherwise, use user input location
		SpawnLocation = ApplyEffectParameters.AbilityInputContext.TargetLocations[0];
	}
	
	return SpawnLocation;
}

function ETeam GetTeam(const out EffectAppliedData ApplyEffectParameters)
{
	return GetSourceUnitsTeam(ApplyEffectParameters);
}

function OnSpawnComplete(const out EffectAppliedData ApplyEffectParameters, StateObjectReference NewUnitRef, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Unit SourceUnitGameState, SpireUnitGameState, TargetUnitGameState;
	local Jammerware_SpireSharedAbilitiesService SpireSharedAbilitiesService;
	local Jammerware_SpireRegistrationService SpireRegistrationService;
	
	SpireSharedAbilitiesService = new class'Jammerware_SpireSharedAbilitiesService';
	SpireRegistrationService = new class'Jammerware_SpireRegistrationService';
	SourceUnitGameState = XComGameState_Unit(NewGameState.GetGameStateForObjectID(ApplyEffectParameters.SourceStateObjectRef.ObjectID));
	SpireUnitGameState = XComGameState_Unit(NewGameState.GetGameStateForObjectID(NewUnitRef.ObjectID));
	TargetUnitGameState = XComGameState_Unit(NewGameState.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));

	// if spawnspire was cast on a unit (like it is when Headstone is used), remove that unit from play
	if (ApplyEffectParameters.SourceStateObjectRef.ObjectID != ApplyEffectParameters.TargetStateObjectRef.ObjectID)
	{
		`XEVENTMGR.TriggerEvent('UnitRemovedFromPlay', TargetUnitGameState, TargetUnitGameState, NewGameState);
	}

	// TODO: look at X2Effect_SpawnPsiZombie to track relationship between runner and spire. this'll let us have a buff on the spire indicating the relationship if we want
	// (not to mention it's less gross)
	SpireRegistrationService.RegisterSpireToRunner(SpireUnitGameState, SourceUnitGameState);

	// DANGER, WILL ROBINSON
	// i'm super unsure of this implementation, especially because it results in using the dreaded InitAbilityForUnit method, which is indicated as
	// pretty dangerous by Firaxis. if the soldier who spawns the spire has certain abilities, the spire gets them too
	SpireSharedAbilitiesService.ConfigureSpireAbilitiesFromSourceUnit(SpireUnitGameState, SourceUnitGameState, NewGameState);
	
	// spires provide high cover
	SpireUnitGameState.bGeneratesCover = true;
	SpireUnitGameState.CoverForceFlag = CoverForce_High;

	`LOG("JSRC: Effect history frame -" @ `XCOMHISTORY.GetCurrentHistoryIndex());
	`LOG("JSRC: new game state frame -" @ NewGameState.HistoryIndex);
	`LOG("JSRC: end of OnEffectApplied for the spire");
	class'Jammerware_DebugUtils'.static.LogUnitLocation(SpireUnitGameState);
}

defaultproperties
{
	UnitToSpawnName=Jammerware_JSRC_Character_Spire
	bInfiniteDuration=true
	EffectName="SpawnSpire"
}