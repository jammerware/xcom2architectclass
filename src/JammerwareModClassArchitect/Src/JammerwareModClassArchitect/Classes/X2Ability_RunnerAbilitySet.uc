class X2Ability_RunnerAbilitySet extends X2Ability
	config(JammerwareModClassArchitect);

// ability names
var name NAME_FIELD_RELOAD_MODULE;
var name NAME_KINETIC_RIGGING;
var name NAME_LOAD_PERK_CONTENT;
var name NAME_QUICKSILVER;
var name NAME_RECLAIM;
var name NAME_SHELTER;
var name NAME_SOUL_OF_THE_ARCHITECT;
var name NAME_UNITY;

// config/balance
var config int RECLAIM_COOLDOWN;

static function array <X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	// SQUADDIE!
	Templates.AddItem(class'X2Ability_SpawnSpire'.static.CreateSpawnSpire());
	
	// CORPORAL!
	Templates.AddItem(class'X2Ability_FieldReloadArray'.static.CreateFieldReloadArray());
	Templates.AddItem(CreateShelter());

	// SERGEANT!
	Templates.AddItem(CreateReclaim());

	// LIEUTENANT!
	Templates.AddItem(class'X2Ability_RelayedShot'.static.CreateRelayedShot());
	Templates.AddItem(class'X2Ability_TargetingArray'.static.CreateTargetingArray());

	// CAPTAIN!
	Templates.AddItem(CreateKineticRigging());
	Templates.AddItem(CreateQuicksilver());

	// MAJOR!
	Templates.AddItem(CreateUnity());
	Templates.AddItem(class'X2Ability_TransmatLink'.static.CreateTransmatLink());

	// COLONEL!
	Templates.AddItem(CreateSoulOfTheArchitect());
	Templates.AddItem(class'X2Ability_TransmatNetwork'.static.CreateRunnerTransmatNetwork());

	return Templates;
}

private static function X2AbilityTemplate CreateShelter()
{
	return PurePassive(default.NAME_SHELTER, "img:///UILibrary_PerkIcons.UIPerk_adventshieldbearer_energyshield");
}

private static function X2AbilityTemplate CreateReclaim()
{
	local X2AbilityTemplate Template;
	local X2AbilityCooldown Cooldown;
	local X2Condition_UnitProperty RangeCondition;
	local X2Effect_ReclaimSpire ReclaimSpireEffect;
	local X2Effect_GrantActionPoints GrantAPEffect;
	local X2Effect_ReduceCooldowns CreateSpireCooldownResetEffect;

	// general properties
	`CREATE_X2ABILITY_TEMPLATE(Template, default.NAME_RECLAIM);
	Template.Hostility = eHostility_Neutral;

	// hud behavior
	Template.IconImage = "img:///UILibrary_XPACK_Common.PerkIcons.str_holotargeting";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.bDisplayInUITacticalText = false;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_SERGEANT_PRIORITY;
	Template.bLimitTargetIcons = true;

	// cost
	Template.AbilityCosts.AddItem(default.FreeActionCost);

	// Cooldown
	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.RECLAIM_COOLDOWN;
	Template.AbilityCooldown = Cooldown;

	// targeting style (how targets are determined by game rules)
	Template.AbilityTargetStyle = default.SimpleSingleTarget;

	// hit chance
	Template.AbilityToHitCalc = default.DeadEye;

	// conditions
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AbilityTargetConditions.AddItem(new class'X2Condition_OwnedSpire');

	RangeCondition = new class'X2Condition_UnitProperty';
	RangeCondition.ExcludeFriendlyToSource = false;
	RangeCondition.RequireWithinRange = true;
	RangeCondition.WithinRange = `METERSTOUNITS(class'XComWorldData'.const.WORLD_Melee_Range_Meters);
	Template.AbilityTargetConditions.AddItem(RangeCondition);

	// triggering
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	
	// effects
	ReclaimSpireEffect = new class'X2Effect_ReclaimSpire';
	Template.AddTargetEffect(ReclaimSpireEffect);

	GrantAPEffect = new class'X2Effect_GrantActionPoints';
	GrantAPEffect.NumActionPoints = 1;
	GrantAPEffect.PointType = class'X2CharacterTemplateManager'.default.StandardActionPoint;
	GrantAPEffect.bSelectUnit = true;
	Template.AddShooterEffect(GrantAPEffect);

	CreateSpireCooldownResetEffect = new class 'X2Effect_ReduceCooldowns';
	CreateSpireCooldownResetEffect.ReduceAll = true;
	CreateSpireCooldownResetEffect.AbilitiesToTick.AddItem(class'X2Ability_SpawnSpire'.default.NAME_SPAWN_SPIRE);
	Template.AddShooterEffect(CreateSpireCooldownResetEffect);
	
	// game state and visualization
	Template.TargetKilledByXComSpeech = ''; // suppress "target down!" kind of stuff
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bShowActivation = true;

	return Template;
}

