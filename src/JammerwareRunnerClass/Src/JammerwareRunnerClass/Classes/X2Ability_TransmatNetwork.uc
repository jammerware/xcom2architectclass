class X2Ability_TransmatNetwork extends X2Ability;

var name NAME_TRANSMAT;
var name NAME_TRANSMATNETWORK;
var name NAME_SPIRETRANSMATNETWORK;

var string ICON_TRANSMATNETWORK;

static function array <X2DataTemplate> CreateTemplates()
{
    local array<X2DataTemplate> Templates;

    // the runner and spire abilities are added by their ability set files
    Templates.AddItem(CreateTransmat());

    return Templates;
}

static function X2DataTemplate CreateRunnerTransmatNetwork()
{
    return PurePassive(default.NAME_TRANSMATNETWORK, default.ICON_TRANSMATNETWORK);
}

static function X2DataTemplate CreateSpireTransmatNetwork()
{
	local X2AbilityTemplate Template;
	local X2Condition_BeASpireOrHaveSoulAnd SotACondition;

	SotACondition = new class'X2Condition_BeASpireOrHaveSoulAnd';
	SotACondition.RequiredRunnerAbility = default.NAME_TRANSMATNETWORK;

	Template = PurePassive(default.NAME_SPIRETRANSMATNETWORK, default.ICON_TRANSMATNETWORK);
	Template.AbilityTargetConditions.AddItem(SotACondition);

    return Template;
}

static function X2AbilityTemplate CreateTransmat()
{
	local X2AbilityTemplate Template;
	local X2AbilityCost_ActionPoints ActionPointCost;
	local X2AbilityCooldown_Global Cooldown;
	local X2Condition_AllyAdjacency SpireAdjacencyCondition;

	// general properties
	`CREATE_X2ABILITY_TEMPLATE(Template, default.NAME_TRANSMAT);
	Template.Hostility = eHostility_Neutral;

	// hud behavior
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_ShowIfAvailable;
	Template.IconImage = default.ICON_TRANSMATNETWORK;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.UNSPECIFIED_PRIORITY;
	Template.bDontDisplayInAbilitySummary = true;
	Template.AbilityIconColor = class'Jammerware_JSRC_IconColorService'.static.GetSpireAbilityIconColor();

	// cost
	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	Template.AbilityCosts.AddItem(ActionPointCost);

	// cooldown
	Cooldown = new class'X2AbilityCooldown_Global';
	Cooldown.iNumTurns = 1;
	Template.AbilityCooldown = Cooldown;

	// conditions
    Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	// we intentionally don't restrict the ally to spires, because the architect can have it via soul of the architect
	SpireAdjacencyCondition = new class'X2Condition_AllyAdjacency';
	SpireAdjacencyCondition.RequireAllyEffect = default.NAME_SPIRETRANSMATNETWORK;
	Template.AbilityShooterConditions.AddItem(SpireAdjacencyCondition);

	// targeting style (how targets are determined by game rules)
	Template.AbilityTargetStyle = new class'X2AbilityTarget_Cursor';
	Template.TargetingMethod = class'X2TargetingMethod_Transmat';

	// hit chance
	Template.AbilityToHitCalc = default.DeadEye;

	// triggering
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	
	// game state and visualization
	Template.BuildNewGameStateFn = Transmat_BuildGameState;
	Template.BuildVisualizationFn = Transmat_BuildVisualization;
	Template.bShowActivation = true;

	return Template;
}

static simulated function XComGameState Transmat_BuildGameState(XComGameStateContext Context)
{
	local XComGameStateContext_Ability AbilityContext;
	local XComGameState	NewGameState;
	local XComGameState_Unit ShooterUnit;
	local XComGameState_Ability AbilityState;
	local XComGameState_Item WeaponState;
	local X2EventManager EventManager;
	local XComWorldData World;

	local vector NewShooterLocation;
	local TTile NewShooterTile;

	`LOG("JSRC: finalize transmat network build gamestate function");
	World = `XWORLD;

	// create new state
	NewGameState = `XCOMHISTORY.CreateNewGameState(true, Context);
	AbilityContext = XComGameStateContext_Ability(NewGameState.GetContext());
	ShooterUnit = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', AbilityContext.InputContext.SourceObject.ObjectID));
	AbilityState = XComGameState_Ability(NewGameState.ModifyStateObject(class'XComGameState_Ability', AbilityContext.InputContext.AbilityRef.ObjectID));
	if (AbilityContext.InputContext.ItemObject.ObjectID > 0)
	{
		WeaponState = XComGameState_Item(NewGameState.ModifyStateObject(class'XComGameState_Item', AbilityContext.InputContext.ItemObject.ObjectID));
	}

	// calculate the shooter's new location
	NewShooterLocation = AbilityContext.InputContext.TargetLocations[0];
	NewShooterTile = World.GetTileCoordinatesFromPosition(NewShooterLocation);
	NewShooterLocation = World.GetPositionFromTileCoordinates(NewShooterTile);

	ShooterUnit.SetVisibilityLocation(NewShooterTile);

	// raise events
	EventManager = `XEVENTMGR;
	EventManager.TriggerEvent('ObjectMoved', ShooterUnit, ShooterUnit, NewGameState);
	EventManager.TriggerEvent('UnitMoveFinished', ShooterUnit, ShooterUnit, NewGameState);
	
	// apply the cost of the ability
	AbilityState.GetMyTemplate().ApplyCost(AbilityContext, AbilityState, ShooterUnit, WeaponState, NewGameState);

	return NewGameState;
}

simulated function Transmat_BuildVisualization(XComGameState VisualizeGameState)
{
	local XComGameStateHistory History;
	local XComGameStateContext_Ability Context;
	local StateObjectReference InteractingUnitRef;
	local VisualizationActionMetadata EmptyTrack, SourceTrack;
    local XComGameState_Unit SourceUnit;

	History = `XCOMHISTORY;
	Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());
	InteractingUnitRef = Context.InputContext.SourceObject;

    SourceUnit = XComGameState_Unit(VisualizeGameState.GetGameStateForObjectID(Context.InputContext.SourceObject.ObjectID));

	//****************************************************************************************
	// Configure the visualization track for the source
	//****************************************************************************************
	SourceTrack = EmptyTrack;
	SourceTrack.StateObject_OldState = History.GetGameStateForObjectID(InteractingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
	SourceTrack.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(InteractingUnitRef.ObjectID);
	SourceTrack.VisualizeActor = History.GetVisualizer(InteractingUnitRef.ObjectID);

    // Build the track
	class'X2Action_AbilityPerkStart'.static.AddToVisualizationTree(SourceTrack, Context, false, SourceTrack.LastActionAdded);
    class'X2Action_ShowSpawnedUnit'.static.AddToVisualizationTree(SourceTrack, Context);
	class'X2Action_AbilityPerkEnd'.static.AddToVisualizationTree(SourceTrack, Context, false, SourceTrack.LastActionAdded);

	// sync the visualizer to ensure the target appears in the correct location on the board
	SourceUnit.SyncVisualizer();
}

defaultproperties
{
    ICON_TRANSMATNETWORK="img:///UILibrary_PerkIcons.UIPerk_codex_teleport"
    NAME_TRANSMATNETWORK=Jammerware_JSRC_Ability_TransmatNetwork
    NAME_SPIRETRANSMATNETWORK=Jammerware_JSRC_Ability_SpireTransmatNetwork
    NAME_TRANSMAT=Jammerware_JSRC_Ability_Transmat
}