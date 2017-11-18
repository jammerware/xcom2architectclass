class X2Effect_SpawnSpire extends X2Effect_SpawnUnit;

var name NAME_SPAWN_SPIRE_TRIGGER;

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

function name GetUnitToSpawnName(const out EffectAppliedData ApplyEffectParameters)
{
	local XComGameStateHistory History;
	local XComGameState_Item SourceWeaponState;
	local name SourceWeaponTemplateName;
	
	History = `XCOMHISTORY;
	SourceWeaponState = XComGameState_Item(History.GetGameStateForObjectID(ApplyEffectParameters.ItemStateObjectRef.ObjectID));
	SourceWeaponTemplateName = SourceWeaponState.GetMyTemplateName();

	// i'd love to somehow attach the name of the spire to summon to each individual weapon in config, but stuck with this for now
	switch (SourceWeaponTemplateName) 
	{
		case class'X2Item_SpireGun'.default.NAME_SPIREGUN_MAGNETIC: return class'X2Character_Spire'.default.NAME_CHARACTER_SPIRE_MAGNETIC;
		case class'X2Item_SpireGun'.default.NAME_SPIREGUN_BEAM: return class'X2Character_Spire'.default.NAME_CHARACTER_SPIRE_BEAM;
		default: return class'X2Character_Spire'.default.NAME_CHARACTER_SPIRE_CONVENTIONAL;
	}
}

function ETeam GetTeam(const out EffectAppliedData ApplyEffectParameters)
{
	return GetSourceUnitsTeam(ApplyEffectParameters);
}

function OnSpawnComplete(const out EffectAppliedData ApplyEffectParameters, StateObjectReference NewUnitRef, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Unit ShooterState, SpireState, TargetUnitGameState;
	local Jammerware_JSRC_SpireRegistrationService SpireRegistrationService;

	SpireRegistrationService = new class'Jammerware_JSRC_SpireRegistrationService';
	ShooterState = XComGameState_Unit(NewGameState.GetGameStateForObjectID(ApplyEffectParameters.SourceStateObjectRef.ObjectID));
	SpireState = XComGameState_Unit(NewGameState.GetGameStateForObjectID(NewUnitRef.ObjectID));
	TargetUnitGameState = XComGameState_Unit(NewGameState.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));

	// if spawnspire was cast on a unit (like it is when Headstone is used), remove that unit from play
	if (ApplyEffectParameters.SourceStateObjectRef.ObjectID != ApplyEffectParameters.TargetStateObjectRef.ObjectID)
	{
		`XEVENTMGR.TriggerEvent('UnitRemovedFromPlay', TargetUnitGameState, TargetUnitGameState, NewGameState);
	}

	SpireRegistrationService.RegisterSpireToRunner(ApplyEffectParameters, NewUnitRef, NewGameState, NewEffectState);

	// prevent spires from breaking squad concealment when they're summoned (unless they're on a naughty space)
	if (ShooterState.IsConcealed())
		SpireState.SetIndividualConcealment(true, NewGameState);

	// NO ACTION FOR YOU
	// the spire passive effect stops the spire from gaining AP on each turn after this, but we need to make sure it
	// doesn't get any this turn
	SpireState.ActionPoints.Length = 0;

	// notify people who care about spires spawning
	`XEVENTMGR.TriggerEvent(default.NAME_SPAWN_SPIRE_TRIGGER, SpireState, ShooterState, NewGameState);
}

simulated function AddX2ActionsForVisualization(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata, const name EffectApplyResult)
{
	local XComGameStateContext_Ability AbilityContext;
	local XComGameState_Unit ShooterState, SpireState;
	local Jammerware_JSRC_SpireRegistrationService SpireRegistrationService;

	if (EffectApplyResult == 'AA_Success')
	{
		SpireRegistrationService = new class'Jammerware_JSRC_SpireRegistrationService';
		AbilityContext = XComGameStateContext_Ability(VisualizeGameState.GetContext());
		ShooterState = XComGameState_Unit(VisualizeGameState.GetGameStateForObjectID(AbilityContext.InputContext.SourceObject.ObjectID));
		SpireState = SpireRegistrationService.GetLastSpireFromRunner(ShooterState, VisualizeGameState);

		AddSpawnVisualizationsToTracks(AbilityContext, SpireState, ActionMetadata, none);

		// sync the visualizer to make sure the new spire shows up
		SpireState.SyncVisualizer();
	}
}

DefaultProperties
{
	bInfiniteDuration=true
	EffectName=Jammerware_JSRC_Effect_SpawnSpire
	NAME_SPAWN_SPIRE_TRIGGER=Jammerware_JSRC_EventTrigger_SpireSpawn
}