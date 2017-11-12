// i created this method of loading perks based on the work done by /u/stormhunter117 here:
// https://www.reddit.com/r/xcom2mods/wiki/wotc_modding/scripting/xcomperkcontent_fix
class X2Event_LoadPerks extends X2EventListener;

var name NAME_BUILD_PERK_PACKAGE_CACHE;

struct PerkRegistration
{
	var name Ability;
	var name CharacterGroupName;
    var name SoldierClassName;
};

public static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

    Templates.AddItem(Create_OnTacticalBeginPlay_BuildPerkPackageCache());
	Templates.AddItem(Create_OnUnitBeginPlay_LoadPerks());

	return Templates;
}

private static function X2DataTemplate Create_OnTacticalBeginPlay_BuildPerkPackageCache()
{
    local X2EventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'X2EventListenerTemplate_LoadPerks', Template, default.NAME_BUILD_PERK_PACKAGE_CACHE);
    Template.AddEvent('OnTacticalBeginPlay', OnTacticalBeginPlay);

    return Template;
}

private static function EventListenerReturn OnTacticalBeginPlay(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
    `CONTENT.BuildPerkPackageCache();
    return ELR_NoInterrupt;
}

private static function X2DataTemplate Create_OnUnitBeginPlay_LoadPerks()
{
    local X2EventListenerTemplate_LoadPerks Template;

	`CREATE_X2TEMPLATE(class'X2EventListenerTemplate_LoadPerks', Template, 'Jammerware_JSRC_EventListener_LoadPerksOnTacticalBegin');
    Template.AddPerkToRegister(class'X2Ability_RunnerAbilitySet'.default.NAME_ACTIVATE_SPIRE, 'Jammerware_JSRC_Class_Architect');
    Template.AddPerkToRegister(class'X2Ability_RunnerAbilitySet'.default.NAME_SOUL_OF_THE_ARCHITECT, 'Jammerware_JSRC_Class_Architect');
	Template.AddEvent('OnUnitBeginPlay', OnUnitBeginPlay);

	return Template;
}

private static function EventListenerReturn OnUnitBeginPlay(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
    local XComGameState_Unit UnitState;
    local X2EventListenerTemplate_LoadPerks LoadPerksTemplate;

    UnitState = XComGameState_Unit(EventSource);
    LoadPerksTemplate = GetLoadPerksTemplate('Jammerware_JSRC_EventListener_LoadPerksOnTacticalBegin');

    if (LoadPerksTemplate.ListenForTeam == eTeam_All || UnitState.GetTeam() == LoadPerksTemplate.ListenForTeam)
        RegisterPerksFor(UnitState, LoadPerksTemplate.PerksToRegister);
    
    return ELR_NoInterrupt;
}

private static function RegisterPerksFor(XComGameState_Unit UnitState, array<PerkRegistration> PerksToRegister)
{
    local XComContentManager Content;
    local XComUnitPawnNativeBase UnitPawnNativeBase;
    local PerkRegistration PerkRegistrationIterator;
    local X2SoldierClassTemplate ClassTemplate;
    local X2CharacterTemplate CharacterTemplate;

    Content = `CONTENT;
    ClassTemplate = UnitState.GetSoldierClassTemplate();
    CharacterTemplate = UnitState.GetMyTemplate();
    UnitPawnNativeBase = XGUnit(UnitState.GetVisualizer()).GetPawn();

    if(UnitPawnNativeBase == none) 
    {
        `LOG("Warning, was unable to find a UnitPawnNativeBase for X2Effect_LoadPerkContent!");
        return;
    }

    foreach PerksToRegister(PerkRegistrationIterator) 
    {
        if (PerkRegistrationIterator.CharacterGroupName != 'None' && CharacterTemplate.CharacterGroupName == PerkRegistrationIterator.CharacterGroupName)
        {
            Content.CachePerkContent(PerkRegistrationIterator.Ability);
            Content.AppendAbilityPerks(PerkRegistrationIterator.Ability, UnitPawnNativeBase);
        }
        else if (PerkRegistrationIterator.SoldierClassName != 'None' && ClassTemplate.DataName == PerkRegistrationIterator.SoldierClassName)
        {
            Content.CachePerkContent(PerkRegistrationIterator.Ability);
            Content.AppendAbilityPerks(PerkRegistrationIterator.Ability, UnitPawnNativeBase);
        }
    }
}

private static function X2EventListenerTemplate_LoadPerks GetLoadPerksTemplate(name TemplateName)
{
	local X2EventListenerTemplateManager TemplateManager;
	local X2EventListenerTemplate_LoadPerks Template;

	TemplateManager = class'X2EventListenerTemplateManager'.static.GetEventListenerTemplateManager();
	Template = X2EventListenerTemplate_LoadPerks(TemplateManager.FindEventListenerTemplate(TemplateName));

	if(Template == none)
	{
		`Redscreen("GetLoadPerksTemplate(): Could not find template " $ TemplateName);
	}

	return Template;
}

DefaultProperties
{
    NAME_BUILD_PERK_PACKAGE_CACHE=Jammerware_JSRC_EventListener_BuildPerkPackageCache
}