class Jammerware_SpireSharedAbilitiesService extends Object;

function ConfigureSpireAbilitiesFromSourceUnit(XComGameState_Unit SpireUnit, XComGameState_Unit SourceUnit, XComGameState NewGameState)
{
	local Jammerware_GameStateEffectsService EffectsService;
	local X2AbilityTemplate SharedAbilityTemplate;
	local X2AbilityTemplateManager TemplateManager;

	EffectsService = new class'Jammerware_GameStateEffectsService';
	TemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	// TODO: eventually some kind of associative array would be better here
	// note that some abilities need to be registered to an item, like lightning rod
	if (EffectsService.IsUnitAffectedByEffect(SourceUnit, class'X2Ability_RunnerAbilitySet'.default.NAME_SHELTER))
	{
		SharedAbilityTemplate = TemplateManager.FindAbilityTemplate(class'X2Ability_SpireAbilitySet'.default.NAME_SPIRE_SHELTER);
		`LOG("JSRC: initing" @ SharedAbilityTemplate.DataName @ "for" @ SpireUnit.GetMyTemplate().DataName);
		`TACTICALRULES.InitAbilityForUnit(SharedAbilityTemplate, SpireUnit, NewGameState);
	}

	if (EffectsService.IsUnitAffectedByEffect(SourceUnit, class'X2Ability_RunnerAbilitySet'.default.NAME_QUICKSILVER))
	{
		SharedAbilityTemplate = TemplateManager.FindAbilityTemplate(class'X2Ability_SpireAbilitySet'.default.NAME_SPIRE_QUICKSILVER);
		`LOG("JSRC: initing" @ SharedAbilityTemplate.DataName @ "for" @ SpireUnit.GetMyTemplate().DataName);
		`TACTICALRULES.InitAbilityForUnit(SharedAbilityTemplate, SpireUnit, NewGameState);
	}

	if (EffectsService.IsUnitAffectedByEffect(SourceUnit, class'X2Ability_RunnerAbilitySet'.default.NAME_LIGHTNINGROD))
	{
		SharedAbilityTemplate = TemplateManager.FindAbilityTemplate(class'X2Ability_SpireAbilitySet'.default.NAME_SPIRE_LIGHTNINGROD);
		`LOG("JSRC: initing" @ SharedAbilityTemplate.DataName @ "for" @ SpireUnit.GetMyTemplate().DataName);
		`TACTICALRULES.InitAbilityForUnit(SharedAbilityTemplate, SpireUnit, NewGameState, SourceUnit.GetSecondaryWeapon().GetReference());
	}
}