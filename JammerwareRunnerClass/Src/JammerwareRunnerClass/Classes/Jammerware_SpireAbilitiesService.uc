class Jammerware_SpireAbilitiesService extends Object;

function ConfigureSpireAbilities(XComGameState_Unit SpireUnit, XComGameState_Unit SourceUnit, XComGameState NewGameState)
{
	// TODO: eventually some kind of associative array would be better here
	// note that some abilities need to be registered to an item, like shelter
	InitSpireAbilityFromRunnerAbility
	(
		SourceUnit, 
		SpireUnit, 
		class'X2Ability_RunnerAbilitySet'.default.NAME_SHELTER, 
		class'X2Ability_SpireAbilitySet'.default.NAME_SPIRE_SHELTER,
		NewGameState,
		SourceUnit.GetSecondaryWeapon().GetReference()
	);
	InitSpireAbilityFromRunnerAbility
	(
		SourceUnit, 
		SpireUnit, 
		class'X2Ability_RunnerAbilitySet'.default.NAME_QUICKSILVER, 
		class'X2Ability_SpireAbilitySet'.default.NAME_SPIRE_QUICKSILVER,
		NewGameState,
		SourceUnit.GetSecondaryWeapon().GetReference()
	);
	InitSpireAbilityFromRunnerAbility
	(
		SourceUnit,
		SpireUnit,
		class'X2Ability_TransmatNetwork'.default.NAME_TRANSMATNETWORK,
		class'X2Ability_TransmatNetwork'.default.NAME_SPIRETRANSMATNETWORK,
		NewGameState,
	);
	InitSpireAbilityFromRunnerAbility
	(
		SourceUnit,
		SpireUnit,
		class'X2Ability_RunnerAbilitySet'.default.NAME_KINETIC_RIGGING,
		class'X2Ability_KineticBlast'.default.NAME_KINETICBLAST,
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
	local X2AbilityTemplate SharedAbilityTemplate;
	local X2AbilityTemplateManager TemplateManager;

	TemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	if (RunnerUnit.AffectedByEffectNames.Find(RunnerAbilityName) != INDEX_NONE)
	{
		SharedAbilityTemplate = TemplateManager.FindAbilityTemplate(SpireAbilityName);
		`LOG("JSRC: initing" @ SharedAbilityTemplate.DataName @ "for" @ SpireUnit.GetMyTemplate().DataName);
		`TACTICALRULES.InitAbilityForUnit(SharedAbilityTemplate, SpireUnit, NewGameState, WeaponRef);
	}
}