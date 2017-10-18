class Jammerware_SpireSharedAbilitiesService extends Object;

function ConfigureSpireAbilitiesFromSourceUnit(XComGameState_Unit SpireUnit, XComGameState_Unit SourceUnit, XComGameState NewGameState)
{
	// TODO: eventually some kind of associative array would be better here
	// note that some abilities need to be registered to an item, like shelter
	InitSpireAbilityFromRunnerAbility
	(
		SourceUnit, 
		SpireUnit, 
		class'X2Ability_RunnerAbilitySet'.default.NAME_SHELTER, 
		class'X2Ability_SpireShelter'.default.NAME_SPIRE_SHELTER,
		NewGameState,
		SourceUnit.GetSecondaryWeapon().GetReference()
	);
	InitSpireAbilityFromRunnerAbility
	(
		SourceUnit, 
		SpireUnit, 
		class'X2Ability_RunnerAbilitySet'.default.NAME_QUICKSILVER, 
		class'X2Ability_SpireAbilitySet'.default.NAME_SPIRE_QUICKSILVER,
		NewGameState
	);
	InitSpireAbilityFromRunnerAbility
	(
		SourceUnit, 
		SpireUnit, 
		class'X2Ability_RunnerAbilitySet'.default.NAME_LIGHTNINGROD, 
		class'X2Ability_SpireAbilitySet'.default.NAME_SPIRE_LIGHTNINGROD,
		NewGameState,
		SourceUnit.GetSecondaryWeapon().GetReference()
	);
}

function InitSpireAbilityFromRunnerAbility(
	XComGameState_Unit RunnerUnit, 
	XComGameState_Unit SpireUnit, 
	name RunnerAbilityName, 
	name SpireAbilityName, 
	XComGameState NewGameState,
	optional StateObjectReference WeaponRef)
{
	local Jammerware_GameStateEffectsService EffectsService;
	local X2AbilityTemplate SharedAbilityTemplate;
	local X2AbilityTemplateManager TemplateManager;

	EffectsService = new class'Jammerware_GameStateEffectsService';
	TemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	if (EffectsService.IsUnitAffectedByEffect(RunnerUnit, RunnerAbilityName))
	{
		SharedAbilityTemplate = TemplateManager.FindAbilityTemplate(SpireAbilityName);
		`LOG("JSRC: initing" @ SharedAbilityTemplate.DataName @ "for" @ SpireUnit.GetMyTemplate().DataName);
		`TACTICALRULES.InitAbilityForUnit(SharedAbilityTemplate, SpireUnit, NewGameState, WeaponRef);
	}
}