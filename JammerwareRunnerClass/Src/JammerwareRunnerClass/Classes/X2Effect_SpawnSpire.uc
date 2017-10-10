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
	local XComGameState_Unit SpireUnitGameState;
	
	SpireUnitGameState = XComGameState_Unit(NewGameState.GetGameStateForObjectID(NewUnitRef.ObjectID));
	`assert(SpireUnitGameState != none);

	// spires provide low cover
	SpireUnitGameState.bGeneratesCover = true;
	SpireUnitGameState.CoverForceFlag = CoverForce_Low;

	// where'd it spawn?
	`LOG("JSRC: spawned at - " @ `XWORLD.GetPositionFromTileCoordinates( SpireUnitGameState.TileLocation ));
}

defaultproperties
{
	UnitToSpawnName="Jammerware_JSRC_Character_Spire"
	bInfiniteDuration=true
	EffectName="SpawnSpire"
}