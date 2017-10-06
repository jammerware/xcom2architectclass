class X2Ability_RunnerAbilitySet extends X2Ability
	config(JammerwareRunnerClass);

var config int CREATESPIRE_COOLDOWN;

// ability names
var name NAME_SHELTER;
var name NAME_SHELTER_SHIELD;
var name NAME_SOUL_OF_THE_ARCHITECT;

// ability numbers
var float RANGE_SHELTER_SHIELD;

static function array <X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	local int LoopIndex;
	Templates.Length = 0;

	// SQUADDIE!
	Templates.AddItem(AddCreateSpire());
	
	// CORPORAL!
	Templates.AddItem(AddShelter());
	Templates.AddItem(AddShelterShield());
	//Templates.AddItem(AddQuicksilver());

	// COLONEL!
	Templates.AddItem(AddSoulOfTheArchitect());

	`LOG("JSRC: runner ability templates created - " @ Templates.Length);
	for (LoopIndex = 0; LoopIndex < Templates.Length; LoopIndex++)
	{
		`LOG("JSRC: template name" @ Templates[LoopIndex].DataName);
	}

	return Templates;
}

static function X2AbilityTemplate AddCreateSpire()
{
	local X2AbilityTemplate Template;
	local X2AbilityCost_ActionPoints ActionPointCost;
	local X2AbilityTarget_Cursor CursorTarget;
	local X2Effect_SpawnSpire SpawnSpireEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'CreateSpire');

	Template.IconImage = "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_Pillar";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.Hostility = eHostility_Neutral;
	Template.bDisplayInUITacticalText = false;

	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.STANDARD_GRENADE_PRIORITY;

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = false;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	CursorTarget = new class'X2AbilityTarget_Cursor';
	CursorTarget.bRestrictToWeaponRange = true;
	Template.AbilityTargetStyle = CursorTarget;
	Template.TargetingMethod = class'X2TargetingMethod_Teleport';

	SpawnSpireEffect = new class'X2Effect_SpawnSpire';
	SpawnSpireEffect.BuildPersistentEffect(1, true);
	Template.AddShooterEffect(SpawnSpireEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = SpawnSpire_BuildVisualization;

	Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.NonAggressiveChosenActivationIncreasePerUse;
		
	return Template;
}

simulated function SpawnSpire_BuildVisualization(XComGameState VisualizeGameState)
{
	local XComGameStateHistory History;
	local XComGameStateContext_Ability Context;
	local StateObjectReference InteractingUnitRef;
	local VisualizationActionMetadata EmptyTrack;
	local VisualizationActionMetadata SourceTrack, SpireTrack;
	local XComGameState_Unit SpireSourceUnit, SpawnedUnit;
	local UnitValue SpawnedUnitValue;
	local X2Effect_SpawnSpire SpawnSpireEffect;
	local X2Action_MimicBeaconThrow FireAction;

	History = `XCOMHISTORY;

	Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());
	InteractingUnitRef = Context.InputContext.SourceObject;

	//Configure the visualization track for the shooter
	//****************************************************************************************
	SourceTrack = EmptyTrack;
	SourceTrack.StateObject_OldState = History.GetGameStateForObjectID(InteractingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
	SourceTrack.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(InteractingUnitRef.ObjectID);
	SourceTrack.VisualizeActor = History.GetVisualizer(InteractingUnitRef.ObjectID);

	class'X2Action_ExitCover'.static.AddToVisualizationTree(SourceTrack, Context);
	FireAction = X2Action_MimicBeaconThrow(class'X2Action_MimicBeaconThrow'.static.AddToVisualizationTree(SourceTrack, Context));
	class'X2Action_EnterCover'.static.AddToVisualizationTree(SourceTrack, Context);

	// Configure the visualization track for the spire
	//******************************************************************************************
	SpireSourceUnit = XComGameState_Unit(VisualizeGameState.GetGameStateForObjectID(InteractingUnitRef.ObjectID));
	`assert(SpireSourceUnit != none);
	SpireSourceUnit.GetUnitValue(class'X2Effect_SpawnUnit'.default.SpawnedUnitValueName, SpawnedUnitValue);

	SpireTrack = EmptyTrack;
	SpireTrack.StateObject_OldState = History.GetGameStateForObjectID(SpawnedUnitValue.fValue, eReturnType_Reference, VisualizeGameState.HistoryIndex);
	SpireTrack.StateObject_NewState = SpireTrack.StateObject_OldState;
	SpawnedUnit = XComGameState_Unit(SpireTrack.StateObject_NewState);
	`assert(SpawnedUnit != none);
	SpireTrack.VisualizeActor = History.GetVisualizer(SpawnedUnit.ObjectID);

	// Set the Throwing Unit's FireAction to reference the spawned unit
	FireAction.MimicBeaconUnitReference = SpawnedUnit.GetReference();
	// Set the Throwing Unit's FireAction to reference the spawned unit
	class'X2Action_WaitForAbilityEffect'.static.AddToVisualizationTree(SpireTrack, Context);

	// Only one target effect and it is X2Effect_SpawnSpire
	SpawnSpireEffect = X2Effect_SpawnSpire(Context.ResultContext.ShooterEffectResults.Effects[0]);
	
	if (SpawnSpireEffect == none)
	{
		`RedScreen("JSRC: Spire_BuildVisualization: Missing X2Effect_SpawnSpire");
		return;
	}

	SpawnSpireEffect.AddSpawnVisualizationsToTracks(Context, SpawnedUnit, SpireTrack, SpireSourceUnit, SourceTrack);
	class'X2Action_SyncVisualizer'.static.AddToVisualizationTree(SpireTrack, Context);
}

