class JsrcAbility_Quicksilver extends X2Ability
    config(JammerwareModClassArchitect);

var string ICON_QUICKSILVER;
var name NAME_QUICKSILVER;
var name NAME_SPIRE_QUICKSILVER;

var config int COOLDOWN_SOUL_QUICKSILVER;

public static function array<X2DataTemplate> CreateTemplates()
{
    local array<X2DataTemplate> Templates;

    Templates.AddItem(CreateQuicksilver());
    Templates.AddItem(CreateSpireQuicksilver());

    return Templates;
}

private static function X2AbilityTemplate CreateQuicksilver()
{
	local X2AbilityTemplate Template;

	Template = PurePassive(default.NAME_QUICKSILVER, default.ICON_QUICKSILVER);

	// the architect has to be able to activate the spire to use quicksilver
	Template.AdditionalAbilities.AddItem(class'JsrcAbility_ActivateSpire'.default.NAME_ABILITY); 

	return Template;
}

private static function X2AbilityTemplate CreateSpireQuicksilver()
{
	local X2AbilityTemplate Template;
	local X2AbilityCost_ActionPoints ActionPointCost;
	local X2AbilityCost_Charges ChargeCost;
	local X2Effect_GrantActionPoints ActionPointEffect;
	local X2Condition_SpireAbilityCondition SpireAbilityCondition;
	local X2Condition_UnitProperty TargetCondition;
	local X2AbilityCooldown_SoulOfTheArchitect Cooldown;

	`CREATE_X2ABILITY_TEMPLATE(Template, default.NAME_SPIRE_QUICKSILVER);

	// hud behavior
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.AbilityIconColor = class'Jammerware_JSRC_IconColorService'.static.GetSpireAbilityIconColor();
	Template.IconImage = default.ICON_QUICKSILVER;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_CAPTAIN_PRIORITY;
	Template.Hostility = eHostility_Neutral;
	Template.bLimitTargetIcons = true;
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_ShowIfAvailable;	
	Template.OverrideAbilityAvailabilityFn = class'Jammerware_JSRC_AbilityAvailabilityService'.static.ShowIfValueCheckPasses;

	// sourcing
	Template.DefaultSourceItemSlot = eInvSlot_SecondaryWeapon;
	
	// triggering
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	// targeting
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SimpleSingleTarget;

	// charges
	Template.AbilityCharges =  new class'JsrcAbilityCharges_Quicksilver';

	// costs
	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPointCost);

	ChargeCost = new class'X2AbilityCost_Charges';
	ChargeCost.NumCharges = 1;
	Template.AbilityCosts.AddItem(ChargeCost);

	// cooldown
	Cooldown = new class'X2AbilityCooldown_SoulOfTheArchitect';
	Cooldown.NonSpireCooldown = default.COOLDOWN_SOUL_QUICKSILVER;
	Template.AbilityCooldown = Cooldown;

	// conditions
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	SpireAbilityCondition = new class'X2Condition_SpireAbilityCondition';
	SpireAbilityCondition.RequiredArchitectAbility = default.NAME_QUICKSILVER;
	Template.AbilityShooterConditions.AddItem(SpireAbilityCondition);

	TargetCondition = new class'X2Condition_UnitProperty';
	TargetCondition.ExcludeHostileToSource = true;
	TargetCondition.ExcludeFriendlyToSource = false;
	TargetCondition.RequireSquadmates = true;
	TargetCondition.FailOnNonUnits = true;
	TargetCondition.ExcludeDead = true;
	TargetCondition.ExcludeUnableToAct = true;
	TargetCondition.RequireWithinRange = true;
	TargetCondition.WithinRange = `METERSTOUNITS(class'XComWorldData'.const.WORLD_Melee_Range_Meters);
	Template.AbilityTargetConditions.AddItem(TargetCondition);

	// effects
	ActionPointEffect = new class'X2Effect_GrantActionPoints';
	ActionPointEffect.NumActionPoints = 1;
	ActionPointEffect.PointType = class'X2CharacterTemplateManager'.default.StandardActionPoint;
	ActionPointEffect.bSelectUnit = true;
	Template.AddTargetEffect(ActionPointEffect);

	// visualization and gamestate
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";
	Template.bShowActivation = true;
	Template.bSkipFireAction = true;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	return Template;
}

DefaultProperties
{
    ICON_QUICKSILVER="img:///UILibrary_PerkIcons.UIPerk_inspire"
    NAME_QUICKSILVER=Jammerware_JSRC_Ability_Quicksilver
    NAME_SPIRE_QUICKSILVER=Jammerware_JSRC_Ability_SpireQuicksilver
}