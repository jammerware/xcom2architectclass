class X2Ability_TransmatLink extends X2Ability;

var name NAME_TRANSMAT_LINK;

static function X2DataTemplate CreateTransmatLink()
{
    local X2AbilityTemplate Template;
	local X2AbilityCost_ActionPoints APCost;
	local X2AbilityCooldown Cooldown;
	local X2Condition_UnitProperty TargetPropertiesCondition;
	local X2Condition_UnitType UnitTypeCondition;

	// general properties
	`CREATE_X2ABILITY_TEMPLATE(Template, default.NAME_TRANSMAT_LINK);
	Template.Hostility = eHostility_Neutral;

	// hud behavior
	Template.IconImage = "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_Exchange";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.bDisplayInUITacticalText = false;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_SERGEANT_PRIORITY;
	Template.bLimitTargetIcons = true;

	// cost
	APCost = new class'X2AbilityCost_ActionPoints';
	APCost.iNumPoints = 1;
	Template.AbilityCosts.AddItem(APCost);
	
	// Cooldown
	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = 5;
	Template.AbilityCooldown = Cooldown;

	// targeting style (how targets are determined by game rules)
	Template.AbilityTargetStyle = default.SimpleSingleTarget;

	// hit chance
	Template.AbilityToHitCalc = default.DeadEye;

	// conditions
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	// TODO: need to enforce that the spire target belongs to the ability source

	TargetPropertiesCondition = new class'X2Condition_UnitProperty';
	TargetPropertiesCondition.ExcludeHostileToSource = true;
	TargetPropertiesCondition.ExcludeFriendlyToSource = false;
	TargetPropertiesCondition.RequireSquadmates = true;
	TargetPropertiesCondition.ExcludeDead = true;
	Template.AbilityTargetConditions.AddItem(TargetPropertiesCondition);

	UnitTypeCondition = new class'X2Condition_UnitType';
	UnitTypeCondition.IncludeTypes.AddItem(class'X2Character_Spire'.default.NAME_CHARACTERGROUP_SPIRE);
	Template.AbilityTargetConditions.AddItem(UnitTypeCondition);

	// triggering
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	
	// game state and visualization
	Template.CinescriptCameraType = "Templar_Invert";
	Template.CustomFireAnim = 'HL_ExchangeStart';
	Template.BuildNewGameStateFn = TransmatLink_BuildGameState;
	Template.BuildVisualizationFn = TransmatLink_BuildVisualization;
	Template.bShowActivation = true;

	return Template;
}

static simulated function XComGameState TransmatLink_BuildGameState(XComGameStateContext Context)
{
	local XComGameStateContext_Ability AbilityContext;
	local XComGameState	NewGameState;
	local XComGameState_Unit ShooterUnit, TargetUnit;
	local XComGameState_Ability AbilityState;
	local XComGameState_Item WeaponState;
	local X2EventManager EventManager;
	local TTile ShooterDesiredLoc;
	local TTile TargetDesiredLoc;
	local XComWorldData WorldData;

	WorldData = `XWORLD;

	NewGameState = `XCOMHISTORY.CreateNewGameState(true, Context);
	AbilityContext = XComGameStateContext_Ability(NewGameState.GetContext());

	ShooterUnit = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', AbilityContext.InputContext.SourceObject.ObjectID));
	TargetUnit = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', AbilityContext.InputContext.PrimaryTarget.ObjectID));
	AbilityState = XComGameState_Ability(NewGameState.ModifyStateObject(class'XComGameState_Ability', AbilityContext.InputContext.AbilityRef.ObjectID));
	if (AbilityContext.InputContext.ItemObject.ObjectID > 0)
	{
		WeaponState = XComGameState_Item(NewGameState.ModifyStateObject(class'XComGameState_Item', AbilityContext.InputContext.ItemObject.ObjectID));
	}

    class'Jammerware_DebugUtils'.static.LogUnitLocation(ShooterUnit);
    class'Jammerware_DebugUtils'.static.LogUnitLocation(TargetUnit);

	ShooterDesiredLoc = TargetUnit.TileLocation;
	TargetDesiredLoc = ShooterUnit.TileLocation;

	ShooterDesiredLoc.Z = WorldData.GetFloorTileZ(ShooterDesiredLoc, true);
	TargetDesiredLoc.Z = WorldData.GetFloorTileZ(TargetDesiredLoc, true);

	ShooterUnit.SetVisibilityLocation(ShooterDesiredLoc);
	TargetUnit.SetVisibilityLocation(TargetDesiredLoc);

	EventManager = `XEVENTMGR;
	EventManager.TriggerEvent('ObjectMoved', ShooterUnit, ShooterUnit, NewGameState);
	EventManager.TriggerEvent('UnitMoveFinished', ShooterUnit, ShooterUnit, NewGameState);
	EventManager.TriggerEvent('ObjectMoved', TargetUnit, TargetUnit, NewGameState);
	EventManager.TriggerEvent('UnitMoveFinished', TargetUnit, TargetUnit, NewGameState);
	
	AbilityState.GetMyTemplate().ApplyCost(AbilityContext, AbilityState, ShooterUnit, WeaponState, NewGameState);

	return NewGameState;
}

simulated function TransmatLink_BuildVisualization(XComGameState VisualizeGameState)
{
	local XComGameStateHistory History;
	local XComGameStateContext_Ability Context;
	local StateObjectReference InteractingUnitRef;
	local VisualizationActionMetadata EmptyTrack, SourceTrack, TargetTrack;
    local XComGameState_Unit SourceUnit, TargetUnit;

	History = `XCOMHISTORY;
	Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());
	InteractingUnitRef = Context.InputContext.SourceObject;

    SourceUnit = XComGameState_Unit(VisualizeGameState.GetGameStateForObjectID(Context.InputContext.SourceObject.ObjectID));
    TargetUnit = XComGameState_Unit(VisualizeGameState.GetGameStateForObjectID(Context.InputContext.PrimaryTarget.ObjectID));

	//****************************************************************************************
	//Configure the visualization track for the source
	//****************************************************************************************
	SourceTrack = EmptyTrack;
	SourceTrack.StateObject_OldState = History.GetGameStateForObjectID(InteractingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
	SourceTrack.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(InteractingUnitRef.ObjectID);
	SourceTrack.VisualizeActor = History.GetVisualizer(InteractingUnitRef.ObjectID);

	//****************************************************************************************
	//Configure the visualization track for the target
	//****************************************************************************************
	InteractingUnitRef = Context.InputContext.PrimaryTarget;
	TargetTrack = EmptyTrack;
	TargetTrack.StateObject_OldState = History.GetGameStateForObjectID(InteractingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
	TargetTrack.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(InteractingUnitRef.ObjectID);
	TargetTrack.VisualizeActor = History.GetVisualizer(InteractingUnitRef.ObjectID);

    // Build the tracks
	class'X2Action_AbilityPerkStart'.static.AddToVisualizationTree(SourceTrack, Context, false, SourceTrack.LastActionAdded);
    class'X2Action_ShowSpawnedUnit'.static.AddToVisualizationTree(TargetTrack, Context);
	class'X2Action_AbilityPerkEnd'.static.AddToVisualizationTree(SourceTrack, Context, false, SourceTrack.LastActionAdded);

	// sync the visualizers - i think this makes sure the units will appear in the right place on the board
	SourceUnit.SyncVisualizer();
	TargetUnit.SyncVisualizer();
}

defaultproperties
{
    NAME_TRANSMAT_LINK=Jammerware_JSRC_Ability_TransmatLink;
}