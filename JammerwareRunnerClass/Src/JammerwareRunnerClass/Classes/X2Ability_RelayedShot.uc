class X2Ability_RelayedShot extends X2Ability;

var name NAME_RELAYED_SHOT;

static function X2DataTemplate CreateRelayedShot()
{
    local X2AbilityTemplate Template;
	local X2AbilityCooldown Cooldown;
	local X2AbilityCost_Ammo AmmoCost;
	local X2Condition_UnitProperty TargetPropertiesCondition;
	local X2Condition_UnitType UnitTypeCondition;

	// general properties
	`CREATE_X2ABILITY_TEMPLATE(Template, default.NAME_RELAYED_SHOT);
	Template.Hostility = eHostility_Offensive;

	// hud behavior
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_nulllance";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.bDisplayInUITacticalText = false;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_MAJOR_PRIORITY;
	Template.bLimitTargetIcons = true;
	Template.bFriendlyFireWarning = false;

	// cost
	Template.AbilityCosts.AddItem(default.WeaponActionTurnEnding);

	AmmoCost = new class'X2AbilityCost_Ammo';
	AmmoCost.iAmmo = 1;
	AmmoCost.bConsumeAllAmmo = true;
	Template.AbilityCosts.AddItem(AmmoCost);
	
	// Cooldown
	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = 5;
	Template.AbilityCooldown = Cooldown;

	// targeting style (how targets are determined by game rules)
	Template.AbilityTargetStyle = default.SimpleSingleTarget;
    Template.AbilityMultiTargetStyle = new class'X2AbilityMultiTarget_Line';

	// hit chance
	Template.AbilityToHitCalc = default.DeadEye;

	// conditions
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	UnitTypeCondition = new class'X2Condition_UnitType';
	UnitTypeCondition.IncludeTypes.AddItem(class'X2Character_Spire'.default.NAME_CHARACTERGROUP_SPIRE);
	Template.AbilityTargetConditions.AddItem(UnitTypeCondition);

	// need to make sure the primary target (spire) is owned by the shooter

    TargetPropertiesCondition = new class'X2Condition_UnitProperty';
	TargetPropertiesCondition.ExcludeHostileToSource = false;
	TargetPropertiesCondition.ExcludeFriendlyToSource = true;
	Template.AbilityMultiTargetConditions.AddItem(TargetPropertiesCondition);

	// triggering
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	// effects
	Template.bAllowAmmoEffects = true;
	Template.AddMultiTargetEffect(new class'X2Effect_ApplyWeaponDamage');
	
	// game state and visualization
	Template.bUsesFiringCamera = true;
	Template.CinescriptCameraType = "StandardGunFiring";
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	return Template;
}

defaultproperties
{
    NAME_RELAYED_SHOT=Jammerware_JSRC_Ability_RelayedShot
}