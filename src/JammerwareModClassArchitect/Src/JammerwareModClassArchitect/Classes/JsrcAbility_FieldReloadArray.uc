class JsrcAbility_FieldReloadArray extends X2Ability;

var name NAME_ABILITY;
var name NAME_SPIRE_ABILITY;
var string ICON;

public static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	
	Templates.AddItem(CreateFieldReloadArray());
	Templates.AddItem(CreateSpireFieldReloadArray());

	return Templates;
}

private static function X2DataTemplate CreateFieldReloadArray()
{
    return PurePassive(default.NAME_ABILITY, default.ICON);
}

private static function X2DataTemplate CreateSpireFieldReloadArray()
{
    local JsrcAbilityTemplate Template;
    local X2AbilityTrigger_EventListener SpireSpawnTrigger;
	local X2Condition_SpireAbilityCondition SpireAbilityCondition;
	local X2Condition_TargetWeapon WeaponCondition;
	
	// general properties
	`CREATE_X2TEMPLATE(class'JsrcAbilityTemplate', Template, default.NAME_SPIRE_ABILITY);
	Template.Hostility = eHostility_Neutral;

	// hud behavior
	Template.IconImage = default.ICON;
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_CORPORAL_PRIORITY;

	// targeting style (how targets are determined by game rules)
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityMultiTargetStyle = new class'X2AbilityMultiTargetStyle_PBAoE';

	// hit chance
	Template.AbilityToHitCalc = default.DeadEye;

	// triggering
	SpireSpawnTrigger = new class'X2AbilityTrigger_EventListener';
	SpireSpawnTrigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	SpireSpawnTrigger.ListenerData.EventID = class'JsrcEffect_SpawnSpire'.default.NAME_SPAWN_SPIRE_TRIGGER;
	SpireSpawnTrigger.ListenerData.EventFn = class'JsrcGameState_Ability'.static.OnSpireSpawned;
	Template.AbilityTriggers.AddItem(SpireSpawnTrigger);

	// conditions
	SpireAbilityCondition = new class'X2Condition_SpireAbilityCondition';
	SpireAbilityCondition.RequiredArchitectAbility = default.NAME_ABILITY;
	Template.AbilityShooterConditions.AddItem(SpireAbilityCondition);

	WeaponCondition = new class'X2Condition_TargetWeapon';
	WeaponCondition.CanReload = true;
	Template.AbilityMultiTargetConditions.AddItem(WeaponCondition);

	// effects
	Template.AddMultiTargetEffect(new class'X2Effect_FieldReload');
	
	// game state and visualization
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bSkipFireAction = true;

	return Template;
}

DefaultProperties
{
    ICON="img:///UILibrary_PerkIcons.UIPerk_reload"
    NAME_ABILITY=Jammerware_JSRC_Ability_FieldReloadModule
    NAME_SPIRE_ABILITY=Jammerware_JSRC_Ability_SpireFieldReloadModule
}