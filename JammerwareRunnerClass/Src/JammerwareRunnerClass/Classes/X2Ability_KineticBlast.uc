class X2Ability_KineticBlast extends X2Ability
	config(JammerwareRunnerClass);

var name NAME_KINETICBLAST;
var config int SOUL_COOLDOWN_KINETIC_BLAST;

static function X2DataTemplate CreateKineticBlast()
{
    local X2AbilityTemplate Template;
    local X2AbilityMultiTarget_Cone MultiTargetStyle;
	local X2Condition_BeASpireOrHaveSoulAnd RunnerAbilityCondition;
	local X2AbilityCooldown_SoulOfTheArchitect Cooldown;
    local X2Effect_Knockback KnockbackEffect;

	// general properties
	`CREATE_X2ABILITY_TEMPLATE(Template, default.NAME_KINETICBLAST);
	Template.Hostility = eHostility_Offensive;

	// hud behavior
	Template.IconImage = "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_StunStrike";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_ShowIfAvailable;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_CAPTAIN_PRIORITY;
	Template.AbilityIconColor = class'Jammerware_JSRC_IconColorService'.static.GetSpireAbilityIconColor();
	Template.OverrideAbilityAvailabilityFn = class'Jammerware_JSRC_AbilityAvailabilityService'.static.ShowIfValueCheckPasses;

	// cost
	Template.AbilityCosts.AddItem(default.WeaponActionTurnEnding);

	// cooldown
	Cooldown = new class'X2AbilityCooldown_SoulOfTheArchitect';
	Cooldown.NonSpireCooldown = default.SOUL_COOLDOWN_KINETIC_BLAST;
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
	RunnerAbilityCondition = new class'X2Condition_BeASpireOrHaveSoulAnd';
	RunnerAbilityCondition.RequiredRunnerAbility = class'X2Ability_RunnerAbilitySet'.default.NAME_KINETIC_RIGGING;
	Template.AbilityShooterConditions.AddItem(RunnerAbilityCondition);
	
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	// triggering
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	
	// effects
	KnockbackEffect = new class'X2Effect_Impetus';
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

defaultproperties
{
    NAME_KINETICBLAST=Jammerware_JSRC_Ability_KineticBlast
}