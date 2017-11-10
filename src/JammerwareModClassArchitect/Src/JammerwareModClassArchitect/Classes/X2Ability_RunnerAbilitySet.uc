class X2Ability_RunnerAbilitySet extends X2Ability
	config(JammerwareModClassArchitect);

// ability names
var name NAME_ACTIVATE_SPIRE;
var name NAME_DEADBOLT;
var name NAME_FIELD_RELOAD_MODULE;
var name NAME_HEADSTONE;
var name NAME_KINETIC_RIGGING;
var name NAME_LOAD_PERK_CONTENT;
var name NAME_QUICKSILVER;
var name NAME_RECLAIM;
var name NAME_SHELTER;
var name NAME_SOUL_OF_THE_ARCHITECT;
var name NAME_UNITY;

// config/balance
var config int ACTIVATE_SPIRE_COOLDOWN;
var config int HEADSTONE_COOLDOWN;
var config int RECLAIM_COOLDOWN;

// on-the-fly effect localizations
var localized string SpireActiveFriendlyName;
var localized string SpireActiveFriendlyDesc;

static function array <X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	// SQUADDIE!
	Templates.AddItem(CreateLoadPerkContent());
	Templates.AddItem(class'X2Ability_SpawnSpire'.static.CreateSpawnSpire());
	Templates.AddItem(CreateActivateSpire());
	
	// CORPORAL!
	Templates.AddItem(CreateFieldReloadModule());
	Templates.AddItem(CreateShelter());

	// SERGEANT!
	Templates.AddItem(CreateHeadstone());
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

	// GTS!
	Templates.AddItem(CreateDeadbolt());

	return Templates;
}

private static function X2DataTemplate CreateLoadPerkContent()
{
	local X2AbilityTemplate Template;
	local X2Effect_LoadPerkContent LoadPerkContentEffect;

	// general properties
	`CREATE_X2ABILITY_TEMPLATE(Template, default.NAME_LOAD_PERK_CONTENT);
	Template.Hostility = eHostility_Neutral;
    Template.bIsPassive = true;

	// hud behavior
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.bDisplayInUITacticalText = false;

	// targeting/hit chance
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityToHitCalc = default.DeadEye;

	// triggering
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	
	// effects
	LoadPerkContentEffect = new class'X2Effect_LoadPerkContent';
	LoadPerkContentEffect.BuildPersistentEffect(1, true, false);
	LoadPerkContentEffect.AbilitiesToLoad.AddItem(default.NAME_ACTIVATE_SPIRE);
	Template.AddTargetEffect(LoadPerkContentEffect);	
	
	// game state and visualization
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bSkipFireAction = true;
	Template.bShowActivation = false;

	return Template;
}

private static function X2AbilityTemplate CreateActivateSpire()
{
	local X2AbilityTemplate Template;
	local X2AbilityCooldown Cooldown;
	local X2Effect_GrantActionPoints APEffect;
	local X2Effect_Persistent CosmeticBuff;

	// general properties
	`CREATE_X2ABILITY_TEMPLATE(Template, default.NAME_ACTIVATE_SPIRE);
	Template.Hostility = eHostility_Neutral;

	// hud behavior
	Template.IconImage = "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_volt";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_ShowIfAvailable;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_SQUADDIE_PRIORITY;
	Template.bLimitTargetIcons = true;
	Template.AbilityIconColor = class'Jammerware_JSRC_IconColorService'.static.GetSpireAbilityIconColor();

	// cost
	Template.AbilityCosts.AddItem(default.FreeActionCost);

	// Cooldown
	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.ACTIVATE_SPIRE_COOLDOWN;
	Template.AbilityCooldown = Cooldown;

	// targeting style (how targets are determined by game rules)
	Template.AbilityTargetStyle = default.SimpleSingleTarget;

	// hit chance
	Template.AbilityToHitCalc = default.DeadEye;

	// conditions
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AbilityTargetConditions.AddItem(default.GameplayVisibilityCondition);
	Template.AbilityTargetConditions.AddItem(new class'X2Condition_OwnedSpire');

	// triggering
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	
	// effects
	APEffect = new class'X2Effect_GrantActionPoints';
	APEffect.NumActionPoints = 2;
	APEffect.PointType = class'X2CharacterTemplateManager'.default.StandardActionPoint;
	APEffect.bSelectUnit = true;
	Template.AddTargetEffect(APEffect);

	CosmeticBuff = new class'X2Effect_Persistent';
	CosmeticBuff.BuildPersistentEffect(1,,,,eGameRule_PlayerTurnEnd);
	CosmeticBuff.SetDisplayInfo(ePerkBuff_Passive, default.SpireActiveFriendlyName, default.SpireActiveFriendlyDesc, Template.IconImage, true,, Template.AbilitySourceName);
	Template.AddTargetEffect(CosmeticBuff);
	
	// game state and visualization
	Template.CustomFireAnim = 'HL_Psi_ProjectileMedium';
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bShowActivation = true;

	return Template;
}

