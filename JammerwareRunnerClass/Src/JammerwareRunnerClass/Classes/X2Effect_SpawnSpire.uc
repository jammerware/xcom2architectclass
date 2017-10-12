class X2Effect_SpawnSpire extends X2Effect_SpawnUnit;

var bool bSpawnOnTargetUnitLocation;

function vector GetSpawnLocation(const out EffectAppliedData ApplyEffectParameters, XComGameState NewGameState)
{
	local vector SpawnLocation;
	local XComGameState_Unit TargetUnitGameState;

	if (bSpawnOnTargetUnitLocation) 
	{
		SpawnLocation = ApplyEffectParameters.AbilityInputContext.TargetLocations[0];
	}
	else
	{
		TargetUnitGameState = XComGameState_Unit(NewGameState.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));
		SpawnLocation = `XWorld.GetPositionFromTileCoordinates(TargetUnitGameState.TileLocation);
	}
	
	`LOG("JSRC: requested location - " @ ApplyEffectParameters.AbilityInputContext.TargetLocations[0]);
	`LOG("JSRC: locations length - " @ ApplyEffectParameters.AbilityInputContext.TargetLocations.Length);
	`LOG("JSRC: resulting location - " @ SpawnLocation);
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

	`LOG("JSRC: ---spawn complete---");
	`LOG("JSRC: source unit id" @ ApplyEffectParameters.SourceStateObjectRef.ObjectID);
	`LOG("JSRC: source template" @ SourceUnitGameState.GetMyTemplateName());
	`LOG("JSRC: target unit id" @ ApplyEffectParameters.TargetStateObjectRef.ObjectID);
	`LOG("JSRC: target template" @ TargetUnitGameState.GetMyTemplateName());
	`LOG("JSRC: new unit id" @ NewUnitRef.ObjectID);
	`LOG("JSRC: new unit template" @ SpireUnitGameState.GetMyTemplateName());
	`LOG("JSRC: ---end spawn complete---");

	// if spawnspire was cast on a target (like it is when Headstone is used), remove that unit from play
	if (ApplyEffectParameters.SourceStateObjectRef.ObjectID != ApplyEffectParameters.TargetStateObjectRef.ObjectID)
	{
		`LOG("JSRC: cleaning up existing unit for headstone");
		`XEVENTMGR.TriggerEvent('UnitRemovedFromPlay', TargetUnitGameState, TargetUnitGameState, NewGameState);
		`LOG("JSRC: done");
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

	// where'd it spawn?
	`LOG("JSRC: spawned at - " @ `XWORLD.GetPositionFromTileCoordinates( SpireUnitGameState.TileLocation ));
}

defaultproperties
{
	UnitToSpawnName=Jammerware_JSRC_Character_Spire
	bInfiniteDuration=true
	bSpawnOnTargetUnitLocation=false
	EffectName="SpawnSpire"
}