class X2Ability_RunnerAbilitySet extends X2Ability
	config(JammerwareRunnerClass);

var config int CREATESPIRE_COOLDOWN;

static function array <X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	Templates.Length = 0;

	// SQUADDIE!
	//Templates.AddItem(AddCreateSpire());
	Templates.AddItem(AddCreateSpireUnit());
	
	// CORPORAL!
	Templates.AddItem(AddShelter());
	Templates.AddItem(AddShelterTrigger());
	Templates.AddItem(AddBuffMeUp());
	//Templates.AddItem(AddQuicksilver());

	`LOG("Jammerware's Runner Class: Creating templates - " @ string(Templates.Length));
	return Templates;
}

//static function X2AbilityTemplate AddCreateSpire()
//{
	//local X2AbilityTemplate	Template;
	//local X2AbilityTarget_Cursor Cursor;
	//local X2AbilityMultiTarget_Radius RadiusMultiTarget;
	//local X2AbilityCost_ActionPoints ActionPointCost;
	//local X2Effect_SpawnSpire SpireEffect;
	//local X2AbilityCooldown Cooldown;
//
	//`CREATE_X2ABILITY_TEMPLATE(Template, 'CreateSpire')
//
	//Template.AbilityToHitCalc = default.DeadEye;
	//Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	//Template.TargetingMethod = class'X2TargetingMethod_Pillar';
//
	//Cursor = new class'X2AbilityTarget_Cursor';
	//Cursor.bRestrictToSquadsightRange = true;
	//Template.AbilityTargetStyle = Cursor;
//
	//RadiusMultiTarget = new class'X2AbilityMultiTarget_Radius';
	//RadiusMultiTarget.fTargetRadius = 0.25; // small amount so it just grabs one tile
	//Template.AbilityMultiTargetStyle = RadiusMultiTarget;
//
	//ActionPointCost = new class'X2AbilityCost_ActionPoints';
	//ActionPointCost.iNumPoints = 1;
	//Template.AbilityCosts.AddItem(ActionPointCost);
//
	//Cooldown = new class'X2AbilityCooldown';
	//Cooldown.iNumTurns = default.CREATESPIRE_COOLDOWN;
	//Template.AbilityCooldown = Cooldown;
//
	//Template.AbilitySourceName = 'eAbilitySource_Perk';
	//Template.ActivationSpeech = 'InTheZone';
	//Template.CustomFireAnim = 'HL_SignalPoint';
//
	//Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	//Template.Hostility = eHostility_Defensive;
	//Template.IconImage = "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_Pillar";
	//Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";
	//Template.ConcealmentRule = eConceal_Never;
//
	//Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	//Template.AddShooterEffectExclusions();
//
	//SpireEffect = new class'X2Effect_SpawnSpire';
	//SpireEffect.BuildPersistentEffect(1, false, true, false, eGameRule_PlayerTurnBegin);	
	//// TODO: figure out why i can't use the pillar archetype 
	////SpireEffect.DestructibleArchetype = "FX_Templar_Pillar.Pillar_Destructible";
	//SpireEffect.DestructibleArchetype = "AdventPillars.Archetypes.ARC_AdventPillars_HiCov_1x1A";
	//Template.AddShooterEffect(SpireEffect);
//
	//Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//Template.BuildVisualizationFn = Spire_BuildVisualization;
	//
	//Template.SuperConcealmentLoss = class'X2AbilityTemplateManager'.default.SuperConcealmentStandardShotLoss;
	//Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.NonAggressiveChosenActivationIncreasePerUse;
//
	//return Template;
//}
//
//function Spire_BuildVisualization(XComGameState VisualizeGameState)
//{
	//local XComGameState_Destructible DestructibleState;
	//local VisualizationActionMetadata BuildTrack;
//
	//TypicalAbility_BuildVisualization(VisualizeGameState);
//
	//foreach VisualizeGameState.IterateByClassType(class'XComGameState_Destructible', DestructibleState)
	//{
		//break;
	//}
	//`assert(DestructibleState != none);
//
	//BuildTrack.StateObject_NewState = DestructibleState;
	//BuildTrack.StateObject_OldState = DestructibleState;
	//BuildTrack.VisualizeActor = `XCOMHISTORY.GetVisualizer(DestructibleState.ObjectID);
//
	//class'X2Action_ShowSpawnedDestructible'.static.AddToVisualizationTree(BuildTrack, VisualizeGameState.GetContext());
//}

