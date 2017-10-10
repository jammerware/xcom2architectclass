class X2Ability_RunnerAbilitySet extends X2Ability
	config(JammerwareRunnerClass);

var config int CREATESPIRE_COOLDOWN;

// ability names
var name NAME_QUICKSILVER;
var name NAME_SHELTER;
var name NAME_SOUL_OF_THE_ARCHITECT;

// ability numbers
var float RANGE_SHELTER_SHIELD;

static function array <X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	Templates.Length = 0;

	// SQUADDIE!
	Templates.AddItem(AddCreateSpire());
	
	// CORPORAL!
	Templates.AddItem(AddShelter());
	Templates.AddItem(AddQuicksilver());

	// COLONEL!
	Templates.AddItem(AddSoulOfTheArchitect());

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
	return PurePassive(default.NAME_SHELTER, "img:///UILibrary_PerkIcons.UIPerk_adventshieldbearer_energyshield");
}

static function X2AbilityTemplate AddQuicksilver()
{
	return PurePassive(default.NAME_QUICKSILVER, "img:///UILibrary_PerkIcons.UIPerk_runandgun");
}

static function X2AbilityTemplate AddSoulOfTheArchitect()
{
	local X2AbilityTemplate Template;

	Template = PurePassive(default.NAME_SOUL_OF_THE_ARCHITECT, "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_Pillar");
	Template.AdditionalAbilities.AddItem(class'X2Ability_SpireAbilitySet'.default.NAME_SPIRE_SHELTER);

	return Template;
}

// these are the abilities that are granted to the spire if the runner has them
static function array<name> GetSpireSharedAbilities()
{
	local array<name> SpireAbilities;

	SpireAbilities.AddItem(default.NAME_SHELTER);

	return SpireAbilities;
}

defaultproperties 
{
	NAME_QUICKSILVER = Jammerware_JSRC_Ability_Quicksilver
	NAME_SHELTER = Jammerware_JSRC_Ability_Shelter
	NAME_SOUL_OF_THE_ARCHITECT = Jammerware_JSRC_Ability_SoulOfTheArchitect
}