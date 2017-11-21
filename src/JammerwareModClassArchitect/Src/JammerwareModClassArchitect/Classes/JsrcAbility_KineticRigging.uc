class JsrcAbility_KineticRigging extends X2Ability
    config(JammerwareModClassArchitect);

var name NAME_KINETIC_BLAST;
var name NAME_KINETIC_RIGGING;
var config int COOLDOWN_SOUL_KINETIC_BLAST;

public static function array<X2DataTemplate> CreateTemplates()
{
    local array<X2DataTemplate> Templates;

    Templates.AddItem(CreateKineticRigging());
    Templates.AddItem(CreateKineticBlast());

    return Templates;
}

private static function X2AbilityTemplate CreateKineticRigging()
{
	local X2AbilityTemplate Template;

	Template = PurePassive(default.NAME_KINETIC_RIGGING, "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_StunStrike");

	// the runner has to be able to activate the spire to use kinetic blast
	Template.AdditionalAbilities.AddItem(class'JsrcAbility_ActivateSpire'.default.NAME_ABILITY); 

	return Template;
}

private static function X2DataTemplate CreateKineticBlast()
{
    local X2AbilityTemplate Template;
    local X2AbilityMultiTarget_Cone MultiTargetStyle;
	local X2Condition_SpireAbilityCondition SpireAbilityCondition;
	local X2AbilityCooldown_SoulOfTheArchitect Cooldown;
    local X2Effect_Knockback KnockbackEffect;

	// general properties
	`CREATE_X2ABILITY_TEMPLATE(Template, default.NAME_KINETIC_BLAST);
	Template.Hostility = eHostility_Offensive;
	Template.DefaultSourceItemSlot = eInvSlot_SecondaryWeapon;

	// hud behavior
	Template.IconImage = "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_StunStrike";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_ShowIfAvailable;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_CAPTAIN_PRIORITY;
	Template.AbilityIconColor = class'Jammerware_JSRC_IconColorService'.static.GetSpireAbilityIconColor();
	Template.OverrideAbilityAvailabilityFn = class'Jammerware_JSRC_AbilityAvailabilityService'.static.ShowIfValueCheckPasses;
	Template.bFriendlyFireWarning = false;

	// cost
	Template.AbilityCosts.AddItem(default.WeaponActionTurnEnding);

	// cooldown
	Cooldown = new class'X2AbilityCooldown_SoulOfTheArchitect';
	Cooldown.NonSpireCooldown = default.COOLDOWN_SOUL_KINETIC_BLAST;
	Template.AbilityCooldown = Cooldown;

	// targeting style (how targets are determined by game rules)
	Template.AbilityTargetStyle = new class'X2AbilityTarget_Cursor';

	MultiTargetStyle = new class'X2AbilityMultiTarget_Cone';
	MultiTargetStyle.ConeEndDiameter = 16 * class'XComWorldData'.const.WORLD_StepSize;
	MultiTargetStyle.ConeLength = 10 * class'XComWorldData'.const.WORLD_StepSize;
	MultiTargetStyle.bUseWeaponRadius = true;
	Template.AbilityMultiTargetStyle = MultiTargetStyle;

	// targeting method (how the user selects a target)
	Template.TargetingMethod = class'X2TargetingMethod_Cone';

	// hit chance
	Template.AbilityToHitCalc = default.DeadEye;

	// conditions
	SpireAbilityCondition = new class'X2Condition_SpireAbilityCondition';
	SpireAbilityCondition.RequiredArchitectAbility = default.NAME_KINETIC_RIGGING;
	Template.AbilityShooterConditions.AddItem(SpireAbilityCondition);
	
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	// triggering
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	
	// effects
	KnockbackEffect = new class'JsrcEffect_KineticBlast';
	KnockbackEffect.KnockbackDistance = 8;
	KnockbackEffect.OnlyOnDeath = false; 
	KnockbackEffect.bKnockbackDestroysNonFragile = true;
	Template.AddMultiTargetEffect(KnockbackEffect);
	
	// game state and visualization
	Template.bShowActivation = true;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	return Template;
}

DefaultProperties
{
    NAME_KINETIC_BLAST=Jammerware_JSRC_Ability_KineticBlast
    NAME_KINETIC_RIGGING=Jammerware_JSRC_Ability_KineticRigging
}