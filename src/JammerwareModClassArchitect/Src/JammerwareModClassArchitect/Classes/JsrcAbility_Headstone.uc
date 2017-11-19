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
	Template.AddTargetEffect(new class'JsrcEffect_SpawnSpire');
	
	// game state and visualization
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bSkipFireAction = true;
	Template.bShowActivation = true;

	return Template;
}

DefaultProperties
{
    NAME_ABILITY=Jammerware_JSRC_Ability_Headstone
}