private static function X2AbilityTemplate CreateKineticRigging()
{
	local X2AbilityTemplate Template;

	Template = PurePassive(default.NAME_KINETIC_RIGGING, "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_StunStrike");

	// the runner has to be able to activate the spire to use kinetic blast
	Template.AdditionalAbilities.AddItem(class'JsrcAbility_ActivateSpire'.default.NAME_ABILITY); 

	return Template;
}

private static function X2AbilityTemplate CreateQuicksilver()
{
	local X2AbilityTemplate Template;

	Template = PurePassive(default.NAME_QUICKSILVER, "img:///UILibrary_PerkIcons.UIPerk_inspire");

	// the architect has to be able to activate the spire to use quicksilver
	Template.AdditionalAbilities.AddItem(class'JsrcAbility_ActivateSpire'.default.NAME_ABILITY); 

	return Template;
}

private static function X2AbilityTemplate CreateUnity()
{
	return PurePassive(default.NAME_UNITY, "img:///UILibrary_PerkIcons.UIPerk_aethershift");
}

private static function X2AbilityTemplate CreateSoulOfTheArchitect()
{
	local X2AbilityTemplate Template;
	local X2Effect_GenerateCover GenerateCoverEffect;
	local X2Effect_Persistent PersistentEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, default.NAME_SOUL_OF_THE_ARCHITECT);

	Template.IconImage = "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_Pillar";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	
	// targeting and ability to hit
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityToHitCalc = default.DeadEye;

	// triggering
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	GenerateCoverEffect = new class'X2Effect_GenerateCover';
	GenerateCoverEffect.BuildPersistentEffect(1, true, false);
	GenerateCoverEffect.bRemoveWhenMoved = false;
	GenerateCoverEffect.bRemoveOnOtherActivation = false;
	Template.AddTargetEffect(GenerateCoverEffect);

	PersistentEffect = new class'X2Effect_Persistent';
	PersistentEffect.BuildPersistentEffect(1, true, false);
	PersistentEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,, Template.AbilitySourceName);
	Template.AddTargetEffect(PersistentEffect);

	Template.AdditionalAbilities.AddItem(class'X2Ability_TargetingArray'.default.NAME_TARGETING_ARRAY_SPIRE);
	Template.AdditionalAbilities.AddItem(class'X2Ability_SpireAbilitySet'.default.NAME_SPIRE_SHELTER);
	Template.AdditionalAbilities.AddItem(class'X2Ability_SpireAbilitySet'.default.NAME_SPIRE_QUICKSILVER);
	Template.AdditionalAbilities.AddItem(class'X2Ability_KineticBlast'.default.NAME_KINETICBLAST);
	Template.AdditionalAbilities.AddItem(class'X2Ability_TransmatNetwork'.default.NAME_SPIRETRANSMATNETWORK);

	Template.bSkipFireAction = true;
	Template.bShowActivation = true;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	return Template;
}

DefaultProperties 
{
	NAME_FIELD_RELOAD_MODULE=Jammerware_JSRC_Ability_FieldReloadModule
	NAME_KINETIC_RIGGING=Jammerware_JSRC_Ability_KineticRigging
	NAME_LOAD_PERK_CONTENT=Jammerware_JSRC_ArchitectLoadPerkContent
	NAME_QUICKSILVER=Jammerware_JSRC_Ability_Quicksilver
	NAME_RECLAIM=Jammerware_JSRC_Ability_Reclaim
	NAME_SHELTER=Jammerware_JSRC_Ability_Shelter
	NAME_SOUL_OF_THE_ARCHITECT=Jammerware_JSRC_Ability_SoulOfTheArchitect
	NAME_UNITY=Jammerware_JSRC_Ability_Unity
}