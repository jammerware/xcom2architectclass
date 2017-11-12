class X2Character_Spire extends X2Character;

var name NAME_CHARACTERGROUP_SPIRE;
var name NAME_CHARACTER_SPIRE_CONVENTIONAL;
var name NAME_CHARACTER_SPIRE_MAGNETIC;
var name NAME_CHARACTER_SPIRE_BEAM;

static function array<X2DataTemplate> CreateTemplates()
{
    local array<X2DataTemplate> Templates;

    Templates.AddItem(CreateSpire_Conventional());
	Templates.AddItem(CreateSpire_Magnetic());
	Templates.AddItem(CreateSpire_Beam());

    return Templates;
}

static function X2CharacterTemplate CreateSpire_Conventional()
{
	local X2CharacterTemplate Template;

	Template = CreateDefaultSpire(default.NAME_CHARACTER_SPIRE_CONVENTIONAL);
	Template.DefaultLoadout='Jammerware_JSRC_Loadout_Spire_Conventional';

	return Template;
}

static function X2CharacterTemplate CreateSpire_Magnetic()
{
	local X2CharacterTemplate Template;

	Template = CreateDefaultSpire(default.NAME_CHARACTER_SPIRE_MAGNETIC);
	Template.DefaultLoadout='Jammerware_JSRC_Loadout_Spire_Magnetic';

	return Template;
}

static function X2CharacterTemplate CreateSpire_Beam()
{
	local X2CharacterTemplate Template;

	Template = CreateDefaultSpire(default.NAME_CHARACTER_SPIRE_BEAM);
	Template.DefaultLoadout='Jammerware_JSRC_Loadout_Spire_Beam';

	return Template;
}

private static function X2CharacterTemplate CreateDefaultSpire(name TemplateName)
{
	local X2CharacterTemplate_Spire CharTemplate;

	`CREATE_X2TEMPLATE(class'X2CharacterTemplate_Spire', CharTemplate, TemplateName);
	CharTemplate.CharacterGroupName = default.NAME_CHARACTERGROUP_SPIRE;
    CharTemplate.strPawnArchetypes.AddItem("GameUnit_LostTowersTurret.ARC_GameUnit_LostTowersTurretM1");

	CharTemplate.ImmuneTypes.AddItem('Fire');
	CharTemplate.ImmuneTypes.AddItem('Poison');
	CharTemplate.ImmuneTypes.AddItem(class'X2Item_DefaultDamageTypes'.default.ParthenogenicPoisonType);
	CharTemplate.ImmuneTypes.AddItem('Panic');

    return CharTemplate;
}

DefaultProperties
{
	NAME_CHARACTERGROUP_SPIRE=Jammerware_JSRC_CharacterGroup_Spire
	NAME_CHARACTER_SPIRE_CONVENTIONAL=Jammerware_JSRC_Character_Spire_Conventional
	NAME_CHARACTER_SPIRE_MAGNETIC=Jammerware_JSRC_Character_Spire_Magnetic
	NAME_CHARACTER_SPIRE_BEAM=Jammerware_JSRC_Character_Spire_Beam
}