class X2Effect_SpawnSpire extends X2Effect_SpawnUnit;

var bool bSpawnOnTargetUnitLocation;

function TriggerSpawnEvent(const out EffectAppliedData ApplyEffectParameters, XComGameState_Unit EffectTargetUnit, XComGameState NewGameState, XComGameState_Effect EffectGameState)
{
	local XComGameState_Unit SourceUnitState, TargetUnitState, SpawnedUnit, CopiedUnit, ModifiedEffectTargetUnit;
	local XComGameStateHistory History;
	local XComAISpawnManager SpawnManager;
	local StateObjectReference NewUnitRef;
	local XComWorldData World;
	local XComGameState_AIGroup GroupState;

	History = `XCOMHISTORY;
	SpawnManager = `SPAWNMGR;
	World = `XWORLD;

	TargetUnitState = XComGameState_Unit(History.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	if( TargetUnitState == none )
	{
		`RedScreen("TargetUnitState in X2Effect_SpawnUnit::TriggerSpawnEvent does not exist. @dslonneger");
		return;
	}
	SourceUnitState = XComGameState_Unit(History.GetGameStateForObjectID(ApplyEffectParameters.SourceStateObjectRef.ObjectID));

	if( bClearTileBlockedByTargetUnitFlag )
	{
		World.ClearTileBlockedByUnitFlag(TargetUnitState);
	}

	if( bCopyTargetAppearance )
	{
		CopiedUnit = TargetUnitState;
	}
	else if ( bCopySourceAppearance )
	{
		CopiedUnit = SourceUnitState;
	}

	// Spawn the new unit
	NewUnitRef = SpawnManager.CreateUnit(
		GetSpawnLocation(ApplyEffectParameters, NewGameState), 
		GetUnitToSpawnName(ApplyEffectParameters), 
		GetTeam(ApplyEffectParameters), 
		false, 
		false, 
		NewGameState, 
		CopiedUnit, 
		, 
		, 
		bCopyReanimatedFromUnit,
		-1,
		bCopyReanimatedStatsFromUnit);

	SpawnedUnit = XComGameState_Unit(NewGameState.GetGameStateForObjectID(NewUnitRef.ObjectID));
	SpawnedUnit.bTriggerRevealAI = !bSetProcessedScamperAs;
	`LOG("JSRC: spawned unit out of the spawn manager");
	class'Jammerware_DebugUtils'.static.LogUnitLocation(SpawnedUnit);

	// Don't allow scamper
	GroupState = SpawnedUnit.GetGroupMembership(NewGameState);
	if( GroupState != None )
	{
		GroupState = XComGameState_AIGroup(NewGameState.ModifyStateObject(class'XComGameState_AIGroup', GroupState.ObjectID));
		GroupState.bProcessedScamper = bSetProcessedScamperAs;
	}

	ModifiedEffectTargetUnit = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', EffectTargetUnit.ObjectID));
	ModifiedEffectTargetUnit.SetUnitFloatValue('SpawnedUnitValue', NewUnitRef.ObjectID, eCleanup_Never);
	ModifiedEffectTargetUnit.SetUnitFloatValue('SpawnedThisTurnUnitValue', NewUnitRef.ObjectID, eCleanup_BeginTurn);

	EffectGameState.CreatedObjectReference = SpawnedUnit.GetReference();

	OnSpawnComplete(ApplyEffectParameters, NewUnitRef, NewGameState, EffectGameState);
}

function vector GetSpawnLocation(const out EffectAppliedData ApplyEffectParameters, XComGameState NewGameState)
{
	local vector SpawnLocation;
	local XComGameState_Unit SourceUnitGameState, TargetUnitGameState;

	SourceUnitGameState = XComGameState_Unit(NewGameState.GetGameStateForObjectID(ApplyEffectParameters.SourceStateObjectRef.ObjectID));
	TargetUnitGameState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));

	if (SourceUnitGameState.GetReference().ObjectID != TargetUnitGameState.GetReference().ObjectID)
	{
		SpawnLocation = `XWorld.GetPositionFromTileCoordinates(TargetUnitGameState.TileLocation);
	}
	else
	{
		SpawnLocation = ApplyEffectParameters.AbilityInputContext.TargetLocations[0];
	}
	
	`LOG("JSRC: resulting location -" @ SpawnLocation);
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

	`LOG("JSRC: end of OnEffectApplied for the spire");
	class'Jammerware_DebugUtils'.static.LogUnitLocation(SpireUnitGameState);
}

defaultproperties
{
	UnitToSpawnName=Jammerware_JSRC_Character_Spire
	bInfiniteDuration=true
	bSpawnOnTargetUnitLocation=false
	EffectName="SpawnSpire"
}