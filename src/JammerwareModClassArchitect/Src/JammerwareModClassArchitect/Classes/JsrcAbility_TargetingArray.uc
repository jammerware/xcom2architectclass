class JsrcAbility_TargetingArray extends X2Ability;

var name NAME_TARGETING_ARRAY;
var name NAME_TARGETING_ARRAY_SPIRE;
var name NAME_TARGETING_ARRAY_SPIRE_TRIGGERED;

var string ICON_TARGETING_ARRAY;

// effect localizations
var localized string TargetingArrayTriggeredFriendlyName;
var localized string TargetingArrayTriggeredFriendlyDesc;
var localized string TargetingArrayRemovedFriendlyName;

public static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateTargetingArray());
	Templates.AddItem(CreateSpireTargetingArray());
	Templates.AddItem(CreateSpireTargetingArrayTriggered());

	return Templates;
}

private static function X2DataTemplate CreateTargetingArray()
{
    return PurePassive(default.NAME_TARGETING_ARRAY, default.ICON_TARGETING_ARRAY);
}

private static function X2DataTemplate CreateSpireTargetingArray()
{
	local X2AbilityTemplate Template;
	local X2Condition_SpireAbilityCondition SpireAbilityCondition;
	
	Template = PurePassive(default.NAME_TARGETING_ARRAY_SPIRE, default.ICON_TARGETING_ARRAY);

	SpireAbilityCondition = new class'X2Condition_SpireAbilityCondition';
	SpireAbilityCondition.RequiredArchitectAbility = default.NAME_TARGETING_ARRAY;
	Template.AbilityShooterConditions.AddItem(SpireAbilityCondition);	

	Template.AdditionalAbilities.AddItem(default.NAME_TARGETING_ARRAY_SPIRE_TRIGGERED);

	return Template;
}

private static function X2DataTemplate CreateSpireTargetingArrayTriggered()
{
    local X2AbilityTemplate Template;
	local X2Condition_SpireAbilityCondition SpireAbilityCondition;
	local X2Condition_UnitEffects EffectsCondition;
	local X2Condition_UnitProperty TargetPropertiesCondition;
	local X2AbilityMultiTarget_Radius MultiTargetStyle;
	local X2AbilityTrigger_EventListener Trigger;
	local X2Effect_TargetingArray TargetingArrayEffect;

	// hud behavior
	`CREATE_X2ABILITY_TEMPLATE(Template, default.NAME_TARGETING_ARRAY_SPIRE_TRIGGERED);
	Template.IconImage = default.ICON_TARGETING_ARRAY;
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	// weapon sourcing - when the spire has this, we need to let the game know to look in the secondary slot
	// for the weapon
	Template.DefaultSourceItemSlot = eInvSlot_SecondaryWeapon;

	// targeting
	Template.AbilityTargetStyle = default.SelfTarget;

	MultiTargetStyle = new class'X2AbilityMultiTarget_Radius';
	MultiTargetStyle.fTargetRadius = 2.375f;
	MultiTargetStyle.bExcludeSelfAsTargetIfWithinRadius = true;
	MultiTargetStyle.bIgnoreBlockingCover = true;
	Template.AbilityMultiTargetStyle = MultiTargetStyle;

	// hit chance
	Template.AbilityToHitCalc = default.DeadEye;

	// conditions
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	SpireAbilityCondition = new class'X2Condition_SpireAbilityCondition';
	SpireAbilityCondition.RequiredArchitectAbility = default.NAME_TARGETING_ARRAY;
	Template.AbilityShooterConditions.AddItem(SpireAbilityCondition);	

	TargetPropertiesCondition = new class'X2Condition_UnitProperty';
	TargetPropertiesCondition.ExcludeFriendlyToSource = false;
	TargetPropertiesCondition.ExcludeHostileToSource = true;
	TargetPropertiesCondition.ExcludeCivilian = true;
	Template.AbilityMultiTargetConditions.AddItem(TargetPropertiesCondition);
	
	EffectsCondition = new class'X2Condition_UnitEffects';
	EffectsCondition.AddExcludeEffect(class'X2Effect_TargetingArray'.default.EffectName, 'AA_DuplicateEffectIgnored');
	Template.AbilityMultiTargetConditions.AddItem(EffectsCondition);

	// triggers
	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.EventID = 'ObjectMoved';
	Trigger.ListenerData.Filter = eFilter_None;
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_SelfWithAdditionalTargets;
	Template.AbilityTriggers.AddItem(Trigger);

	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.EventID = class'JsrcEffect_SpawnSpire'.default.NAME_SPAWN_SPIRE_TRIGGER;
	Trigger.ListenerData.Filter = eFilter_None;
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.EventFn = UnitSpawnedTargetingArrayListener;
	Template.AbilityTriggers.AddItem(Trigger);

	// also trigger at post begin play for architects with SotA and this
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	// effects
	TargetingArrayEffect = new class'X2Effect_TargetingArray';
	TargetingArrayEffect.BuildPersistentEffect(1, true);
	TargetingArrayEffect.SetDisplayInfo(ePerkBuff_Bonus, default.TargetingArrayTriggeredFriendlyName, default.TargetingArrayTriggeredFriendlyDesc, Template.IconImage);
	TargetingArrayEffect.FlyoverText = default.TargetingArrayTriggeredFriendlyName;
	TargetingArrayEffect.FlyoverIcon = Template.IconImage;
	TargetingArrayEffect.RemovedFlyoverText = default.TargetingArrayRemovedFriendlyName;
	Template.AddMultiTargetEffect(TargetingArrayEffect);

	// game state and visualization
	Template.bSkipFireAction = true;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	return Template;
}

private static function EventListenerReturn UnitSpawnedTargetingArrayListener(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComGameState_Ability AbilityState;

	AbilityState = XComGameState_Ability(CallbackData);
	class'Jammerware_JSRC_AbilityStateService'.static.ActivateAbility(AbilityState);
	
	return ELR_NoInterrupt;
}

DefaultProperties
{
	ICON_TARGETING_ARRAY="img:///UILibrary_PerkIcons.UIPerk_Ambush"
	NAME_TARGETING_ARRAY=Jammerware_JSRC_Ability_TargetingArray
	NAME_TARGETING_ARRAY_SPIRE=Jammerware_JSRC_Ability_SpireTargetingArray
	NAME_TARGETING_ARRAY_SPIRE_TRIGGERED=Jammerware_JSRC_Ability_SpireTargetingArray_Triggered
}