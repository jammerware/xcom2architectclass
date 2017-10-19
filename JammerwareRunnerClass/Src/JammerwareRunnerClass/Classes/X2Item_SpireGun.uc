class X2Item_SpireGun extends X2Item 
	config(GameData_WeaponData);

var name NAME_SPIREGUN_WEAPONCAT;
var config int SPIREGUN_ISOUNDRANGE;
var config int SPIREGUN_IENVIRONMENTDAMAGE;

var name NAME_SPIREGUN_CONVENTIONAL;
var config array <WeaponDamageValue> SPIREGUN_CONVENTIONAL_ABILITYDAMAGE;

var name NAME_SPIREGUN_MAGNETIC;
var config array<WeaponDamageValue> SPIREGUN_MAGNETIC_ABILITYDAMAGE;

var name NAME_SPIREGUN_BEAM;
var config array<WeaponDamageValue> SPIREGUN_BEAM_ABILITYDAMAGE;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Weapons;
	
	Weapons.AddItem(CreateTemplate_SpireGun_Conventional());
	Weapons.AddItem(CreateTemplate_SpireGun_Magnetic());
	Weapons.AddItem(CreateTemplate_SpireGun_Beam());

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
	Template.iSoundRange = default.SPIREGUN_ISOUNDRANGE;
	Template.iEnvironmentDamage = default.SPIREGUN_IENVIRONMENTDAMAGE;
	
	Template.StartingItem = true;
	Template.CanBeBuilt = false;
	Template.bInfiniteItem = true;

	return Template;
}

static function X2DataTemplate CreateTemplate_SpireGun_Magnetic()
{
	local X2WeaponTemplate Template;

	`CREATE_X2TEMPLATE(class'X2WeaponTemplate', Template, default.NAME_SPIREGUN_MAGNETIC);
	Template.WeaponPanelImage = "_PsiAmp";

	Template.ItemCat = 'weapon';
	Template.WeaponCat = default.NAME_SPIREGUN_WEAPONCAT;
	Template.WeaponTech = 'magnetic';
	Template.strImage = "img:///UILibrary_Common.MagSecondaryWeapons.MagPsiAmp";
	Template.EquipSound = "Psi_Amp_Equip";
	Template.InventorySlot = eInvSlot_SecondaryWeapon;
	Template.StowedLocation = eSlot_RightBack;

	// This all the resources; sounds, animations, models, physics, the works.
	Template.GameArchetype = "WP_PsiAmp_MG.WP_PsiAmp_MG";
	Template.Tier = 2;

	Template.NumUpgradeSlots = 0;
	Template.InfiniteAmmo = true;
	Template.iPhysicsImpulse = 5;

	Template.ExtraDamage = default.SPIREGUN_MAGNETIC_ABILITYDAMAGE;
	Template.iSoundRange = default.SPIREGUN_ISOUNDRANGE;
	Template.iEnvironmentDamage = default.SPIREGUN_IENVIRONMENTDAMAGE;
	
	// upgradey stuff
	Template.CreatorTemplateName = class'X2Item_SpireGunSchematics'.default.NAME_SPIREGUN_SCHEMATIC_MAGNETIC;
	Template.BaseItem = default.NAME_SPIREGUN_CONVENTIONAL;

	Template.StartingItem = false;
	Template.CanBeBuilt = false;
	Template.bInfiniteItem = true;

	return Template;
}

static function X2DataTemplate CreateTemplate_SpireGun_Beam()
{
	local X2WeaponTemplate Template;

	`CREATE_X2TEMPLATE(class'X2WeaponTemplate', Template, default.NAME_SPIREGUN_BEAM);
	Template.WeaponPanelImage = "_PsiAmp";

	Template.ItemCat = 'weapon';
	Template.WeaponCat = default.NAME_SPIREGUN_WEAPONCAT;
	Template.WeaponTech = 'beam';
	Template.strImage = "img:///UILibrary_Common.BeamSecondaryWeapons.BeamPsiAmp";
	Template.EquipSound = "Psi_Amp_Equip";
	Template.InventorySlot = eInvSlot_SecondaryWeapon;
	Template.StowedLocation = eSlot_RightBack;

	// This all the resources; sounds, animations, models, physics, the works.
	Template.GameArchetype = "WP_PsiAmp_BM.WP_PsiAmp_BM";
	Template.Tier = 4;

	Template.NumUpgradeSlots = 0;
	Template.InfiniteAmmo = true;
	Template.iPhysicsImpulse = 5;

	Template.ExtraDamage = default.SPIREGUN_BEAM_ABILITYDAMAGE;
	Template.iSoundRange = default.SPIREGUN_ISOUNDRANGE;
	Template.iEnvironmentDamage = default.SPIREGUN_IENVIRONMENTDAMAGE;
	
	// upgradey stuff
	Template.CreatorTemplateName = class'X2Item_SpireGunSchematics'.default.NAME_SPIREGUN_SCHEMATIC_BEAM;
	Template.BaseItem = default.NAME_SPIREGUN_MAGNETIC;

	Template.StartingItem = false;
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