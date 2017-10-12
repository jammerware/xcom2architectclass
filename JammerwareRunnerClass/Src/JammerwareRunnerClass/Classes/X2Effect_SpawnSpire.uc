class X2Effect_SpawnSpire extends X2Effect_SpawnUnit;

function vector GetSpawnLocation(const out EffectAppliedData ApplyEffectParameters, XComGameState NewGameState)
{
	`LOG("JSRC: get spawn location - " @ ApplyEffectParameters.AbilityInputContext.TargetLocations[0]);
	return ApplyEffectParameters.AbilityInputContext.TargetLocations[0];
}

function ETeam GetTeam(const out EffectAppliedData ApplyEffectParameters)
{
	return GetSourceUnitsTeam(ApplyEffectParameters);
}

function OnSpawnComplete(const out EffectAppliedData ApplyEffectParameters, StateObjectReference NewUnitRef, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Unit SourceUnitGameState, SpireUnitGameState;
	local Jammerware_SpireSharedAbilitiesService SpireSharedAbilitiesService;
	local Jammerware_SpireRegistrationService SpireRegistrationService;
	
	SourceUnitGameState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	SpireUnitGameState = XComGameState_Unit(NewGameState.GetGameStateForObjectID(NewUnitRef.ObjectID));
	SpireSharedAbilitiesService = new class'Jammerware_SpireSharedAbilitiesService';
	SpireRegistrationService = new class'Jammerware_SpireRegistrationService';

	// not positive this is right. we need to track somewhere the soldier who created the spire, so we're putting it as a unit value on the spire for now
	SpireRegistrationService.RegisterSpireToRunner(SpireUnitGameState, SourceUnitGameState);

	// DANGER, WILL ROBINSON
	// i'm super unsure of this implementation, especially because it results in using the dreaded InitAbilityForUnit method, which is indicated as
	// pretty dangerous by Firaxis. if the soldier who spawns the spire has certain abilities, the spire gets them too
	SpireSharedAbilitiesService.ConfigureSpireAbilitiesFromSourceUnit(SpireUnitGameState, SourceUnitGameState, NewGameState);
	
	// spires provide low cover
	SpireUnitGameState.bGeneratesCover = true;
	SpireUnitGameState.CoverForceFlag = CoverForce_High;

	// where'd it spawn?
	`LOG("JSRC: spawned at - " @ `XWORLD.GetPositionFromTileCoordinates( SpireUnitGameState.TileLocation ));
}

defaultproperties
{
	UnitToSpawnName=Jammerware_JSRC_Character_Spire
	bInfiniteDuration=true
	EffectName="SpawnSpire"
}