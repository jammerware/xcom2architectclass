class X2Ability_KineticPulse extends X2Ability;

var name NAME_KINETICPULSE;

static function X2DataTemplate CreateKineticPulse()
{
    local X2AbilityTemplate Template;
	local X2AbilityCharges Charges;
	local X2AbilityCost_Charges ChargeCost;
    local X2AbilityMultiTarget_Cone MultiTargetStyle;
    local X2Effect_Knockback KnockbackEffect;

	// general properties
	`CREATE_X2ABILITY_TEMPLATE(Template, default.NAME_KINETICPULSE);
	Template.Hostility = eHostility_Offensive;

	// hud behavior
	Template.IconImage = "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_StunStrike";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_ShowIfAvailable;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_LIEUTENANT_PRIORITY;

	// initial Charges
	Charges = new class'X2AbilityCharges';
	Charges.InitialCharges = 1;
	Template.AbilityCharges = Charges;

	// cost
	Template.AbilityCosts.AddItem(default.WeaponActionTurnEnding);

	ChargeCost = new class'X2AbilityCost_Charges';
	ChargeCost.NumCharges = 1;
	Template.AbilityCosts.AddItem(ChargeCost);

	// targeting style (how targets are determined by game rules)
	Template.AbilityTargetStyle = new class'X2AbilityTarget_Cursor';

	MultiTargetStyle = new class'X2AbilityMultiTarget_Cone';
	MultiTargetStyle.ConeEndDiameter = 16 * class'XComWorldData'.const.WORLD_StepSize;
	MultiTargetStyle.ConeLength = 60 * class'XComWorldData'.const.WORLD_StepSize;
	MultiTargetStyle.bUseWeaponRadius = true;
	Template.AbilityMultiTargetStyle = MultiTargetStyle;

	// targeting method (how the user selects a target)
	Template.TargetingMethod = class'X2TargetingMethod_Cone';

	// hit chance
	Template.AbilityToHitCalc = default.DeadEye;

	// conditions
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
    NAME_KINETICPULSE=Jammerware_JSRC_Ability_KineticPulse
}