private static function X2AbilityTemplate CreateFieldReloadModule()
{
	local X2AbilityTemplate Template;
	local X2Effect_FieldReload FieldReloadEffect;
	
	// general properties
	`CREATE_X2ABILITY_TEMPLATE(Template, default.NAME_FIELD_RELOAD_MODULE);
	Template.Hostility = eHostility_Neutral;

	// hud behavior
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_reload";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_CORPORAL_PRIORITY;
	Template.bIsPassive = true;

	// targeting style (how targets are determined by game rules)
	Template.AbilityTargetStyle = default.SelfTarget;

	// hit chance
	Template.AbilityToHitCalc = default.DeadEye;

	// triggering
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	
	// effects
	FieldReloadEffect = new class'X2Effect_FieldReload';
	FieldReloadEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,, Template.AbilitySourceName);
	FieldReloadEffect.BuildPersistentEffect(1, true);
	Template.AddTargetEffect(FieldReloadEffect);
	
	// game state and visualization
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bShowActivation = false;
	Template.bSkipFireAction = true;

	return Template;
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
	local X2Condition_UnitType UnitTypeCondition;
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

	UnitTypeCondition = new class'X2Condition_UnitType';
	UnitTypeCondition.IncludeTypes.AddItem(class'X2Character_Spire'.default.NAME_CHARACTERGROUP_SPIRE);
	Template.AbilityTargetConditions.AddItem(UnitTypeCondition);

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
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bShowActivation = true;

	return Template;
}

private static function X2AbilityTemplate CreateHeadstone()
{
	local X2AbilityTemplate Template;
	local X2AbilityCooldown Cooldown;
	local X2Condition_UnitProperty DeadEnemiesCondition;
	local X2Effect_SpawnSpire SpawnSpireEffect;

	// general properties
	`CREATE_X2ABILITY_TEMPLATE(Template, default.NAME_HEADSTONE);
	Template.Hostility = eHostility_Neutral;

	// hud behavior
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_poisonspit";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.bDisplayInUITacticalText = false;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_SERGEANT_PRIORITY;
	Template.bLimitTargetIcons = true;

	// cost
	Template.AbilityCosts.AddItem(default.FreeActionCost);

	// Cooldown
	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.HEADSTONE_COOLDOWN;
	Template.AbilityCooldown = Cooldown;

	// targeting style (how targets are determined by game rules)
	Template.AbilityTargetStyle = default.SimpleSingleTarget;

	// targeting method (how the user chooses a target based on the rules)
	Template.TargetingMethod = class'X2TargetingMethod_TopDownTileHighlight';

	// hit chance
	Template.AbilityToHitCalc = default.DeadEye;

	// conditions
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AbilityTargetConditions.AddItem(default.GameplayVisibilityCondition);

	DeadEnemiesCondition = new class 'X2Condition_UnitProperty';
	DeadEnemiesCondition.ExcludeAlive = true;
	DeadEnemiesCondition.ExcludeDead = false;
	DeadEnemiesCondition.ExcludeHostileToSource = false;
	DeadEnemiesCondition.FailOnNonUnits = true;
	Template.AbilityTargetConditions.AddItem(DeadEnemiesCondition);

	// triggering
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	
	// effects
	SpawnSpireEffect = new class'X2Effect_SpawnSpire';
	SpawnSpireEffect.BuildPersistentEffect(1, true, true);
	SpawnSpireEffect.bClearTileBlockedByTargetUnitFlag = true;
	Template.AddTargetEffect(SpawnSpireEffect);
	
	// game state and visualization
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = Headstone_BuildVisualization;
	Template.bShowActivation = true;

	return Template;
}

