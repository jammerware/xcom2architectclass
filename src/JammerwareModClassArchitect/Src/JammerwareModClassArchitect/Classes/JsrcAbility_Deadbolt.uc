class JsrcAbility_Deadbolt extends X2Ability;

var string ICON_DEADBOLT;
var name NAME_DEADBOLT;
var name NAME_DEADBOLT_TRIGGER;

public static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateDeadbolt());
	Templates.AddItem(CreateDeadboltTrigger());

	return Templates;
}

private static function X2DataTemplate CreateDeadbolt()
{
    local X2AbilityTemplate Template;

    Template = PurePassive(default.NAME_DEADBOLT, default.ICON_DEADBOLT);
    Template.AdditionalAbilities.AddItem(default.NAME_DEADBOLT_TRIGGER);

    return Template;
}

private static function X2DataTemplate CreateDeadboltTrigger()
{
    local JsrcAbilityTemplate Template;
    local X2AbilityTrigger_OnShotMissed ShotMissedTrigger;

	`CREATE_X2TEMPLATE(class'JsrcAbilityTemplate', Template, default.NAME_DEADBOLT_TRIGGER);

	// HUD behavior
	Template.IconImage = default.ICON_DEADBOLT;
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	// targeting and ability to hit
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityToHitCalc = default.DeadEye;

	// triggering
	ShotMissedTrigger = new class'X2AbilityTrigger_OnShotMissed';
	ShotMissedTrigger.SetListenerData();
	Template.AbilityTriggers.AddItem(ShotMissedTrigger);

    // effects
	Template.AddTargetEffect(new class'X2Effect_Deadbolt');

    // game state and visualization
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
    Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bSkipFireAction = true;

	return Template;
}

DefaultProperties
{
    ICON_DEADBOLT="img:///UILibrary_PerkIcons.UIPerk_equip"
    NAME_DEADBOLT=Jammerware_JSRC_Ability_Deadbolt
    NAME_DEADBOLT_TRIGGER=Jammerware_JSRC_Ability_DeadboltTrigger
}