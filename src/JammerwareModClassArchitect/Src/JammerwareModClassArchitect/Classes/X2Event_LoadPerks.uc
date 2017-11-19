// i created this method of loading perks based on the work done by /u/stormhunter117 here:
// https://www.reddit.com/r/xcom2mods/wiki/wotc_modding/scripting/xcomperkcontent_fix
class X2Event_LoadPerks extends X2EventListener;

var name NAME_BUILD_PERK_PACKAGE_CACHE;

struct PerkRegistration
{
	var name Ability;
	var name CharacterGroupName;
    var name SoldierClassName;
    var eTeam Team;
};

public static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(Create_OnUnitBeginPlay_LoadPerks());

	return Templates;
}

private static function X2DataTemplate Create_OnUnitBeginPlay_LoadPerks()
{
    local X2EventListenerTemplate_LoadPerks Template;

	`CREATE_X2TEMPLATE(class'X2EventListenerTemplate_LoadPerks', Template, default.NAME_BUILD_PERK_PACKAGE_CACHE);

    // all my perks are currently triggered by xcom units - the template doesn't even try to evaluate perks if the unit isn't xcom as an optimization
    Template.ListenForTeam = eTeam_XCom;

    // perk registrations (architect)
    Template.AddPerkToRegister(class'JsrcAbility_ActivateSpire'.default.NAME_ABILITY, 'Jammerware_JSRC_Class_Architect');
    Template.AddPerkToRegister(class'JsrcAbility_SoulOfTheArchitect'.default.NAME_ABILITY, 'Jammerware_JSRC_Class_Architect');
    Template.AddPerkToRegister(class'JsrcAbility_Quicksilver'.default.NAME_SPIRE_QUICKSILVER, 'Jammerware_JSRC_Class_Architect');

    // perk registrations (spire)
    Template.AddPerkToRegister(class'JsrcAbility_Shelter'.default.NAME_SPIRE_SHELTER, , class'X2Character_Spire'.default.NAME_CHARACTERGROUP_SPIRE);
    Template.AddPerkToRegister(class'JsrcAbility_Quicksilver'.default.NAME_SPIRE_QUICKSILVER, ,class'X2Character_Spire'.default.NAME_CHARACTERGROUP_SPIRE);

    // perk registrations (every unit ever)
    Template.AddPerkToRegister(class'JsrcAbility_TransmatNetwork'.default.NAME_TRANSMAT,,, eTeam_XCom);

    // fire it up on unit begin play
	Template.AddEvent('OnUnitBeginPlay', OnUnitBeginPlay);

	return Template;
}

private static function EventListenerReturn OnUnitBeginPlay(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
    local XComGameState_Unit UnitState;
    local X2EventListenerTemplate_LoadPerks LoadPerksTemplate;

    UnitState = XComGameState_Unit(EventSource);
    if (UnitState != none)
    {
        LoadPerksTemplate = GetLoadPerksTemplate(default.NAME_BUILD_PERK_PACKAGE_CACHE);

        if (LoadPerksTemplate.ListenForTeam == eTeam_None || UnitState.GetTeam() == LoadPerksTemplate.ListenForTeam)
            RegisterPerksFor(UnitState, LoadPerksTemplate.PerksToRegister);
    }
    
    return ELR_NoInterrupt;
}

private static function RegisterPerksFor(XComGameState_Unit UnitState, array<PerkRegistration> PerksToRegister)
{
    local PerkRegistration PerkRegistrationIterator;
    local X2SoldierClassTemplate ClassTemplate;
    local X2CharacterTemplate CharacterTemplate;
    
    ClassTemplate = UnitState.GetSoldierClassTemplate();
    CharacterTemplate = UnitState.GetMyTemplate();

    foreach PerksToRegister(PerkRegistrationIterator) 
    {
        if (PerkRegistrationIterator.CharacterGroupName != 'None' && CharacterTemplate.CharacterGroupName == PerkRegistrationIterator.CharacterGroupName)
        {
            RegisterPerk(UnitState, PerkRegistrationIterator.Ability);
        }
        else if (PerkRegistrationIterator.SoldierClassName != 'None' && ClassTemplate.DataName == PerkRegistrationIterator.SoldierClassName)
        {
            RegisterPerk(UnitState, PerkRegistrationIterator.Ability);
        }
        else if (PerkRegistrationIterator.Team != eTeam_None && UnitState.GetTeam() == PerkRegistrationIterator.Team)
        {
            RegisterPerk(UnitState, PerkRegistrationIterator.Ability);
        }
    }
}

private static function RegisterPerk(XComGameState_Unit Unit, name Ability)
{
    local XComContentManager Content;
    local XComUnitPawnNativeBase UnitPawnNativeBase;

    Content = `CONTENT;
    UnitPawnNativeBase = XGUnit(Unit.GetVisualizer()).GetPawn();
    if(UnitPawnNativeBase == none) 
    {
        `LOG("Warning, was unable to find a UnitPawnNativeBase for X2Effect_LoadPerkContent!");
        return;
    }

    Content.CachePerkContent(Ability);
    Content.AppendAbilityPerks(Ability, UnitPawnNativeBase);
    `LOG("JSRC: registered perk" @ Ability @ "to" @ Unit.GetFullName());
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