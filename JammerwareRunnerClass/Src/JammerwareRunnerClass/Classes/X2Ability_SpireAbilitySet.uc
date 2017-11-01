class X2Ability_SpireAbilitySet extends X2Ability
	config(JammerwareRunnerClass);

var name NAME_DECOMMISSION;
var name NAME_SPIRE_LIGHTNINGROD;
var name NAME_SPIRE_PASSIVE;
var name NAME_SPIRE_QUICKSILVER;
var name NAME_SPIRE_SHELTER;

var config int SHELTER_DURATION;

static function array <X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	Templates.Length = 0;

	// SQUADDIE!
	Templates.AddItem(CreateDecommission());
	Templates.AddItem(CreateSpirePassive());

	// SERGEANT!
	Templates.AddItem(CreateSpireShelter());
	Templates.AddItem(AddSpireQuicksilver());

	// LIEUTENANT
	Templates.AddItem(AddSpireLightningRod());
	Templates.AddItem(class'X2Ability_KineticPulse'.static.CreateKineticPulse());

	// COLONEL!
	Templates.AddItem(class'X2Ability_TransmatNetwork'.static.CreateSpireTransmatNetwork());

	return Templates;
}

private static function X2AbilityTemplate CreateSpirePassive()
{
	local X2AbilityTemplate Template;
	local X2Effect_SpirePassive SpirePassiveEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, default.NAME_SPIRE_PASSIVE);

	// HUD behavior
	Template.IconImage = "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_Pillar";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	// targeting and ability to hit
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityToHitCalc = default.DeadEye;

	// triggering
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	SpirePassiveEffect = new class'X2Effect_SpirePassive';
	SpirePassiveEffect.BuildPersistentEffect(1, true, false);
	SpirePassiveEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage,,,Template.AbilitySourceName);
	Template.AddTargetEffect(SpirePassiveEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;
}

static function X2AbilityTemplate CreateDecommission()
{
	local X2AbilityTemplate Template;
	local X2AbilityCost_ActionPoints ActionPointCost;

	// general properties
	`CREATE_X2ABILITY_TEMPLATE(Template, default.NAME_DECOMMISSION);
	Template.Hostility = eHostility_Neutral;

	// hud behavior
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_poisonspit";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.UNSPECIFIED_PRIORITY;

	// cost
	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPointCost);

	// targeting style (how targets are determined by game rules)
	Template.AbilityTargetStyle = default.SelfTarget;

	// hit chance
	Template.AbilityToHitCalc = default.DeadEye;

	// conditions
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	// triggering
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	
	// effects
	Template.AddTargetEffect(new class'X2Effect_ReclaimSpire');

	// game state and visualization
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bShowActivation = false;
	Template.bSkipFireAction = true;

	return Template;
}

static function X2AbilityTemplate CreateSpireShelter()
{
	local X2AbilityTemplate Template;
	local X2AbilityMultiTarget_Radius MultiTargetStyle;
	local X2AbilityTrigger_EventListener TurnEndTrigger;
	local X2Effect_ShelterShield ShieldEffect;
	local X2Condition_UnitProperty PropertyCondition;

	`CREATE_X2ABILITY_TEMPLATE(Template, default.NAME_SPIRE_SHELTER);

	// hud behavior
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_adventshieldbearer_energyshield";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_CORPORAL_PRIORITY;

	// targeting
	Template.AbilityTargetStyle = default.SelfTarget;

	MultiTargetStyle = new class'X2AbilityMultiTarget_Radius';
	MultiTargetStyle.fTargetRadius = 2.375f;
	MultiTargetStyle.bExcludeSelfAsTargetIfWithinRadius = true;
	MultiTargetStyle.bIgnoreBlockingCover = true;
	Template.AbilityMultiTargetStyle = MultiTargetStyle;

	// hit chance
	Template.AbilityToHitCalc = default.DeadEye;

	// concealment and tactical behavior
	Template.ConcealmentRule = eConceal_Always;

	// conditions
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	
	// the ability can only go off if there's an adjacent ally
	Template.AbilityShooterConditions.AddItem(new class'X2Condition_AllyAdjacency');
	
	// multitarget valid targets are friendly squadmates
	PropertyCondition = new class'X2Condition_UnitProperty';
	PropertyCondition.ExcludeFriendlyToSource = false;
	PropertyCondition.ExcludeHostileToSource = true;
	PropertyCondition.RequireSquadmates = true;
	Template.AbilityMultiTargetConditions.AddItem(PropertyCondition);

	// trigger
	TurnEndTrigger = new class'X2AbilityTrigger_EventListener';
	TurnEndTrigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	TurnEndTrigger.ListenerData.EventID = 'PlayerTurnEnded';
	TurnEndTrigger.ListenerData.Filter = eFilter_Player;
	TurnEndTrigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	Template.AbilityTriggers.AddItem(TurnEndTrigger);

	// effects
	ShieldEffect = new class'X2Effect_ShelterShield';
	ShieldEffect.BuildPersistentEffect(default.SHELTER_DURATION, false, true, , eGameRule_PlayerTurnBegin);
	ShieldEffect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.GetMyLongDescription(), "img:///UILibrary_PerkIcons.UIPerk_adventshieldbearer_energyshield", true);
	Template.AddMultiTargetEffect(ShieldEffect);

	// game state and visualization
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bShowActivation = true;
	Template.bSkipFireAction = true;

	return Template;
}