private static function Headstone_BuildVisualization(XComGameState VisualizeGameState)
{
	local XComGameStateHistory History;
	local XComGameStateContext_Ability Context;
	local StateObjectReference InteractingUnitRef;

	local VisualizationActionMetadata EmptyTrack;
	local VisualizationActionMetadata ShooterTrack, DeadUnitTrack, SpawnedUnitTrack;
	local XComGameState_Unit SpawnedUnit, DeadUnit;

	local UnitValue SpawnedUnitValue;
	local X2Effect_SpawnSpire SpawnSpireEffect;

	History = `XCOMHISTORY;

	Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());
	InteractingUnitRef = Context.InputContext.SourceObject;

	// Configure the visualization track for the shooter
	//****************************************************************************************
	ShooterTrack = EmptyTrack;
	ShooterTrack.StateObject_OldState = History.GetGameStateForObjectID(InteractingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
	ShooterTrack.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(InteractingUnitRef.ObjectID);
	ShooterTrack.VisualizeActor = History.GetVisualizer(InteractingUnitRef.ObjectID);

	// Configure the visualization track for the dead guy
	//******************************************************************************************
	DeadUnitTrack.StateObject_OldState = History.GetGameStateForObjectID(Context.InputContext.PrimaryTarget.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex);
	DeadUnitTrack.StateObject_NewState = DeadUnitTrack.StateObject_OldState;
	DeadUnit = XComGameState_Unit(VisualizeGameState.GetGameStateForObjectID(Context.InputContext.PrimaryTarget.ObjectID));
	`assert(DeadUnit != none);
	DeadUnitTrack.VisualizeActor = History.GetVisualizer(DeadUnit.ObjectID);

	// Get the ObjectID for the SpawnedUnit created from the DeadUnit
	DeadUnit.GetUnitValue(class'X2Effect_SpawnUnit'.default.SpawnedUnitValueName, SpawnedUnitValue);

	SpawnedUnitTrack = EmptyTrack;
	SpawnedUnitTrack.StateObject_OldState = History.GetGameStateForObjectID(SpawnedUnitValue.fValue, eReturnType_Reference, VisualizeGameState.HistoryIndex);
	SpawnedUnitTrack.StateObject_NewState = SpawnedUnitTrack.StateObject_OldState;
	SpawnedUnit = XComGameState_Unit(SpawnedUnitTrack.StateObject_NewState);
	`assert(SpawnedUnit != none);
	SpawnedUnitTrack.VisualizeActor = History.GetVisualizer(SpawnedUnit.ObjectID);

	// Only one target effect and it is X2Effect_SpawnSpire
	SpawnSpireEffect = X2Effect_SpawnSpire(Context.ResultContext.TargetEffectResults.Effects[0]);

	if( SpawnSpireEffect == none )
	{
		`RedScreenOnce("Headstone_BuildVisualization: Missing X2Effect_SpawnSpire");
		return;
	}

	// Build the tracks
	class'X2Action_ExitCover'.static.AddToVisualizationTree(ShooterTrack, Context, false, ShooterTrack.LastActionAdded);
	class'X2Action_AbilityPerkStart'.static.AddToVisualizationTree(ShooterTrack, Context, false, ShooterTrack.LastActionAdded);

	SpawnSpireEffect.AddSpawnVisualizationsToTracks(Context, SpawnedUnit, SpawnedUnitTrack, DeadUnit, DeadUnitTrack);

	class'X2Action_AbilityPerkEnd'.static.AddToVisualizationTree(ShooterTrack, Context, false, ShooterTrack.LastActionAdded);
	class'X2Action_EnterCover'.static.AddToVisualizationTree(ShooterTrack, Context, false, ShooterTrack.LastActionAdded);

	// sync the spire's visualizer to ensure cover status is reflected
	SpawnedUnit.SyncVisualizer();
}

