class X2Ability_TargetingArray extends X2Ability;

var name NAME_TARGETING_ARRAY;
var name NAME_TARGETING_ARRAY_TRIGGERED;

// effect localizations
var localized string TargetingArrayTriggeredFriendlyName;
var localized string TargetingArrayTriggeredFriendlyDesc;

static function X2DataTemplate CreateTargetingArray()
{
    local X2AbilityTemplate Template;

	// targeting array is x-classable
	Template = PurePassive(default.NAME_TARGETING_ARRAY, "img:///UILibrary_PerkIcons.UIPerk_Ambush", true);
	Template.AdditionalAbilities.AddItem(default.NAME_TARGETING_ARRAY_TRIGGERED);

	return Template;
}

static function X2DataTemplate CreateTargetingArrayTriggered()
{
    local X2AbilityTemplate Template;
	local X2Condition_UnitEffects EffectsCondition;
	local X2AbilityTrigger_EventListener Trigger;
	local X2Effect_TargetingArray TargetingArrayEffect;

	// hud behavior
	`CREATE_X2ABILITY_TEMPLATE(Template, default.NAME_TARGETING_ARRAY_TRIGGERED);
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_Ambush";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	// targeting
	Template.AbilityTargetStyle = default.SelfTarget;

	// hit chance
	Template.AbilityToHitCalc = default.DeadEye;

	// conditions
	Template.AbilityTargetConditions.AddItem(new class'X2Condition_SpireProximityCondition');
	
	EffectsCondition = new class'X2Condition_UnitEffects';
	EffectsCondition.AddExcludeEffect(class'X2Effect_TargetingArray'.default.EffectName, 'AA_DuplicateEffectIgnored');
	Template.AbilityTargetConditions.AddItem(EffectsCondition);

	// triggers
	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.EventID = 'ObjectMoved';
	Trigger.ListenerData.Filter = eFilter_None;
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	Template.AbilityTriggers.AddItem(Trigger);

	// effects
	TargetingArrayEffect = new class'X2Effect_TargetingArray';
	TargetingArrayEffect.BuildPersistentEffect(1, true);
	TargetingArrayEffect.SetDisplayInfo(ePerkBuff_Bonus, default.TargetingArrayTriggeredFriendlyName, default.TargetingArrayTriggeredFriendlyDesc, Template.IconImage);
	Template.AddTargetEffect(TargetingArrayEffect);

	// game state and visualization
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	return Template;
}

defaultproperties
{
	NAME_TARGETING_ARRAY=Jammerware_JSRC_Ability_TargetingArray
	NAME_TARGETING_ARRAY_TRIGGERED=Jammerware_JSRC_Ability_TargetingArray_Triggered
}