static function X2AbilityTemplate AddCreateSpireUnit()
{
	local X2AbilityTemplate             Template;
	local X2AbilityCost_ActionPoints    ActionPointCost;
	local X2AbilityTarget_Cursor        CursorTarget;
	local X2AbilityMultiTarget_Radius   RadiusMultiTarget;
	local X2Effect_SpawnMimicBeacon     SpawnMimicBeacon;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'CreateSpireUnit');

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

	RadiusMultiTarget = new class'X2AbilityMultiTarget_Radius';
	RadiusMultiTarget.bUseWeaponRadius = true;
	RadiusMultiTarget.bIgnoreBlockingCover = true; // we don't need this, the squad viewer will do the appropriate things once thrown
	Template.AbilityMultiTargetStyle = RadiusMultiTarget;

	Template.TargetingMethod = class'X2TargetingMethod_MimicBeacon';
	Template.SkipRenderOfTargetingTemplate = true;

	Template.bUseThrownGrenadeEffects = true;

	SpawnMimicBeacon = new class'X2Effect_SpawnMimicBeacon';
	SpawnMimicBeacon.BuildPersistentEffect(1, false, true, false, eGameRule_PlayerTurnBegin);
	Template.AddShooterEffect(SpawnMimicBeacon);
	Template.AddShooterEffect(new class'X2Effect_BreakUnitConcealment');

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = MimicBeacon_BuildVisualization;

	Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.NonAggressiveChosenActivationIncreasePerUse;
		
	return Template;
}

