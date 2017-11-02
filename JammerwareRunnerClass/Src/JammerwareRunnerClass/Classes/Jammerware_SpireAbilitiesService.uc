class Jammerware_SpireAbilitiesService extends Object;

function ConfigureSpireAbilities(XComGameState_Unit SpireUnit, XComGameState_Unit SourceUnit, XComGameState NewGameState)
{
	local X2AbilityTemplateManager TemplateManager;
	local X2AbilityTemplate DecommissionTemplate;

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
		class'X2Ability_KineticPulse'.default.NAME_KINETICPULSE,
		NewGameState,
		SourceUnit.GetSecondaryWeapon().GetReference()
	);

	// if the spire has any active abilities, also give it decommission so they don't have to keep ending turn on it if they
	// don't want to
	// this may not be a release thing (spires may deactivate or die when the runner is out of range?)
	
	if (SpireHasActiveAbility(SpireUnit, NewGameState))
	{
		TemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
		DecommissionTemplate = TemplateManager.FindAbilityTemplate(class'X2Ability_SpireAbilitySet'.default.NAME_DECOMMISSION);
		`TACTICALRULES.InitAbilityForUnit(DecommissionTemplate, SpireUnit, NewGameState);
	}
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

private function bool SpireHasActiveAbility(XComGameState_Unit SpireState, XComGameState GameState)
{
	local X2AbilityTemplate SpireAbilityTemplate;
	local XComGameState_Ability SpireAbilityState;
	local StateObjectReference SpireAbilityRef;
	local X2AbilityTrigger SpireAbilityTrigger;

	foreach SpireState.Abilities(SpireAbilityRef)
	{
		SpireAbilityState = XComGameState_Ability(GameState.GetGameStateForObjectID(SpireAbilityRef.ObjectID));
		SpireAbilityTemplate = SpireAbilityState.GetMyTemplate();

		foreach SpireAbilityTemplate.AbilityTriggers(SpireAbilityTrigger)
		{
			if (SpireAbilityTrigger.IsA('X2AbilityTrigger_PlayerInput'))
			{
				return true;
			}
		}
	}

	return false;
}