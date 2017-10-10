class X2Ability_SpireAbilitySet extends X2Ability
	config(JammerwareRunnerClass);

var name NAME_SPIRE_SHELTER;
var name NAME_SPIRE_QUICKSILVER;

static function array <X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	Templates.Length = 0;

	// CORPORAL!
	Templates.AddItem(AddSpireShelter());
	Templates.AddItem(AddSpireQuicksilver());

	return Templates;
}

static function X2AbilityTemplate AddSpireShelter()
{
	local X2AbilityTemplate Template;
	local X2AbilityTrigger_EventListener Trigger;
	local X2Effect_ShelterShield ShieldEffect;
	local X2Condition_ApplyShelterShield TargetCondition;

	`CREATE_X2ABILITY_TEMPLATE(Template, default.NAME_SPIRE_SHELTER);

	// hud behavior
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_adventshieldbearer_energyshield";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_CORPORAL_PRIORITY;

	// targeting
	Template.AbilityTargetStyle = default.SimpleSingleTarget;

	// hit chance
	Template.AbilityToHitCalc = default.DeadEye;

	// conditions
	TargetCondition = new class'X2Condition_ApplyShelterShield';
	TargetCondition.ExcludeFriendlyToSource = false;
	TargetCondition.ExcludeHostileToSource = true;
	TargetCondition.RequireSquadmates = true;
	TargetCondition.RequireWithinRange = true;
	TargetCondition.WithinRange = `METERSTOUNITS(class'XComWorldData'.const.WORLD_Melee_Range_Meters);
	Template.AbilityTargetConditions.AddItem(TargetCondition);

	// triggers
	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.EventID = 'ObjectMoved';
	Trigger.ListenerData.Filter = eFilter_None;
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.TypicalOverwatchListener;
	Template.AbilityTriggers.AddItem(Trigger);

	// effects
	ShieldEffect = new class'X2Effect_ShelterShield';
	// TODO: enable config and weapon-based computation for shield strength and duration
	ShieldEffect.BuildPersistentEffect(2, false, true, , eGameRule_PlayerTurnBegin);
	ShieldEffect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.GetMyLongDescription(), "img:///UILibrary_PerkIcons.UIPerk_adventshieldbearer_energyshield", true);
	ShieldEffect.AddPersistentStatChange(eStat_ShieldHP, 3);
	Template.AddTargetEffect(ShieldEffect);

	// game state and visualization
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bShowActivation = true;

	return Template;
}

static function X2AbilityTemplate AddSpireQuicksilver()
{
	local X2AbilityTemplate Template;
	local X2AbilityTrigger_EventListener Trigger;
	local X2Effect_QuicksilverMobility MobilityEffect;
	local X2Condition_UnitEffects TargetCondition;

	`CREATE_X2ABILITY_TEMPLATE(Template, default.NAME_SPIRE_QUICKSILVER);

	// hud behavior
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_escape";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_CORPORAL_PRIORITY;

	// targeting
	Template.AbilityTargetStyle = default.SimpleSingleTarget;

	// hit chance
	Template.AbilityToHitCalc = default.DeadEye;

	// conditions
	TargetCondition = new class'X2Condition_UnitEffects';
	TargetCondition.AddExcludeEffect(class'X2Effect_QuicksilverMobility'.default.EffectName, 'AA_DuplicateEffectIgnored');
	Template.AbilityTargetConditions.AddItem(TargetCondition);

	// triggers
	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.EventID = 'PlayerTurnBegun';
	Trigger.ListenerData.Filter = eFilter_None;
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.TypicalOverwatchListener;
	Template.AbilityTriggers.AddItem(Trigger);

	// effects
	MobilityEffect = new class'X2Effect_QuicksilverMobility';
	// TODO: enable config and weapon-based computation for mobility amount
	MobilityEffect.BuildPersistentEffect(1);
	MobilityEffect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.GetMyLongDescription(), "img:///UILibrary_PerkIcons.UIPerk_escape", true);
	MobilityEffect.AddPersistentStatChange(eStat_Mobility, 1);
	Template.AddTargetEffect(MobilityEffect);

	// game state and visualization
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bShowActivation = true;

	return Template;
}

defaultproperties
{
	NAME_SPIRE_QUICKSILVER=Jammerware_JSRC_Ability_SpireQuicksilver
	NAME_SPIRE_SHELTER=Jammerware_JSRC_Ability_SpireShelter
}