simulated function MimicBeacon_BuildVisualization(XComGameState VisualizeGameState)
{
	local XComGameStateHistory History;
	local XComGameStateContext_Ability Context;
	local StateObjectReference InteractingUnitRef;
	local VisualizationActionMetadata EmptyTrack;
	local VisualizationActionMetadata SourceTrack, MimicBeaconTrack;
	local XComGameState_Unit MimicSourceUnit, SpawnedUnit;
	local UnitValue SpawnedUnitValue;
	local X2Effect_SpawnMimicBeacon SpawnMimicBeaconEffect;
	local X2Action_MimicBeaconThrow FireAction;
	local X2Action_PlayAnimation AnimationAction;

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

	// Configure the visualization track for the mimic beacon
	//******************************************************************************************
	MimicSourceUnit = XComGameState_Unit(VisualizeGameState.GetGameStateForObjectID(InteractingUnitRef.ObjectID));
	`assert(MimicSourceUnit != none);
	MimicSourceUnit.GetUnitValue(class'X2Effect_SpawnUnit'.default.SpawnedUnitValueName, SpawnedUnitValue);

	MimicBeaconTrack = EmptyTrack;
	MimicBeaconTrack.StateObject_OldState = History.GetGameStateForObjectID(SpawnedUnitValue.fValue, eReturnType_Reference, VisualizeGameState.HistoryIndex);
	MimicBeaconTrack.StateObject_NewState = MimicBeaconTrack.StateObject_OldState;
	SpawnedUnit = XComGameState_Unit(MimicBeaconTrack.StateObject_NewState);
	`assert(SpawnedUnit != none);
	MimicBeaconTrack.VisualizeActor = History.GetVisualizer(SpawnedUnit.ObjectID);

	// Set the Throwing Unit's FireAction to reference the spawned unit
	FireAction.MimicBeaconUnitReference = SpawnedUnit.GetReference();
	// Set the Throwing Unit's FireAction to reference the spawned unit
	class'X2Action_WaitForAbilityEffect'.static.AddToVisualizationTree(MimicBeaconTrack, Context);

	// Only one target effect and it is X2Effect_SpawnMimicBeacon
	SpawnMimicBeaconEffect = X2Effect_SpawnMimicBeacon(Context.ResultContext.ShooterEffectResults.Effects[0]);
	
	if( SpawnMimicBeaconEffect == none )
	{
		`RedScreenOnce("MimicBeacon_BuildVisualization: Missing X2Effect_SpawnMimicBeacon -dslonneger @gameplay");
		return;
	}

	SpawnMimicBeaconEffect.AddSpawnVisualizationsToTracks(Context, SpawnedUnit, MimicBeaconTrack, MimicSourceUnit, SourceTrack);

	class'X2Action_SyncVisualizer'.static.AddToVisualizationTree(MimicBeaconTrack, Context);

	AnimationAction = X2Action_PlayAnimation(class'X2Action_PlayAnimation'.static.AddToVisualizationTree(MimicBeaconTrack, Context));
	AnimationAction.Params.BlendTime = 0.0f;
}

static function X2AbilityTemplate AddShelter()
{
	local X2AbilityTemplate Template;

	Template = PurePassive('Shelter', "img:///UILibrary_PerkIcons.UIPerk_evervigilant");
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	Template.AdditionalAbilities.AddItem('ShelterTrigger');

	return Template;
}

static function X2AbilityTemplate AddShelterTrigger()
{
	local X2AbilityTemplate Template;
	local X2AbilityTrigger_EventListener Trigger;
	local X2Effect_Shelter ShelterEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ShelterTrigger');

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.EventID = 'ObjectMoved';
	Trigger.ListenerData.Filter = eFilter_Unit;
	Trigger.ListenerData.EventFn = ShelterTriggerListener;
	Template.AbilityTriggers.AddItem(Trigger);

	ShelterEffect = new class'X2Effect_Shelter';
	ShelterEffect.BuildPersistentEffect(1, true, false);
	// TODO: localize
	ShelterEffect.SetDisplayInfo(ePerkBuff_Bonus, "Shelter", "Contact with a spire has granted an energy shield.", "img:///UILibrary_PerkIcons.UIPerk_adventshieldbearer_energyshield", true);
	ShelterEffect.AddPersistentStatChange(eStat_ShieldHP, 1);
	ShelterEffect.EffectRemovedVisualizationFn = OnShieldRemoved_BuildVisualization;
	Template.AddShooterEffect(ShelterEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	
	return Template;
}

static function EventListenerReturn ShelterTriggerListener(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	`LOG("JSRC: event data" @ EventData);
	`LOG("JSRC: event src" @ EventSource);

	return ELR_NoInterrupt;
}

static function OnShieldRemoved_BuildVisualization(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata, const name EffectApplyResult)
{
	local X2Action_PlaySoundAndFlyOver SoundAndFlyOver;

	if (XGUnit(ActionMetadata.VisualizeActor).IsAlive())
	{
		SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, ActionMetadata.LastActionAdded));
		SoundAndFlyOver.SetSoundAndFlyOverParameters(None, class'XLocalizedData'.default.ShieldRemovedMsg, '', eColor_Bad, , 0.75, true);
	}
}

static function X2AbilityTemplate AddBuffMeUp() 
{
	local X2AbilityTemplate                 Template;
	local X2AbilityCost_ActionPoints        ActionPointCost;
	local X2AbilityTarget_Single            SingleTarget;
	local X2Condition_UnitProperty          UnitPropertyCondition;
	local X2AbilityTrigger_PlayerInput      InputTrigger;
	local X2Effect_PersistentStatChange StatChangeEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'BuffMeUp');

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	Template.AbilityCosts.AddItem(ActionPointCost);
	
	Template.AbilityToHitCalc = default.DeadEye;

	SingleTarget = new class'X2AbilityTarget_Single';
	SingleTarget.bIncludeSelf = true;
	Template.AbilityTargetStyle = SingleTarget;

	UnitPropertyCondition = new class'X2Condition_UnitProperty';
	UnitPropertyCondition.ExcludeDead = true;
	Template.AbilityShooterConditions.AddItem(UnitPropertyCondition);

	UnitPropertyCondition = new class'X2Condition_UnitProperty';
	UnitPropertyCondition.ExcludeDead = true;
	UnitPropertyCondition.ExcludeHostileToSource = true;
	UnitPropertyCondition.ExcludeFriendlyToSource = false;
	Template.AbilityTargetConditions.AddItem(UnitPropertyCondition);

	StatChangeEffect = new class'X2Effect_PersistentStatChange';
	StatChangeEffect.BuildPersistentEffect(1, true, false, true);
	StatChangeEffect.AddPersistentStatChange(eStat_ShieldHP, 3);
	Template.AddTargetEffect(StatChangeEffect);
	
	InputTrigger = new class'X2AbilityTrigger_PlayerInput';
	Template.AbilityTriggers.AddItem(InputTrigger);

	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_medkit";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.MEDIKIT_HEAL_PRIORITY;
	Template.Hostility = eHostility_Defensive;
	Template.bDisplayInUITooltip = false;
	Template.bLimitTargetIcons = true;
	Template.ActivationSpeech = 'HealingAlly';

	Template.CustomSelfFireAnim = 'FF_FireMedkitSelf';
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.NonAggressiveChosenActivationIncreasePerUse;

	return Template;
}