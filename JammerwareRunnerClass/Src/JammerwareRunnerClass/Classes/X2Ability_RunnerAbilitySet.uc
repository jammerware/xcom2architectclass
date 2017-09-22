class X2Ability_RunnerAbilitySet extends X2Ability
	config(JammerwareRunnerClass);

var config int CREATESPIRE_COOLDOWN;

static function array <X2DataTemplate> CreateTemplates()
{
	// TODO: expose values and strings to config and localization, respectively, sort of like this:
	// var config int ParallaxCooldown;
	
	local array<X2DataTemplate> Templates;
	Templates.Length = 0;

	// SQUADDIE!
	Templates.AddItem(AddCreateSpire());

	`LOG("Jammerware's Runner Class: Creating templates - " @ string(Templates.Length));
	return Templates;
}

static function X2AbilityTemplate AddCreateSpire()
{
	local X2AbilityTemplate	Template;
	local X2AbilityTarget_Cursor Cursor;
	local X2AbilityMultiTarget_Radius RadiusMultiTarget;
	local X2AbilityCost_ActionPoints ActionPointCost;
	local X2Effect_SpawnDestructible SpireEffect;
	local X2AbilityCooldown Cooldown;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'CreateSpire')

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	Template.TargetingMethod = class'X2TargetingMethod_Pillar';

	Cursor = new class'X2AbilityTarget_Cursor';
	Cursor.bRestrictToSquadsightRange = true;
	Template.AbilityTargetStyle = Cursor;

	RadiusMultiTarget = new class'X2AbilityMultiTarget_Radius';
	RadiusMultiTarget.fTargetRadius = 0.25; // small amount so it just grabs one tile
	Template.AbilityMultiTargetStyle = RadiusMultiTarget;

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.CREATESPIRE_COOLDOWN;
	Template.AbilityCooldown = Cooldown;

	//Template.AbilitySourceName = 'eAbilitySource_Psionic';
	//Template.CustomFireAnim = 'HL_Pillar';
	Template.ActivationSpeech = 'InTheZone';

	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.Hostility = eHostility_Defensive;
	Template.IconImage = "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_Pillar";
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";
	Template.ConcealmentRule = eConceal_Never;

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	SpireEffect = new class'X2Effect_SpawnSpire';
	SpireEffect.BuildPersistentEffect(1, false, true, false, eGameRule_PlayerTurnBegin);	
	SpireEffect.DestructibleArchetype = "FX_Templar_Pillar.Pillar_Destructible";
	Template.AddShooterEffect(SpireEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//Template.BuildVisualizationFn = Pillar_BuildVisualization;
	
	Template.SuperConcealmentLoss = class'X2AbilityTemplateManager'.default.SuperConcealmentStandardShotLoss;
	Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.NonAggressiveChosenActivationIncreasePerUse;

	return Template;
}

function Pillar_BuildVisualization(XComGameState VisualizeGameState)
{
	local XComGameState_Destructible DestructibleState;
	local VisualizationActionMetadata BuildTrack;

	TypicalAbility_BuildVisualization(VisualizeGameState);

	foreach VisualizeGameState.IterateByClassType(class'XComGameState_Destructible', DestructibleState)
	{
		break;
	}
	`assert(DestructibleState != none);

	BuildTrack.StateObject_NewState = DestructibleState;
	BuildTrack.StateObject_OldState = DestructibleState;
	BuildTrack.VisualizeActor = `XCOMHISTORY.GetVisualizer(DestructibleState.ObjectID);

	`LOG("Jammerware Runner Class: Visualize Actor is " @ BuildTrack.VisualizeActor);

	class'X2Action_ShowSpawnedDestructible'.static.AddToVisualizationTree(BuildTrack, VisualizeGameState.GetContext());
}