private static function X2AbilityTemplate CreateKineticRigging()
{
	local X2AbilityTemplate Template;

	Template = PurePassive(default.NAME_KINETIC_RIGGING, "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_StunStrike");

	// the runner has to be able to activate the spire to use kinetic blast
	Template.AdditionalAbilities.AddItem(class'X2Ability_RunnerAbilitySet'.default.NAME_ACTIVATE_SPIRE); 

	return Template;
}

private static function X2AbilityTemplate CreateQuicksilver()
{
	local X2AbilityTemplate Template;

	Template = PurePassive(default.NAME_QUICKSILVER, "img:///UILibrary_PerkIcons.UIPerk_inspire");

	// the architect has to be able to activate the spire to use quicksilver
	Template.AdditionalAbilities.AddItem(class'X2Ability_RunnerAbilitySet'.default.NAME_ACTIVATE_SPIRE); 

	return PurePassive(default.NAME_QUICKSILVER, "img:///UILibrary_PerkIcons.UIPerk_runandgun");
}

private static function X2AbilityTemplate CreateUnity()
{
	return PurePassive(default.NAME_UNITY, "img:///UILibrary_PerkIcons.UIPerk_aethershift");
}

private static function X2AbilityTemplate CreateSoulOfTheArchitect()
{
	local X2AbilityTemplate Template;
	local X2Effect_LoadPerkContent LoadPerkContentEffect;
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

	LoadPerkContentEffect = new class'X2Effect_LoadPerkContent';
	LoadPerkContentEffect.BuildPersistentEffect(1, true, false);
	LoadPerkContentEffect.AbilitiesToLoad.AddItem(default.NAME_SOUL_OF_THE_ARCHITECT);
	Template.AddTargetEffect(LoadPerkContentEffect);	

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

private static function X2AbilityTemplate CreateDeadbolt()
{
	local X2AbilityTemplate Template;
	local X2Effect_Deadbolt DeadboltEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, default.NAME_DEADBOLT);

	// HUD behavior
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_equip";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	// targeting and ability to hit
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityToHitCalc = default.DeadEye;

	// triggering
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	DeadboltEffect = new class'X2Effect_Deadbolt';
	DeadboltEffect.BuildPersistentEffect(1, true);
	DeadboltEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage,,,Template.AbilitySourceName);
	Template.AddTargetEffect(DeadboltEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;
}

DefaultProperties 
{
	NAME_ACTIVATE_SPIRE=Jammerware_JSRC_Ability_ActivateSpire
	NAME_DEADBOLT=Jammerware_JSRC_Ability_Deadbolt
	NAME_FIELD_RELOAD_MODULE=Jammerware_JSRC_Ability_FieldReloadModule
	NAME_HEADSTONE=Jammerware_JSRC_Ability_Headstone
	NAME_KINETIC_RIGGING=Jammerware_JSRC_Ability_KineticRigging
	NAME_LOAD_PERK_CONTENT=Jammerware_JSRC_ArchitectLoadPerkContent
	NAME_QUICKSILVER=Jammerware_JSRC_Ability_Quicksilver
	NAME_RECLAIM=Jammerware_JSRC_Ability_Reclaim
	NAME_SHELTER=Jammerware_JSRC_Ability_Shelter
	NAME_SOUL_OF_THE_ARCHITECT=Jammerware_JSRC_Ability_SoulOfTheArchitect
	NAME_UNITY=Jammerware_JSRC_Ability_Unity
}