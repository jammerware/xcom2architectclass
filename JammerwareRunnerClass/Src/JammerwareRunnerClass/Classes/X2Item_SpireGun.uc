class X2Item_SpireGun extends X2Item config(GameData_WeaponData);

var name NAME_SPIREGUN_WEAPONCAT;

var name NAME_SPIREGUN_CONVENTIONAL;
var config array <WeaponDamageValue> SPIREGUN_CONVENTIONAL_ABILITYDAMAGE;
var config int SPIREGUN_CONVENTIONAL_ISOUNDRANGE;
var config int SPIREGUN_CONVENTIONAL_IENVIRONMENTDAMAGE;

var name NAME_SPIREGUN_MAGNETIC;
var name NAME_SPIREGUN_BEAM;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Weapons;
	
	Weapons.AddItem(CreateTemplate_SpireGun_Conventional());

	return Weapons;
}

static function X2DataTemplate CreateTemplate_SpireGun_Conventional()
{
	local X2WeaponTemplate Template;

	`CREATE_X2TEMPLATE(class'X2WeaponTemplate', Template, default.NAME_SPIREGUN_CONVENTIONAL);
	Template.WeaponPanelImage = "_PsiAmp";

	Template.ItemCat = 'weapon';
	Template.WeaponCat = default.NAME_SPIREGUN_WEAPONCAT;
	Template.WeaponTech = 'conventional';
	Template.strImage = "img:///UILibrary_Common.ConvSecondaryWeapons.PsiAmp";
	Template.EquipSound = "Psi_Amp_Equip";
	Template.InventorySlot = eInvSlot_SecondaryWeapon;
	Template.StowedLocation = eSlot_RightBack;

	// This all the resources; sounds, animations, models, physics, the works.
	Template.GameArchetype = "WP_PsiAmp_CV.WP_PsiAmp_CV";
	Template.Tier = 0;

	Template.NumUpgradeSlots = 0;
	Template.InfiniteAmmo = true;
	Template.iPhysicsImpulse = 5;

	Template.ExtraDamage = default.SPIREGUN_CONVENTIONAL_ABILITYDAMAGE;
	Template.iSoundRange = default.SPIREGUN_CONVENTIONAL_ISOUNDRANGE;
	Template.iEnvironmentDamage = default.SPIREGUN_CONVENTIONAL_IENVIRONMENTDAMAGE;
	
	Template.StartingItem = true;
	Template.CanBeBuilt = false;
	Template.bInfiniteItem = true;

	return Template;
}

defaultproperties
{
	NAME_SPIREGUN_WEAPONCAT=spiregun
	NAME_SPIREGUN_CONVENTIONAL=Jammerware_JSRC_Item_SpireGun_Conventional
	NAME_SPIREGUN_MAGNETIC=Jammerware_JSRC_Item_SpireGun_Magnetic
	NAME_SPIREGUN_BEAM=Jammerware_JSRC_Item_SpireGun_Beam
}