static function X2AbilityTemplate AddShelter()
{
	local X2AbilityTemplate Template;

	Template = PurePassive(default.NAME_SHELTER, "img:///UILibrary_PerkIcons.UIPerk_evervigilant");
	Template.AdditionalAbilities.AddItem(default.NAME_SHELTER_SHIELD);

	return Template;
}

static function X2AbilityTemplate AddShelterShield()
{
	local X2AbilityTemplate Template;
	local X2AbilityTrigger_EventListener Trigger;
	local X2Effect_ShelterShield ShieldEffect;
	local X2Condition_UnitProperty TargetCondition;

	`CREATE_X2ABILITY_TEMPLATE(Template, default.NAME_SHELTER_SHIELD);

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
	TargetCondition = new class'X2Condition_UnitProperty';
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
	ShieldEffect.BuildPersistentEffect(2, false, true, , eGameRule_PlayerTurnEnd);
	ShieldEffect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.GetMyLongDescription(), "img:///UILibrary_PerkIcons.UIPerk_adventshieldbearer_energyshield", true);
	ShieldEffect.AddPersistentStatChange(eStat_ShieldHP, 3);
	Template.AddTargetEffect(ShieldEffect);

	// game state and visualization
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = ShelterShield_BuildVisualization;
	Template.bShowActivation = true;

	return Template;
}

simulated function ShelterShield_BuildVisualization(XComGameState VisualizeGameState)
{
	local XComGameStateHistory History;
	local XComGameStateContext_Ability  Context;
	local StateObjectReference InteractingUnitRef;
	local VisualizationActionMetadata EmptyTrack;
	local VisualizationActionMetadata ActionMetadata;
	local X2Action_PlayAnimation PlayAnimationAction;

	History = `XCOMHISTORY;

	Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());
	InteractingUnitRef = Context.InputContext.SourceObject;

	//Configure the visualization track for the shooter
	//****************************************************************************************
	ActionMetadata = EmptyTrack;
	ActionMetadata.StateObject_OldState = History.GetGameStateForObjectID(InteractingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
	ActionMetadata.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(InteractingUnitRef.ObjectID);
	ActionMetadata.VisualizeActor = History.GetVisualizer(InteractingUnitRef.ObjectID);

	// TODO: this is busted
	//PlayAnimationAction = X2Action_PlayAnimation(class'X2Action_PlayAnimation'.static.AddToVisualizationTree(ActionMetadata, Context, false, ActionMetadata.LastActionAdded));
	//PlayAnimationAction.Params.AnimName = 'HL_EnergyShield';
}

static function X2AbilityTemplate AddSoulOfTheArchitect()
{
	local X2AbilityTemplate Template;

	Template = PurePassive('Jammerware_JSRC_Ability_SoulOfTheArchitect', "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_Pillar");

	return Template;
}

defaultproperties 
{
	NAME_SHELTER = "Jammerware_JSRC_Ability_Shelter"
	NAME_SHELTER_SHIELD = "Jammerware_JSRC_Ability_ShelterShield"
	NAME_SOUL_OF_THE_ARCHITECT = "Jammerware_JSRC_Ability_SoulOfTheArchitect"
}