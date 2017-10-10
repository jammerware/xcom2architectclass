class Jammerware_SpireSharedAbilitiesService extends Object;

function ConfigureSpireAbilitiesFromSourceUnit(XComGameState_Unit SourceUnit, out array<AbilitySetupData> SetupData)
{
    local int LoopIndex;
	local Jammerware_GameStateEffectsService EffectsService;
	local array<name> SpireSharedAbilities;
	local X2AbilityTemplate SharedAbilityTemplate;
	local AbilitySetupData SharedAbilitySetupData;

	EffectsService = new class'Jammerware_GameStateEffectsService';
	SpireSharedAbilities = class'X2Ability_RunnerAbilitySet'.static.GetSpireSharedAbilities();

	for (LoopIndex = 0; LoopIndex < SpireSharedAbilities.Length; LoopIndex++)
	{
		if (EffectsService.IsUnitAffectedByEffect(SourceUnit, SpireSharedAbilities[LoopIndex])) 
		{
			SharedAbilityTemplate = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager().FindAbilityTemplate(SpireSharedAbilities[LoopIndex]);
			if (SharedAbilityTemplate != none)
			{
				SharedAbilitySetupData.Template = SharedAbilityTemplate;
				SharedAbilitySetupData.TemplateName = SharedAbilityTemplate.DataName;
				SetupData.AddItem(SharedAbilitySetupData);
			}
		}
	}
}