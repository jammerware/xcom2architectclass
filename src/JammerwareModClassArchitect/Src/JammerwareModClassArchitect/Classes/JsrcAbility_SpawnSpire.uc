class JsrcAbility_SpawnSpire extends X2Ability
    config(JammerwareModClassArchitect);

var name NAME_SPAWN_SPIRE;

var config int COOLDOWN_SPAWN_SPIRE;
var config int TILERANGE_SPAWN_SPIRE;

public static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	Templates.AddItem(CreateSpawnSpire());
	return Templates;
}

private static function X2DataTemplate CreateSpawnSpire()
{
	local X2AbilityTemplate Template;
	local X2AbilityCost_ActionPoints APCost;
	local X2AbilityCooldown Cooldown;
	local X2AbilityTarget_Cursor CursorTarget;

	`CREATE_X2ABILITY_TEMPLATE(Template, default.NAME_SPAWN_SPIRE);

	// hud behavior
	Template.IconImage = "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_Pillar";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.Hostility = eHostility_Neutral;
	Template.bDisplayInUITacticalText = false;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_SQUADDIE_PRIORITY;

	// costs
	APCost = new class'X2AbilityCost_ActionPoints';
	APCost.iNumPoints = 1;
	Template.AbilityCosts.AddItem(APCost);

	// cooldown
	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.COOLDOWN_SPAWN_SPIRE;
	Template.AbilityCooldown = Cooldown;

	// conditions
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	// triggers
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	// targeting and hitting
	Template.AbilityToHitCalc = default.DeadEye;
	CursorTarget = new class'X2AbilityTarget_Cursor';
	CursorTarget.FixedAbilityRange = default.TILERANGE_SPAWN_SPIRE * class'XComWorldData'.const.WORLD_StepSize * class'XComWorldData'.const.WORLD_UNITS_TO_METERS_MULTIPLIER;
	Template.AbilityTargetStyle = CursorTarget;
	Template.TargetingMethod = class'X2TargetingMethod_SpawnSpire';

	// effects
	Template.AddShooterEffect(new class'JsrcEffect_SpawnSpire');

	// game state and visualization
	Template.bSkipFireAction = true;
	Template.bShowActivation = true;
	Template.BuildNewGameStateFn = SpawnSpire_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
		
	return Template;
}

// i had to build my own gamestate building function, because TypicalAbility_BuildGameState was changing the position of 
// the spire. no idea why. it's on my list.
private static simulated function XComGameState SpawnSpire_BuildGameState(XComGameStateContext Context)
{
	local Jammerware_JSRC_SpireRegistrationService SpireRegistrationService;
	local XComGameState NewGameState;
	local XComGameState_Unit ShooterState, SpireState;
	local XComGameStateContext_Ability AbilityContext;
	local vector NewLocation;
	local TTile NewTileLocation;
	local XComWorldData World;

	World = `XWORLD;
	SpireRegistrationService = new class'Jammerware_JSRC_SpireRegistrationService';

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

defaultproperties
{
    NAME_SPAWN_SPIRE=Jammerware_JSRC_Ability_SpawnSpire
}