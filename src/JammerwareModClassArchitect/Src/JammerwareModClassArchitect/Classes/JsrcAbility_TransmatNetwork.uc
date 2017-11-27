class JsrcAbility_TransmatNetwork extends X2Ability;

var name NAME_TRANSMAT;
var name NAME_TRANSMATNETWORK;
var name NAME_SPIRETRANSMATNETWORK;

var string ICON_TRANSMATNETWORK;

public static function array <X2DataTemplate> CreateTemplates()
{
    local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateTransmatNetwork());
	Templates.AddItem(CreateSpireTransmatNetwork());
    Templates.AddItem(CreateTransmat());

    return Templates;
}

private static function X2DataTemplate CreateTransmatNetwork()
{
    return PurePassive(default.NAME_TRANSMATNETWORK, default.ICON_TRANSMATNETWORK);
}

private static function X2DataTemplate CreateSpireTransmatNetwork()
{
	local X2AbilityTemplate Template;
	local X2Condition_SpireAbilityCondition SpireAbilityCondition;

	SpireAbilityCondition = new class'X2Condition_SpireAbilityCondition';
	SpireAbilityCondition.RequiredArchitectAbility = default.NAME_TRANSMATNETWORK;

	Template = PurePassive(default.NAME_SPIRETRANSMATNETWORK, default.ICON_TRANSMATNETWORK);
	Template.AbilityTargetConditions.AddItem(SpireAbilityCondition);

    return Template;
}

private static function X2AbilityTemplate CreateTransmat()
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
	Template.TargetingMethod = class'JsrcTargetingMethod_Transmat';

	// hit chance
	Template.AbilityToHitCalc = default.DeadEye;

	// triggering
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	
	// game state and visualization
	Template.bShowActivation = true;
	Template.bSkipFireAction = true;
	Template.BuildNewGameStateFn = Transmat_BuildGameState;
	Template.BuildVisualizationFn = Transmat_BuildVisualization;

	return Template;
}

private static simulated function XComGameState Transmat_BuildGameState(XComGameStateContext Context)
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

private simulated function Transmat_BuildVisualization(XComGameState VisualizeGameState)
{
	local XComGameStateContext_Ability AbilityContext;	
	local XComGameState_Unit SourceUnit;
	local VisualizationActionMetadata EmptyTrack, ActionMetadata;
	local X2Action_TimedWait WaitAction;

	AbilityContext = XComGameStateContext_Ability(VisualizeGameState.GetContext());
	SourceUnit = XComGameState_Unit(VisualizeGameState.GetGameStateForObjectID(AbilityContext.InputContext.SourceObject.ObjectID));

	// firaxis is smart and i am dumb
	TypicalAbility_BuildVisualization(VisualizeGameState);

	// build the shooter track
	ActionMetadata = EmptyTrack;
	ActionMetadata.StateObjectRef = AbilityContext.InputContext.SourceObject;
	ActionMetadata.StateObject_OldState = SourceUnit;
	ActionMetadata.StateObject_NewState = SourceUnit;

	// this is a hot track
	class'X2Action_AbilityPerkStart'.static.AddToVisualizationTree(ActionMetadata, AbilityContext);
	class'X2Action_AbilityPerkEnd'.static.AddToVisualizationTree(ActionMetadata, AbilityContext);
	WaitAction = X2Action_TimedWait(class'X2Action_TimedWait'.static.AddToVisualizationTree(ActionMetadata, AbilityContext));
	WaitAction.DelayTimeSec = 1.5;
	class'X2Action_SyncVisualizer'.static.AddToVisualizationTree(ActionMetadata, AbilityContext);
	WaitAction = X2Action_TimedWait(class'X2Action_TimedWait'.static.AddToVisualizationTree(ActionMetadata, AbilityContext));
	WaitAction.DelayTimeSec = 1.5;
}

defaultproperties
{
    ICON_TRANSMATNETWORK="img:///UILibrary_PerkIcons.UIPerk_codex_teleport"
    NAME_TRANSMATNETWORK=Jammerware_JSRC_Ability_TransmatNetwork
    NAME_SPIRETRANSMATNETWORK=Jammerware_JSRC_Ability_SpireTransmatNetwork
    NAME_TRANSMAT=Jammerware_JSRC_Ability_Transmat
}