static function X2AbilityTemplate AddSpireLightningRod()
{
	local X2AbilityTemplate Template;
	local X2AbilityCost_ActionPoints ActionPointCost;
	local X2AbilityTarget_Cursor TargetStyle;
	local X2AbilityMultiTarget_Radius MultiTargetStyle;
	local X2Effect_ApplyWeaponDamage DamageEffect;

	// general properties
	`CREATE_X2ABILITY_TEMPLATE(Template, default.NAME_SPIRE_LIGHTNINGROD);
	Template.Hostility = eHostility_Offensive;
	// need to source it to the slot because this ability can be on runner or spire
	Template.DefaultSourceItemSlot = eInvSlot_SecondaryWeapon;

	// hud behavior
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.IconImage = "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_volt";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_CORPORAL_PRIORITY;

	// cost
	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPointCost);

	// targeting style (how targets are determined by game rules)
	TargetStyle = new class'X2AbilityTarget_Cursor';
	TargetStyle.bRestrictToWeaponRange = false;
	TargetStyle.FixedAbilityRange = 0;
	Template.AbilityTargetStyle = TargetStyle;

	MultiTargetStyle = new class'X2AbilityMultiTarget_Radius';
	MultiTargetStyle.fTargetRadius = 5;
	MultiTargetStyle.bIgnoreBlockingCover = true;
	Template.AbilityMultiTargetStyle = MultiTargetStyle;
	
	// targeting method (how the player chooses a target)
	Template.TargetingMethod = class'X2TargetingMethod_LightningRod';

	// hit chance
	Template.AbilityToHitCalc = default.DeadEye;

	// conditions
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	// triggering
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	
	// effects
	DamageEffect = new class'X2Effect_ApplyWeaponDamage';
	DamageEffect.bExplosiveDamage = true;
	DamageEffect.bIgnoreBaseDamage = true;
	DamageEffect.DamageTag = 'LightningRod';
	Template.AddMultiTargetEffect(DamageEffect);

	// game state and visualization
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bShowActivation = true;

	return Template;
}

static function X2AbilityTemplate AddSpireQuicksilver()
{
	local X2AbilityTemplate Template;
	local X2AbilityCost_ActionPoints ActionPointCost;
	local X2AbilityCost_Charges ChargeCost;
	local X2Effect_GrantActionPoints ActionPointEffect;
	local X2Condition_UnitProperty TargetCondition;
	local X2AbilityCooldown Cooldown;

	`CREATE_X2ABILITY_TEMPLATE(Template, default.NAME_SPIRE_QUICKSILVER);

	// hud behavior
	Template.DisplayTargetHitChance = true;
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_runandgun";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_SERGEANT_PRIORITY;
	Template.Hostility = eHostility_Neutral;
	Template.bLimitTargetIcons = true;
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;	
	
	// triggering
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	// targeting
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SimpleSingleTarget;

	// charges
	Template.AbilityCharges =  new class'X2AbilityCharges_Quicksilver';

	// costs
	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPointCost);

	ChargeCost = new class'X2AbilityCost_Charges';
	ChargeCost.NumCharges = 1;
	Template.AbilityCosts.AddItem(ChargeCost);

	// cooldown
	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = 3;
	Template.AbilityCooldown = Cooldown;

	// conditions
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	TargetCondition = new class'X2Condition_UnitProperty';
	TargetCondition.ExcludeHostileToSource = true;
	TargetCondition.ExcludeFriendlyToSource = false;
	TargetCondition.RequireSquadmates = true;
	TargetCondition.FailOnNonUnits = true;
	TargetCondition.ExcludeDead = true;
	TargetCondition.ExcludeRobotic = true;
	TargetCondition.ExcludeUnableToAct = true;
	TargetCondition.RequireWithinRange = true;
	TargetCondition.WithinRange = `METERSTOUNITS(class'XComWorldData'.const.WORLD_Melee_Range_Meters);
	Template.AbilityTargetConditions.AddItem(TargetCondition);
	Template.AbilityTargetConditions.AddItem(default.GameplayVisibilityCondition);

	// effects
	ActionPointEffect = new class'X2Effect_GrantActionPoints';
	ActionPointEffect.NumActionPoints = 1;
	ActionPointEffect.PointType = class'X2CharacterTemplateManager'.default.StandardActionPoint;
	ActionPointEffect.bSelectUnit = true;
	Template.AddTargetEffect(ActionPointEffect);

	// visualization and gamestate
	Template.bShowActivation = true;
	Template.bSkipFireAction = true;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	Template.SuperConcealmentLoss = class'X2AbilityTemplateManager'.default.SuperConcealmentStandardShotLoss;
	Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.NonAggressiveChosenActivationIncreasePerUse;
	Template.LostSpawnIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotLostSpawnIncreasePerUse;
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";

	return Template;
}

defaultproperties
{
	NAME_DECOMMISSION=Jammerware_JSRC_Ability_Decommission
	NAME_SPIRE_LIGHTNINGROD=Jammerware_JSRC_Ability_SpireLightningRod
	NAME_SPIRE_QUICKSILVER=Jammerware_JSRC_Ability_SpireQuicksilver
	NAME_SPIRE_PASSIVE=Jammerware_JSRC_Ability_SpirePassive
	NAME_SPIRE_SHELTER=Jammerware_JSRC_Ability_SpireShelter
}