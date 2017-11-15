class X2Ability_SpireAbilitySet extends X2Ability
	config(JammerwareModClassArchitect);

var name NAME_DECOMMISSION;
var name NAME_SPIRE_PASSIVE;
var name NAME_SPIRE_QUICKSILVER;
var name NAME_SPIRE_SHELTER;

var config int COOLDOWN_SOUL_QUICKSILVER;
var config int SHELTER_DURATION;

static function array <X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	Templates.Length = 0;

	// SQUADDIE!
	Templates.AddItem(CreateDecommission());
	Templates.AddItem(CreateSpirePassive());

	// CORPORAL
	Templates.AddItem(class'X2Ability_FieldReloadArray'.static.CreateSpireFieldReloadArray());

	// SERGEANT!
	Templates.AddItem(CreateSpireShelter());
	Templates.AddItem(CreateSpireQuicksilver());

	// LIEUTENANT
	Templates.AddItem(class'X2Ability_TargetingArray'.static.CreateSpireTargetingArray());
	Templates.AddItem(class'X2Ability_TargetingArray'.static.CreateSpireTargetingArrayTriggered());
	Templates.AddItem(class'X2Ability_KineticBlast'.static.CreateKineticBlast());

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

private static function X2AbilityTemplate CreateSpireShelter()
{
	local X2AbilityTemplate Template;
	local X2AbilityTrigger_EventListener TurnEndTrigger;
	local X2Effect_ShelterShield ShieldEffect;
	local X2Condition_AllyAdjacency AllyAdjacencyCondition;
	local X2Condition_UnitProperty PropertyCondition;
	local X2Condition_IsSpire IsSpireCondition;
	local X2Condition_BeASpireOrHaveSoulAnd RunnerAbilityCondition;

	`CREATE_X2ABILITY_TEMPLATE(Template, default.NAME_SPIRE_SHELTER);

	// hud behavior
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_adventshieldbearer_energyshield";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_CORPORAL_PRIORITY;

	// targeting
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityMultiTargetStyle = new class'X2AbilityMultiTargetStyle_PBAoE';

	// hit chance
	Template.AbilityToHitCalc = default.DeadEye;

	// concealment and tactical behavior
	Template.ConcealmentRule = eConceal_Always;

	// conditions
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	RunnerAbilityCondition = new class'X2Condition_BeASpireOrHaveSoulAnd';
	RunnerAbilityCondition.RequiredRunnerAbility = class'X2Ability_RunnerAbilitySet'.default.NAME_SHELTER;
	Template.AbilityShooterConditions.AddItem(RunnerAbilityCondition);
	
	// the ability can only go off if there's an adjacent ally, and since spires can't receive shelter, they don't trigger it
	AllyAdjacencyCondition = new class'X2Condition_AllyAdjacency';
	AllyAdjacencyCondition.ExcludeAllyCharacterGroup = class'X2Character_Spire'.default.NAME_CHARACTERGROUP_SPIRE;
	Template.AbilityShooterConditions.AddItem(AllyAdjacencyCondition);
	
	// multitarget valid targets are friendly squadmates
	PropertyCondition = new class'X2Condition_UnitProperty';
	PropertyCondition.ExcludeFriendlyToSource = false;
	PropertyCondition.ExcludeHostileToSource = true;
	PropertyCondition.RequireSquadmates = true;
	Template.AbilityMultiTargetConditions.AddItem(PropertyCondition);

	// can't apply to spires for gameplay clarity (damage is supposed to be basically irrelevant to spires)
	IsSpireCondition = new class'X2Condition_IsSpire';
	IsSpireCondition.IsNegated = true;
	Template.AbilityMultiTargetConditions.AddItem(IsSpireCondition);

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

static function X2AbilityTemplate CreateSpireQuicksilver()
{
	local X2AbilityTemplate Template;
	local X2AbilityCost_ActionPoints ActionPointCost;
	local X2AbilityCost_Charges ChargeCost;
	local X2Effect_GrantActionPoints ActionPointEffect;
	local X2Condition_BeASpireOrHaveSoulAnd RunnerAbilityCondition;
	local X2Condition_UnitProperty TargetCondition;
	local X2AbilityCooldown_SoulOfTheArchitect Cooldown;

	`CREATE_X2ABILITY_TEMPLATE(Template, default.NAME_SPIRE_QUICKSILVER);

	// hud behavior
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.AbilityIconColor = class'Jammerware_JSRC_IconColorService'.static.GetSpireAbilityIconColor();
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_inspire";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_CAPTAIN_PRIORITY;
	Template.Hostility = eHostility_Neutral;
	Template.bLimitTargetIcons = true;
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_ShowIfAvailable;	
	Template.OverrideAbilityAvailabilityFn = class'Jammerware_JSRC_AbilityAvailabilityService'.static.ShowIfValueCheckPasses;
	
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
	Cooldown = new class'X2AbilityCooldown_SoulOfTheArchitect';
	Cooldown.NonSpireCooldown = default.COOLDOWN_SOUL_QUICKSILVER;
	Template.AbilityCooldown = Cooldown;

	// conditions
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	RunnerAbilityCondition = new class'X2Condition_BeASpireOrHaveSoulAnd';
	RunnerAbilityCondition.RequiredRunnerAbility = class'X2Ability_RunnerAbilitySet'.default.NAME_QUICKSILVER;
	Template.AbilityShooterConditions.AddItem(RunnerAbilityCondition);

	TargetCondition = new class'X2Condition_UnitProperty';
	TargetCondition.ExcludeHostileToSource = true;
	TargetCondition.ExcludeFriendlyToSource = false;
	TargetCondition.RequireSquadmates = true;
	TargetCondition.FailOnNonUnits = true;
	TargetCondition.ExcludeDead = true;
	TargetCondition.ExcludeUnableToAct = true;
	TargetCondition.RequireWithinRange = true;
	TargetCondition.WithinRange = `METERSTOUNITS(class'XComWorldData'.const.WORLD_Melee_Range_Meters);
	Template.AbilityTargetConditions.AddItem(TargetCondition);

	// effects
	ActionPointEffect = new class'X2Effect_GrantActionPoints';
	ActionPointEffect.NumActionPoints = 1;
	ActionPointEffect.PointType = class'X2CharacterTemplateManager'.default.StandardActionPoint;
	ActionPointEffect.bSelectUnit = true;
	Template.AddTargetEffect(ActionPointEffect);

	// visualization and gamestate
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";
	Template.bShowActivation = true;
	Template.bSkipFireAction = true;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	return Template;
}

defaultproperties
{
	NAME_DECOMMISSION=Jammerware_JSRC_Ability_Decommission
	NAME_SPIRE_QUICKSILVER=Jammerware_JSRC_Ability_SpireQuicksilver
	NAME_SPIRE_PASSIVE=Jammerware_JSRC_Ability_SpirePassive
	NAME_SPIRE_SHELTER=Jammerware_JSRC_Ability_SpireShelter
}