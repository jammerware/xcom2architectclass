class X2Ability_RunnerAbilitySet extends X2Ability
	config(JammerwareRunnerClass);

// ability names
var name NAME_HEADSTONE;
var name NAME_LIGHTNINGROD;
var name NAME_QUICKSILVER;
var name NAME_RECLAIM;
var name NAME_SHELTER;
var name NAME_SOUL_OF_THE_ARCHITECT;
var name NAME_UNITY;

// config/balance
var config int HEADSTONE_COOLDOWN;
var config int RECLAIM_COOLDOWN;

static function array <X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	// SQUADDIE!
	Templates.AddItem(class'X2Ability_SpawnSpire'.static.CreateSpawnSpire());
	
	// CORPORAL!
	Templates.AddItem(AddLightningRod());
	Templates.AddItem(AddShelter());

	// SERGEANT!
	Templates.AddItem(AddReclaim());

	// LIEUTENANT!
	Templates.AddItem(class'X2Ability_TargetingArray'.static.CreateTargetingArray());
	Templates.AddItem(class'X2Ability_TargetingArray'.static.CreateTargetingArrayTriggered());
	Templates.AddItem(class'X2Ability_TransmatLink'.static.CreateTransmatLink());

	// CAPTAIN!
	Templates.AddItem(AddHeadstone());
	Templates.AddItem(AddQuicksilver());

	// MAJOR!
	Templates.AddItem(CreateUnity());

	// COLONEL!
	Templates.AddItem(CreateSoulOfTheArchitect());
	Templates.AddItem(class'X2Ability_TransmatNetwork'.static.CreateRunnerTransmatNetwork());

	return Templates;
}

static function X2AbilityTemplate AddLightningRod()
{
	return PurePassive(default.NAME_LIGHTNINGROD, "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_volt");
}

static function X2AbilityTemplate AddShelter()
{
	return PurePassive(default.NAME_SHELTER, "img:///UILibrary_PerkIcons.UIPerk_adventshieldbearer_energyshield");
}

static function X2AbilityTemplate AddQuicksilver()
{
	return PurePassive(default.NAME_QUICKSILVER, "img:///UILibrary_PerkIcons.UIPerk_runandgun");
}

static function X2AbilityTemplate AddReclaim()
{
	local X2AbilityTemplate Template;
	local X2AbilityCost_ActionPoints ActionPointCost;
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
	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = false;
	Template.AbilityCosts.AddItem(ActionPointCost);

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

static function X2AbilityTemplate AddHeadstone()
{
	local X2AbilityTemplate Template;
	local X2AbilityCost_ActionPoints ActionPointCost;
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
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_LIEUTENANT_PRIORITY;
	Template.bLimitTargetIcons = true;

	// cost
	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = false;
	Template.AbilityCosts.AddItem(ActionPointCost);

	// Cooldown
	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.HEADSTONE_COOLDOWN;
	Template.AbilityCooldown = Cooldown;

	// targeting style (how targets are determined by game rules)
	Template.AbilityTargetStyle = default.SimpleSingleTarget;

	// hit chance
	Template.AbilityToHitCalc = default.DeadEye;

	// conditions
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AbilityTargetConditions.AddItem(default.GameplayVisibilityCondition);

	DeadEnemiesCondition = new class 'X2Condition_UnitProperty';
	DeadEnemiesCondition.ExcludeAlive = true;
	DeadEnemiesCondition.ExcludeDead = false;
	DeadEnemiesCondition.ExcludeHostileToSource = false;
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

static function Headstone_BuildVisualization(XComGameState VisualizeGameState)
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
}

static function X2AbilityTemplate CreateUnity()
{
	return PurePassive(default.NAME_UNITY, "img:///UILibrary_PerkIcons.UIPerk_aethershift");
}

static function X2AbilityTemplate CreateSoulOfTheArchitect()
{
	local X2AbilityTemplate Template;

	Template = PurePassive(default.NAME_SOUL_OF_THE_ARCHITECT, "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_Pillar");
	Template.AdditionalAbilities.AddItem(class'X2Ability_SpireAbilitySet'.default.NAME_SPIRE_LIGHTNINGROD);
	Template.AdditionalAbilities.AddItem(class'X2Ability_SpireShelter'.default.NAME_SPIRE_SHELTER);
	Template.AdditionalAbilities.AddItem(class'X2Ability_SpireAbilitySet'.default.NAME_SPIRE_QUICKSILVER);

	return Template;
}

defaultproperties 
{
	NAME_HEADSTONE=Jammerware_JSRC_Ability_Headstone
	NAME_LIGHTNINGROD=Jammerware_JSRC_Ability_LightningRod
	NAME_QUICKSILVER=Jammerware_JSRC_Ability_Quicksilver
	NAME_RECLAIM=Jammerware_JSRC_Ability_Reclaim
	NAME_SHELTER=Jammerware_JSRC_Ability_Shelter
	NAME_SOUL_OF_THE_ARCHITECT=Jammerware_JSRC_Ability_SoulOfTheArchitect
	NAME_UNITY=Jammerware_JSRC_Ability_Unity
}