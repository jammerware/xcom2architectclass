class X2Item_RailGun extends X2Item config(GameData_WeaponData);

var name NAME_RAILGUN_CONVENTIONAL;
var name NAME_RAILGUN_MAGNETIC;
var name NAME_RAILGUN_BEAM;

var config WeaponDamageValue RAILGUN_BASEDAMAGE_CONVENTIONAL;
var config WeaponDamageValue RAILGUN_BASEDAMAGE_MAGNETIC;
var config WeaponDamageValue RAILGUN_BASEDAMAGE_BEAM;

var config int RAILGUN_IENVIRONMENTDAMAGE;
var config int RAILGUN_ISOUNDRANGE;
var config array<int> RAILGUN_RANGE;

static function array<X2DataTemplate> CreateTemplates()
{
    local array<X2DataTemplate> Templates;

    Templates.AddItem(CreateRailgunConventional());
	Templates.AddItem(CreateRailgunMagnetic());
	Templates.AddItem(CreateRailgunBeam());

    return Templates;
}

private static function X2DataTemplate CreateRailgunConventional()
{
    local X2WeaponTemplate Template;

	`CREATE_X2TEMPLATE(class'X2WeaponTemplate', Template, default.NAME_RAILGUN_CONVENTIONAL);

	Template.WeaponPanelImage = "_ConventionalRifle";
	Template.ItemCat = 'weapon';
	Template.WeaponCat = 'rifle';
	Template.WeaponTech = 'conventional';
	Template.strImage = "img:///UILibrary_Common.AlienWeapons.AdventTurret";

	Template.RangeAccuracy = default.RAILGUN_RANGE;
	Template.BaseDamage = default.RAILGUN_BASEDAMAGE_CONVENTIONAL;
	Template.iClipSize = 1;
	Template.InfiniteAmmo = true;
	Template.iSoundRange = default.RAILGUN_ISOUNDRANGE;
	Template.iEnvironmentDamage = default.RAILGUN_IENVIRONMENTDAMAGE;

	Template.InventorySlot = eInvSlot_PrimaryWeapon;
	Template.Abilities.AddItem('StandardShot');

	// This all the resources; sounds, animations, models, physics, the works.
	Template.GameArchetype = "WP_Turret_MG.WP_Turret_MG";

	Template.iPhysicsImpulse = 5;
	Template.CanBeBuilt = false;
	Template.TradingPostValue = 30;

	Template.DamageTypeTemplateName = 'Electrical';

	return Template;
}

private static function X2DataTemplate CreateRailgunMagnetic()
{
    local X2WeaponTemplate Template;

	`CREATE_X2TEMPLATE(class'X2WeaponTemplate', Template, default.NAME_RAILGUN_MAGNETIC);

	Template.WeaponPanelImage = "_ConventionalRifle";
	Template.ItemCat = 'weapon';
	Template.WeaponCat = 'rifle';
	Template.WeaponTech = 'magnetic';
	Template.strImage = "img:///UILibrary_Common.AlienWeapons.AdventTurret";

	Template.RangeAccuracy = default.RAILGUN_RANGE;
	Template.BaseDamage = default.RAILGUN_BASEDAMAGE_MAGNETIC;
	Template.iClipSize = 1;
	Template.InfiniteAmmo = true;
	Template.iSoundRange = default.RAILGUN_ISOUNDRANGE;
	Template.iEnvironmentDamage = default.RAILGUN_IENVIRONMENTDAMAGE;

	Template.InventorySlot = eInvSlot_PrimaryWeapon;
	Template.Abilities.AddItem('StandardShot');

	// This all the resources; sounds, animations, models, physics, the works.
	Template.GameArchetype = "WP_Turret_MG.WP_Turret_MG";

	Template.iPhysicsImpulse = 5;
	Template.CanBeBuilt = false;
	Template.TradingPostValue = 30;

	Template.DamageTypeTemplateName = 'Electrical';

	return Template;
}

private static function X2DataTemplate CreateRailgunBeam()
{
    local X2WeaponTemplate Template;

	`CREATE_X2TEMPLATE(class'X2WeaponTemplate', Template, default.NAME_RAILGUN_BEAM);

	Template.WeaponPanelImage = "_ConventionalRifle";
	Template.ItemCat = 'weapon';
	Template.WeaponCat = 'rifle';
	Template.WeaponTech = 'beam';
	Template.strImage = "img:///UILibrary_Common.AlienWeapons.AdventTurret";

	Template.RangeAccuracy = default.RAILGUN_RANGE;
	Template.BaseDamage = default.RAILGUN_BASEDAMAGE_BEAM;
	Template.iClipSize = 1;
	Template.InfiniteAmmo = true;
	Template.iSoundRange = default.RAILGUN_ISOUNDRANGE;
	Template.iEnvironmentDamage = default.RAILGUN_IENVIRONMENTDAMAGE;

	Template.InventorySlot = eInvSlot_PrimaryWeapon;
	//Template.Abilities.AddItem('StandardShot');

	// This all the resources; sounds, animations, models, physics, the works.
	Template.GameArchetype = "WP_Turret_MG.WP_Turret_MG";

	Template.iPhysicsImpulse = 5;
	Template.CanBeBuilt = false;
	Template.TradingPostValue = 30;

	Template.DamageTypeTemplateName = 'Electrical';

	return Template;
}

DefaultProperties
{
	NAME_RAILGUN_CONVENTIONAL=Jammerware_JSRC_Item_Railgun_Conventional
	NAME_RAILGUN_MAGNETIC=Jammerware_JSRC_Item_Railgun_Magnetic
	NAME_RAILGUN_BEAM=Jammerware_JSRC_Item_Railgun_Beam
}