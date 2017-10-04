class X2Effect_SpawnSpire extends X2Effect_SpawnUnit;

function vector GetSpawnLocation(const out EffectAppliedData ApplyEffectParameters, XComGameState NewGameState)
{
	return ApplyEffectParameters.AbilityInputContext.TargetLocations[0];
}

// Get the team that this unit should be added to
function ETeam GetTeam(const out EffectAppliedData ApplyEffectParameters)
{
	return GetSourceUnitsTeam(ApplyEffectParameters);
}

function OnSpawnComplete(const out EffectAppliedData ApplyEffectParameters, StateObjectReference NewUnitRef, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Unit SpireGameState, SourceUnitGameState;

	SpireGameState = XComGameState_Unit(NewGameState.GetGameStateForObjectID(NewUnitRef.ObjectID));
	`assert(SpireGameState != none);

	SourceUnitGameState = XComGameState_Unit(NewGameState.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	if( SourceUnitGameState == none)
	{
		SourceUnitGameState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID, eReturnType_Reference));
	}
	`assert(SourceUnitGameState != none);
}

function AddSpawnVisualizationsToTracks(XComGameStateContext Context, XComGameState_Unit SpawnedUnit, out VisualizationActionMetadata SpawnedUnitTrack,
										XComGameState_Unit EffectTargetUnit, optional out VisualizationActionMetadata EffectTargetUnitTrack)
{
	local X2Action_CreateDoppelganger CopyUnitAction;
	local XComGameStateHistory History;

	History = `XCOMHISTORY;

	// Copy the thrower unit's appearance to the mimic
	CopyUnitAction = X2Action_CreateDoppelganger(class'X2Action_CreateDoppelganger'.static.AddToVisualizationTree(SpawnedUnitTrack, Context));
	CopyUnitAction.OriginalUnit = XGUnit(History.GetVisualizer(EffectTargetUnit.ObjectID));
	CopyUnitAction.ShouldCopyAppearance = true;
	CopyUnitAction.bReplacingOriginalUnit = false;
	CopyUnitAction.bIgnorePose = true;
}

defaultproperties
{
	UnitToSpawnName="Spire"
	bCopyTargetAppearance=true
	bInfiniteDuration=true
	bKnockbackAffectsSpawnLocation=false
	EffectName="SpawnSpireUnit"
}