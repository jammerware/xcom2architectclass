class JsrcAbility_Headstone extends X2Ability
	config(JammerwareModClassArchitect);

var name NAME_ABILITY;
var config int HEADSTONE_COOLDOWN;

public static function array<X2DataTemplate> CreateTemplates()
{
    local array<X2DataTemplate> Templates;
    Templates.AddItem(CreateHeadstone());
    return Templates;
}

private static function X2AbilityTemplate CreateHeadstone()
{
	local X2AbilityTemplate Template;
	local X2AbilityCooldown Cooldown;
	local X2Condition_UnitProperty DeadEnemiesCondition;
	local X2Effect_SpawnSpire SpawnSpireEffect;

	// general properties
	`CREATE_X2ABILITY_TEMPLATE(Template, default.NAME_ABILITY);
	Template.Hostility = eHostility_Neutral;

	// hud behavior
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_poisonspit";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.bDisplayInUITacticalText = false;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_SERGEANT_PRIORITY;
	Template.bLimitTargetIcons = true;

	// cost
	Template.AbilityCosts.AddItem(default.FreeActionCost);

	// Cooldown
	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.HEADSTONE_COOLDOWN;
	Template.AbilityCooldown = Cooldown;

	// targeting style (how targets are determined by game rules)
	Template.AbilityTargetStyle = default.SimpleSingleTarget;

	// targeting method (how the user chooses a target based on the rules)
	Template.TargetingMethod = class'X2TargetingMethod_TopDownTileHighlight';

	// hit chance
	Template.AbilityToHitCalc = default.DeadEye;

	// conditions
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AbilityTargetConditions.AddItem(default.GameplayVisibilityCondition);

	DeadEnemiesCondition = new class 'X2Condition_UnitProperty';
	DeadEnemiesCondition.ExcludeAlive = true;
	DeadEnemiesCondition.ExcludeDead = false;
	DeadEnemiesCondition.ExcludeHostileToSource = false;
	DeadEnemiesCondition.FailOnNonUnits = true;
	Template.AbilityTargetConditions.AddItem(DeadEnemiesCondition);

	// triggering
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	
	// effects
	SpawnSpireEffect = new class'X2Effect_SpawnSpire';
	SpawnSpireEffect.BuildPersistentEffect(1, true, true);
	SpawnSpireEffect.bClearTileBlockedByTargetUnitFlag = true;
	Template.AddTargetEffect(SpawnSpireEffect);
	
	// game state and visualization
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = Headstone_BuildVisualization;
	Template.bShowActivation = true;

	return Template;
}

private static function Headstone_BuildVisualization(XComGameState VisualizeGameState)
{
	local XComGameStateHistory History;
	local XComGameStateContext_Ability Context;
	local StateObjectReference InteractingUnitRef;

	local VisualizationActionMetadata EmptyTrack;
	local VisualizationActionMetadata ShooterTrack, DeadUnitTrack, SpawnedUnitTrack;
	local XComGameState_Unit SpawnedUnit, DeadUnit;

	local UnitValue SpawnedUnitValue;
	local X2Effect_SpawnSpire SpawnSpireEffect;

	History = `XCOMHISTORY;

	Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());
	InteractingUnitRef = Context.InputContext.SourceObject;

	// Configure the visualization track for the shooter
	//****************************************************************************************
	ShooterTrack = EmptyTrack;
	ShooterTrack.StateObject_OldState = History.GetGameStateForObjectID(InteractingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
	ShooterTrack.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(InteractingUnitRef.ObjectID);
	ShooterTrack.VisualizeActor = History.GetVisualizer(InteractingUnitRef.ObjectID);

	// Configure the visualization track for the dead guy
	//******************************************************************************************
	DeadUnitTrack.StateObject_OldState = History.GetGameStateForObjectID(Context.InputContext.PrimaryTarget.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex);
	DeadUnitTrack.StateObject_NewState = DeadUnitTrack.StateObject_OldState;
	DeadUnit = XComGameState_Unit(VisualizeGameState.GetGameStateForObjectID(Context.InputContext.PrimaryTarget.ObjectID));
	`assert(DeadUnit != none);
	DeadUnitTrack.VisualizeActor = History.GetVisualizer(DeadUnit.ObjectID);

	// Get the ObjectID for the SpawnedUnit created from the DeadUnit
	DeadUnit.GetUnitValue(class'X2Effect_SpawnUnit'.default.SpawnedUnitValueName, SpawnedUnitValue);

	SpawnedUnitTrack = EmptyTrack;
	SpawnedUnitTrack.StateObject_OldState = History.GetGameStateForObjectID(SpawnedUnitValue.fValue, eReturnType_Reference, VisualizeGameState.HistoryIndex);
	SpawnedUnitTrack.StateObject_NewState = SpawnedUnitTrack.StateObject_OldState;
	SpawnedUnit = XComGameState_Unit(SpawnedUnitTrack.StateObject_NewState);
	`assert(SpawnedUnit != none);
	SpawnedUnitTrack.VisualizeActor = History.GetVisualizer(SpawnedUnit.ObjectID);

	// Only one target effect and it is X2Effect_SpawnSpire
	SpawnSpireEffect = X2Effect_SpawnSpire(Context.ResultContext.TargetEffectResults.Effects[0]);

	if( SpawnSpireEffect == none )
	{
		`RedScreenOnce("Headstone_BuildVisualization: Missing X2Effect_SpawnSpire");
		return;
	}

	// Build the tracks
	class'X2Action_ExitCover'.static.AddToVisualizationTree(ShooterTrack, Context, false, ShooterTrack.LastActionAdded);
	class'X2Action_AbilityPerkStart'.static.AddToVisualizationTree(ShooterTrack, Context, false, ShooterTrack.LastActionAdded);

	SpawnSpireEffect.AddSpawnVisualizationsToTracks(Context, SpawnedUnit, SpawnedUnitTrack, DeadUnit, DeadUnitTrack);

	class'X2Action_AbilityPerkEnd'.static.AddToVisualizationTree(ShooterTrack, Context, false, ShooterTrack.LastActionAdded);
	class'X2Action_EnterCover'.static.AddToVisualizationTree(ShooterTrack, Context, false, ShooterTrack.LastActionAdded);

	// sync the spire's visualizer to ensure cover status is reflected
	SpawnedUnit.SyncVisualizer();
}

DefaultProperties
{
    NAME_ABILITY=Jammerware_JSRC_Ability_Headstone
}