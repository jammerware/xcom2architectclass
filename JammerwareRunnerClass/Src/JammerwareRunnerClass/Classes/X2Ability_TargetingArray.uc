class X2Ability_TargetingArray extends X2Ability;

var name NAME_SPIRE_TARGETING_ARRAY;

// icon
var string ICON_TARGETING_ARRAY;

// effect localizations
var localized string TargetingArrayTriggeredFriendlyName;
var localized string TargetingArrayTriggeredFriendlyDesc;

public static function X2DataTemplate CreateSpireTargetingArray()
{
    local X2AbilityTemplate Template;
	local X2AbilityCost_ActionPoints APCost;
	local X2Condition_UnitEffects EffectsCondition;
	local X2Condition_UnitProperty PropertiesCondition;
	local X2Effect_TargetingArray TargetingArrayEffect;

	// hud behavior
	`CREATE_X2ABILITY_TEMPLATE(Template, default.NAME_SPIRE_TARGETING_ARRAY);
	Template.IconImage = default.ICON_TARGETING_ARRAY;
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_AlwaysShow;
	Template.Hostility = eHostility_Neutral;

	// triggers
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	// cost
	APCost = new class'X2AbilityCost_ActionPoints';
	APCost.iNumPoints = 1;
	Template.AbilityCosts.AddItem(APCost);
	
	// targeting
	Template.AbilityTargetStyle = default.SimpleSingleTarget;

	// hit chance
	Template.AbilityToHitCalc = default.DeadEye;

	// conditions
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	EffectsCondition = new class'X2Condition_UnitEffects';
	EffectsCondition.AddExcludeEffect(class'X2Effect_TargetingArray'.default.EffectName, 'AA_DuplicateEffectIgnored');
	Template.AbilityTargetConditions.AddItem(EffectsCondition);

	PropertiesCondition = new class'X2Condition_UnitProperty';
	PropertiesCondition.ExcludeHostileToSource = true;
	PropertiesCondition.ExcludeFriendlyToSource = false;
	PropertiesCondition.RequireSquadmates = true;
	PropertiesCondition.FailOnNonUnits = true;
	PropertiesCondition.RequireWithinRange = true;
	PropertiesCondition.WithinRange = `METERSTOUNITS(class'XComWorldData'.const.WORLD_Melee_Range_Meters);
	Template.AbilityTargetConditions.AddItem(PropertiesCondition);

	// effects
	TargetingArrayEffect = new class'X2Effect_TargetingArray';
	TargetingArrayEffect.BuildPersistentEffect(1);
	TargetingArrayEffect.SetDisplayInfo(ePerkBuff_Bonus, default.TargetingArrayTriggeredFriendlyName, default.TargetingArrayTriggeredFriendlyDesc, Template.IconImage);
	Template.AddTargetEffect(TargetingArrayEffect);

	// game state and visualization
	Template.bSkipFireAction = true;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	return Template;
}

defaultproperties
{
	ICON_TARGETING_ARRAY="img:///UILibrary_PerkIcons.UIPerk_Ambush"
	NAME_SPIRE_TARGETING_ARRAY=Jammerware_JSRC_Ability_SpireTargetingArray
}