class Jammerware_JSRC_SpireAbilitiesService extends Object;

function ConfigureSpireAbilities(XComGameState_Unit SpireUnit, XComGameState_Unit SourceUnit, XComGameState NewGameState)
{
	// TODO: this'll be refactored to use conditions rather than hotloading the abilities
	// tracked in https://github.com/jammerware/xcom2architectclass/issues/24
	InitSpireAbilityFromRunnerAbility
	(
		SourceUnit,
		SpireUnit,
		class'X2Ability_FieldReloadArray'.default.NAME_ABILITY,
		class'X2Ability_FieldReloadArray'.default.NAME_SPIRE_ABILITY,
		NewGameState,
		SourceUnit.GetSecondaryWeapon().GetReference()
	);
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
		class'X2Ability_TargetingArray'.default.NAME_TARGETING_ARRAY, 
		class'X2Ability_TargetingArray'.default.NAME_TARGETING_ARRAY_SPIRE,
		NewGameState,
		SourceUnit.GetSecondaryWeapon().GetReference()
	);
	InitSpireAbilityFromRunnerAbility
	(
		SourceUnit, 
		SpireUnit, 
		class'X2Ability_TargetingArray'.default.NAME_TARGETING_ARRAY, 
		class'X2Ability_TargetingArray'.default.NAME_TARGETING_ARRAY_SPIRE_TRIGGERED,
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
		class'X2Ability_RunnerAbilitySet'.default.NAME_KINETIC_RIGGING,
		class'X2Ability_KineticBlast'.default.NAME_KINETICBLAST,
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