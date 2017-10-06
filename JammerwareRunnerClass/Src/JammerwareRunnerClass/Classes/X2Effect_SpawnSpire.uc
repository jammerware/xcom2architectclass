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
	local XComGameState_Unit SpireUnitGameState, SourceUnitGameState;
	
	SpireUnitGameState = XComGameState_Unit(NewGameState.GetGameStateForObjectID(NewUnitRef.ObjectID));
	`assert(SpireUnitGameState != none);

	SourceUnitGameState = XComGameState_Unit(NewGameState.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	if( SourceUnitGameState == none)
	{
		SourceUnitGameState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID, eReturnType_Reference));
	}
	`assert(SourceUnitGameState != none);

	// wire up the spire's abilities and effects based on the state of the shooting runner
	//ConfigureSpireFromSourceUnit(SourceUnitGameState, SpireUnitGameState, NewGameState);

	// spires provide low cover
	SpireUnitGameState.bGeneratesCover = true;
	SpireUnitGameState.CoverForceFlag = CoverForce_Low;
}

function ConfigureSpireFromSourceUnit(XComGameState_Unit SourceUnit, XComGameState_Unit SpireUnit, XComGameState NewGameState)
{
	if (GetIsUnitAffectedBy('Shelter', SourceUnit)) {
		//ZombieGameState.SetUnitFloatValue(TurnedZombieName, 1, eCleanup_BeginTactical);
		//SpireUnit.SetUnitFloatValue
	}
}

function bool GetIsUnitAffectedBy(name CheckEffectName, XComGameState_Unit Unit)
{
	local int LoopIndex;

	for (LoopIndex = 0; LoopIndex < Unit.AffectedByEffectNames.Length; LoopIndex++) {
		if (Unit.AffectedByEffectNames[LoopIndex] == CheckEffectName) {
			return true;
		}
	}

	return false;
}

defaultproperties
{
	UnitToSpawnName="Jammerware_JSRC_Character_Spire"
	bInfiniteDuration=true
	EffectName="SpawnSpire"
}