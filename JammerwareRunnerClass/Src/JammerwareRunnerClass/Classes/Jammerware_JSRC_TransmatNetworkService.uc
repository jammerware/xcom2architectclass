class Jammerware_JSRC_TransmatNetworkService extends Object;

// add the transmat ability (that works with the runner's transmat network) to a lot of things
function RegisterTransmatAbilityToCharacterTemplates()
{
    local X2CharacterTemplateManager CharacterTemplateManager;
    local X2CharacterTemplate CharTemplate;
    local array<X2DataTemplate> DataTemplates;
    local X2DataTemplate Template, DiffTemplate;

    CharacterTemplateManager = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager();

    foreach CharacterTemplateManager.IterateTemplates(Template, None)
    {
        CharacterTemplateManager.FindDataTemplateAllDifficulties(Template.DataName, DataTemplates);
        foreach DataTemplates(DiffTemplate)
        {
            CharTemplate = X2CharacterTemplate(DiffTemplate);

            if (IsCharacterEligibleForTransmat(CharTemplate))
            {
                `LOG("JSRC: registering Transmat ability for" @ CharTemplate.DataName);
                CharTemplate.Abilities.AddItem(class'X2Ability_TransmatNetwork'.default.NAME_TRANSMAT);
            }
        }
    }
}

function bool IsCharacterEligibleForTransmat(X2CharacterTemplate Template)
{
    return 
        !Template.bSkipDefaultAbilities && 
        Template.DefaultLoadout != '';
}