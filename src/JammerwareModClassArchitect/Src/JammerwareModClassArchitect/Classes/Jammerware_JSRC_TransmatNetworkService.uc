class Jammerware_JSRC_TransmatNetworkService extends Object;

// add the transmat ability (that works with the architect's transmat network) to a lot of things
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

            if (IsEligibleForTransmatAbility(CharTemplate))
            {
                CharTemplate.Abilities.AddItem(class'X2Ability_TransmatNetwork'.default.NAME_TRANSMAT);
            }
        }
    }
}

function bool IsEligibleForTransmatAbility(X2CharacterTemplate Template)
{
    return 
        !Template.bSkipDefaultAbilities && 
        Template.DefaultLoadout != '';
}

// tells us the id of the transmat network to which the unit belongs
// (this is basically either the spire's architect's ID or the architect themself's ID via SotA)
function int GetNetworkIDFromUnitState(XComGameState_Unit UnitState)
{
    local Jammerware_JSRC_SpireRegistrationService SpireRegistrationService;

    if (UnitState == none)
        return 0;

    if (UnitState.AffectedByEffectNames.Find(class'X2Ability_TransmatNetwork'.default.NAME_SPIRETRANSMATNETWORK) == INDEX_NONE)
    {
        `REDSCREEN("JSRC: the transmat network service couldn't get the network id for" @ UnitState.GetFullName());
        return 0;
    }

    // if the unit's a spire, get its architect
    if (UnitState.GetMyTemplate().CharacterGroupName == class'X2Character_Spire'.default.NAME_CHARACTERGROUP_SPIRE)
    {
        SpireRegistrationService = new class'Jammerware_JSRC_SpireRegistrationService';
        return SpireRegistrationService.GetRunnerFromSpire(UnitState.ObjectID).ObjectID;
    }

    // otherwise hopefully the unit is just an architect
    return UnitState.ObjectID;
}