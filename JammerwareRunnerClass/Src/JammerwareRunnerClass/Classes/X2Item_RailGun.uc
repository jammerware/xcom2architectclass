class X2Item_RailGun extends X2Item config(GameData_WeaponData);

var name NAME_RAILGUN_CONVENTIONAL;
var name NAME_RAILGUN_MAGNETIC;
var name NAME_RAILGUN_BEAM;

static function array<X2DataTemplate> CreateTemplates()
{
    local array<X2DataTemplate> Templates;

    Templates.Add(CreateRailgunConventional());

    return Templates;
}

static function X2DataTemplate CreateRailgunConventional()
{
    local X2WeaponTemplate Template;

	`CREATE_X2TEMPLATE(class'X2WeaponTemplate', Template, 'Jammerware_JSRC_Item_Railgun_Conventional');

	Template.WeaponPanelImage = "_ConventionalRifle";                       // used by the UI. Probably determines iconview of the weapon.
	Template.ItemCat = 'weapon';
	Template.WeaponCat = 'rifle';
	Template.WeaponTech = 'magnetic';
	Template.strImage = "img:///UILibrary_Common.AlienWeapons.AdventTurret";
	Template.RemoveTemplateAvailablility(Template.BITFIELD_GAMEAREA_Multiplayer); //invalidates multiplayer availability

	Template.RangeAccuracy = default.FLAT_CONVENTIONAL_RANGE;
	Template.BaseDamage = default.XCOMTURRETM1_WPN_BASEDAMAGE;
	Template.iClipSize = 1;
	Template.InfiniteAmmo = true;
	Template.iSoundRange = default.ASSAULTRIFLE_MAGNETIC_ISOUNDRANGE;
	Template.iEnvironmentDamage = default.ASSAULTRIFLE_MAGNETIC_IENVIRONMENTDAMAGE;

	Template.InventorySlot = eInvSlot_PrimaryWeapon;
	Template.Abilities.AddItem('StandardShot');

	// This all the resources; sounds, animations, models, physics, the works.
	Template.GameArchetype = "WP_Turret_MG.WP_Turret_MG";

	Template.iPhysicsImpulse = 5;
	Template.CanBeBuilt = false;
	Template.TradingPostValue = 30;

	Template.DamageTypeTemplateName = 'Projectile_MagAdvent';

	return Template;
}