class X2Ability_SpawnSpire extends X2Ability
    config(JammerwareRunnerClass);

var config int SPAWNSPIRE_COOLDOWN;
var name NAME_SPAWN_SPIRE;

static function X2DataTemplate CreateSpawnSpire()
{
	local X2AbilityTemplate Template;
	local X2AbilityCost_ActionPoints ActionPointCost;
	local X2AbilityCooldown Cooldown;
	local X2AbilityTarget_Cursor CursorTarget;
	local X2Effect_SpawnSpire SpawnSpireEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, default.NAME_SPAWN_SPIRE);

	// hud behavior
	Template.IconImage = "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_Pillar";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.Hostility = eHostility_Neutral;
	Template.bDisplayInUITacticalText = false;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_SQUADDIE_PRIORITY;

	// costs
	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPointCost);

	// cooldown
	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.SPAWNSPIRE_COOLDOWN;
	Template.AbilityCooldown = Cooldown;

	Template.AbilityToHitCalc = default.DeadEye;

	// conditions
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	// triggers
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	// targeting
	CursorTarget = new class'X2AbilityTarget_Cursor';
	CursorTarget.FixedAbilityRange = 5 * class'XComWorldData'.const.WORLD_Melee_Range_Meters;
	Template.AbilityTargetStyle = CursorTarget;
	Template.TargetingMethod = class'X2TargetingMethod_SpawnSpire';

	// effects
	SpawnSpireEffect = new class'X2Effect_SpawnSpire';
	SpawnSpireEffect.BuildPersistentEffect(1, true);
	Template.AddShooterEffect(SpawnSpireEffect);

	// game state and visualization
	Template.BuildNewGameStateFn = SpawnSpire_BuildGameState;
	Template.BuildVisualizationFn = SpawnSpire_BuildVisualization;
	Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.NonAggressiveChosenActivationIncreasePerUse;
		
	return Template;
}

// i had to build my own gamestate building function, because TypicalAbility_BuildGameState was changing the position of 
// the spire. no idea why. it's on my list.
static simulated function XComGameState SpawnSpire_BuildGameState(XComGameStateContext Context)
{
	local Jammerware_SpireRegistrationService SpireRegistrationService;
	local XComGameState NewGameState;
	local XComGameState_Unit ShooterState, SpireState;
	local XComGameStateContext_Ability AbilityContext;
	local vector NewLocation;
	local TTile NewTileLocation;
	local XComWorldData World;

	World = `XWORLD;
	SpireRegistrationService = new class'Jammerware_SpireRegistrationService';

	//Build the new game state frame
	NewGameState = TypicalAbility_BuildGameState(Context);

	AbilityContext = XComGameStateContext_Ability(NewGameState.GetContext());	
	ShooterState = XComGameState_Unit(NewGameState.GetGameStateForObjectID(AbilityContext.InputContext.SourceObject.ObjectID));
	SpireState = SpireRegistrationService.GetLastSpireFromRunner(ShooterState, NewGameState);

	// we're going to modify the spire state's position
	SpireState = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', SpireState.ObjectID));
	
	// Set the spire's location
	NewLocation = AbilityContext.InputContext.TargetLocations[0];
	NewTileLocation = World.GetTileCoordinatesFromPosition(NewLocation);
	SpireState.SetVisibilityLocation(NewTileLocation);

	// Return the game state we maded
	return NewGameState;
}

simulated function SpawnSpire_BuildVisualization(XComGameState VisualizeGameState)
{
	local XComGameStateHistory History;
	local XComGameStateContext_Ability Context;
	local StateObjectReference InteractingUnitRef;
	local Jammerware_SpireRegistrationService SpireRegistrationService;
	local VisualizationActionMetadata EmptyTrack;
	local VisualizationActionMetadata ShooterTrack, SpawnedUnitTrack;
	local XComGameState_Unit ShooterUnit, SpawnedUnit;
	local X2Effect_SpawnSpire SpawnSpireEffect;

	History = `XCOMHISTORY;
	Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());
	InteractingUnitRef = Context.InputContext.SourceObject;
	SpireRegistrationService = new class'Jammerware_SpireRegistrationService';

	// find the shooter and the spire
	ShooterUnit = XComGameState_Unit(VisualizeGameState.GetGameStateForObjectID(InteractingUnitRef.ObjectID));
	SpawnedUnit = SpireRegistrationService.GetLastSpireFromRunner(ShooterUnit, VisualizeGameState);

	// Configure the visualization track for the shooter
	//****************************************************************************************
	ShooterTrack = EmptyTrack;
	ShooterTrack.StateObject_OldState = History.GetGameStateForObjectID(InteractingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
	ShooterTrack.StateObject_NewState = ShooterUnit;
	ShooterTrack.VisualizeActor = History.GetVisualizer(InteractingUnitRef.ObjectID);

	// Configure the visualization track for the spire
	//****************************************************************************************
	SpawnedUnitTrack = EmptyTrack;
	SpawnedUnitTrack.StateObject_OldState = SpawnedUnit;
	SpawnedUnitTrack.StateObject_NewState = SpawnedUnit;
	SpawnedUnitTrack.VisualizeActor = History.GetVisualizer(SpawnedUnit.ObjectID);

	// Only one target effect and it is X2Effect_SpawnSpire
	SpawnSpireEffect = X2Effect_SpawnSpire(Context.ResultContext.ShooterEffectResults.Effects[0]);

	if (SpawnSpireEffect == none)
	{
		`RedScreen("SpawnSpire_BuildVisualization: Missing X2Effect_SpawnSpire");
		return;
	}

	// Build the tracks
	class'X2Action_ExitCover'.static.AddToVisualizationTree(ShooterTrack, Context, false, ShooterTrack.LastActionAdded);
	class'X2Action_AbilityPerkStart'.static.AddToVisualizationTree(ShooterTrack, Context, false, ShooterTrack.LastActionAdded);

	SpawnSpireEffect.AddSpawnVisualizationsToTracks(Context, SpawnedUnit, SpawnedUnitTrack, none);

	class'X2Action_AbilityPerkEnd'.static.AddToVisualizationTree(ShooterTrack, Context, false, ShooterTrack.LastActionAdded);
	class'X2Action_EnterCover'.static.AddToVisualizationTree(ShooterTrack, Context, false, ShooterTrack.LastActionAdded);

	// doing this here (to update the unit's cover status) and not in the effect apply seems to fix an intermittent crash
	//SpawnedUnit.SyncVisualizer();
}

defaultproperties
{
    NAME_SPAWN_SPIRE=Jammerware_JSRC_Ability_SpawnSpire
}