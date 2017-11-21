// by the time i'd done enough hackery to make subclassing X2Effect_SpawnUnit even work for my case, i was using very little of it.
// decided just to go in my own direction
class JsrcEffect_SpawnSpire extends X2Effect;

var name NAME_SPAWN_SPIRE_TRIGGER;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Unit TargetUnitState;

	TargetUnitState = XComGameState_Unit(kNewTargetState);
	`assert(TargetUnitState != none);

	TriggerSpawnEvent(ApplyEffectParameters, TargetUnitState, NewGameState, NewEffectState);
}

simulated protected function TriggerSpawnEvent(const out EffectAppliedData ApplyEffectParameters, XComGameState_Unit EffectTargetUnit, XComGameState NewGameState, XComGameState_Effect EffectGameState)
{
	local XComGameState_Unit SourceUnitState, SpawnedUnit;
	local XComGameStateHistory History;
	local Jammerware_JSRC_UnitSpawnService UnitSpawnService;

	History = `XCOMHISTORY;
	UnitSpawnService = new class'Jammerware_JSRC_UnitSpawnService';

	SourceUnitState = XComGameState_Unit(History.GetGameStateForObjectID(ApplyEffectParameters.SourceStateObjectRef.ObjectID));

	// Spawn the new unit
	SpawnedUnit = UnitSpawnService.CreateUnit
	(
		SourceUnitState,
		GetSpawnLocation(ApplyEffectParameters, NewGameState),
		GetUnitToSpawnName(ApplyEffectParameters),
		SourceUnitState.GetTeam(),
		NewGameState
	);

	OnSpawnComplete(ApplyEffectParameters, SpawnedUnit, NewGameState);
}

function vector GetSpawnLocation(const out EffectAppliedData ApplyEffectParameters, XComGameState NewGameState)
{
	local vector SpawnLocation;
	local XComGameState_Unit TargetUnitGameState;

	TargetUnitGameState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));

	if (ApplyEffectParameters.SourceStateObjectRef.ObjectID != TargetUnitGameState.GetReference().ObjectID)
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

function OnSpawnComplete(const out EffectAppliedData ApplyEffectParameters, XComGameState_Unit SpireState, XComGameState NewGameState)
{
	local XComGameState_Unit ShooterState, TargetUnitGameState;
	local Jammerware_JSRC_SpireRegistrationService SpireRegistrationService;

	SpireRegistrationService = new class'Jammerware_JSRC_SpireRegistrationService';
	ShooterState = XComGameState_Unit(NewGameState.GetGameStateForObjectID(ApplyEffectParameters.SourceStateObjectRef.ObjectID));
	TargetUnitGameState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));

	// if spawnspire was cast on a unit (like it is when Headstone is used), remove that unit from play
	if (ApplyEffectParameters.SourceStateObjectRef.ObjectID != ApplyEffectParameters.TargetStateObjectRef.ObjectID)
	{
		`XEVENTMGR.TriggerEvent('UnitRemovedFromPlay', TargetUnitGameState, TargetUnitGameState, NewGameState);
	}

	// currently, all this does is log the last spire the architect created so we can examine it in the BuildGameState function for the abilities
	// that apply this effect. TODO: think about this
	SpireRegistrationService.RegisterSpireToArchitect(SpireState, ShooterState);

	// prevent spires from breaking squad concealment when they're summoned (unless they're on a naughty space)
	if (ShooterState.IsConcealed())
		SpireState.SetIndividualConcealment(true, NewGameState);

	// notify people who care about spires spawning
	`XEVENTMGR.TriggerEvent(default.NAME_SPAWN_SPIRE_TRIGGER, SpireState, ShooterState, NewGameState);
}

simulated function AddX2ActionsForVisualization(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata, const name EffectApplyResult)
{
	local XComGameStateContext_Ability AbilityContext;
	local XComGameState_Unit ShooterState, SpireState;
	local Jammerware_JSRC_SpireRegistrationService SpireRegistrationService;

	AbilityContext = XComGameStateContext_Ability(VisualizeGameState.GetContext());
	SpireRegistrationService = new class'Jammerware_JSRC_SpireRegistrationService';
	ShooterState = XComGameState_Unit(VisualizeGameState.GetGameStateForObjectID(AbilityContext.InputContext.SourceObject.ObjectID));
	SpireState = SpireRegistrationService.GetLastSpireFromRunner(ShooterState, VisualizeGameState);

	if (EffectApplyResult == 'AA_Success')
	{
		`LOG("JSRC: spire state is" @ SpireState.GetFullName());
		SpireState.SyncVisualizer(VisualizeGameState);		
		`LOG("JSRC: visualizer sync'd");
	}
}

DefaultProperties
{
	NAME_SPAWN_SPIRE_TRIGGER=Jammerware_JSRC_EventTrigger_SpireSpawn
}