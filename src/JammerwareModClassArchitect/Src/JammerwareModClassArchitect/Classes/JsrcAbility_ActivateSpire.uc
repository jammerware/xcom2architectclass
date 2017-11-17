class JsrcAbility_ActivateSpire extends X2Ability
    config(JammerwareModClassArchitect);

var name NAME_ABILITY;
var config int ACTIVATE_SPIRE_COOLDOWN;

// on-the-fly effect localizations
var localized string SpireActiveFriendlyName;
var localized string SpireActiveFriendlyDesc;

public static function array<X2DataTemplate> CreateTemplates()
{
    local array<X2DataTemplate> Templates;
    Templates.AddItem(CreateActivateSpire());
    return Templates;
}

private static function X2AbilityTemplate CreateActivateSpire()
{
	local X2AbilityTemplate Template;
	local X2AbilityCooldown Cooldown;
	local X2Effect_GrantActionPoints APEffect;
	local X2Effect_SpireActive SpireActiveEffect;

	// general properties
	`CREATE_X2ABILITY_TEMPLATE(Template, default.NAME_ABILITY);
	Template.Hostility = eHostility_Neutral;
	Template.bUniqueSource = true; // all rigging abilities also grant this one

	// hud behavior
	Template.IconImage = "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_volt";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_ShowIfAvailable;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_SQUADDIE_PRIORITY;
	Template.bLimitTargetIcons = true;
	Template.AbilityIconColor = class'Jammerware_JSRC_IconColorService'.static.GetSpireAbilityIconColor();
	Template.DefaultSourceItemSlot = eInvSlot_SecondaryWeapon;

	// cost
	Template.AbilityCosts.AddItem(default.FreeActionCost);

	// Cooldown
	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.ACTIVATE_SPIRE_COOLDOWN;
	Template.AbilityCooldown = Cooldown;

	// targeting style (how targets are determined by game rules)
	Template.AbilityTargetStyle = default.SimpleSingleTarget;

	// hit chance
	Template.AbilityToHitCalc = default.DeadEye;

	// conditions
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AbilityTargetConditions.AddItem(default.GameplayVisibilityCondition);
	Template.AbilityTargetConditions.AddItem(new class'X2Condition_OwnedSpire');

	// triggering
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	
	// effects
	APEffect = new class'X2Effect_GrantActionPoints';
	APEffect.NumActionPoints = 2;
	APEffect.PointType = class'X2CharacterTemplateManager'.default.StandardActionPoint;
	APEffect.bSelectUnit = true;
	Template.AddTargetEffect(APEffect);

	SpireActiveEffect = new class'X2Effect_SpireActive';
	SpireActiveEffect.BuildPersistentEffect(1,,,,eGameRule_PlayerTurnEnd);
	SpireActiveEffect.SetDisplayInfo(ePerkBuff_Passive, default.SpireActiveFriendlyName, default.SpireActiveFriendlyDesc, Template.IconImage, true,, Template.AbilitySourceName);
	Template.AddTargetEffect(SpireActiveEffect);
	
	// game state and visualization
	Template.bShowActivation = true;
	Template.CustomFireAnim = 'HL_Psi_ProjectileMedium';
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	return Template;
}

DefaultProperties
{
    NAME_ABILITY=Jammerware_JSRC_Ability_ActivateSpire
}