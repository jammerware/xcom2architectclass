class X2Effect_SpawnSpire extends X2Effect_SpawnUnit;

function vector GetSpawnLocation(const out EffectAppliedData ApplyEffectParameters, XComGameState NewGameState)
{
	return ApplyEffectParameters.AbilityInputContext.TargetLocations[0];
}

function ETeam GetTeam(const out EffectAppliedData ApplyEffectParameters)
{
	return GetSourceUnitsTeam(ApplyEffectParameters);
}

function OnSpawnComplete(const out EffectAppliedData ApplyEffectParameters, StateObjectReference NewUnitRef, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Unit SpireGameState, SourceUnitGameState;
	local GameRulesCache_Unit UnitCache;
	
	SpireGameState = XComGameState_Unit(NewGameState.GetGameStateForObjectID(NewUnitRef.ObjectID));
	`assert(SpireGameState != none);

	SourceUnitGameState = XComGameState_Unit(NewGameState.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	if( SourceUnitGameState == none)
	{
		SourceUnitGameState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID, eReturnType_Reference));
	}
	`assert(SourceUnitGameState != none);

	// spires provide low cover
	SpireGameState.bGeneratesCover = true;
	SpireGameState.CoverForceFlag = CoverForce_Low;

	`TACTICALRULES.GetGameRulesCache_Unit(SpireGameState.GetReference(), UnitCache);

	// what is happening
	`LOG("JSRC: Spire spawned | actions? " @ UnitCache.bAnyActionsAvailable);
}

defaultproperties
{
	UnitToSpawnName="Jammerware_JSRC_Spire"
	bInfiniteDuration=true
	EffectName="SpawnSpire"
}