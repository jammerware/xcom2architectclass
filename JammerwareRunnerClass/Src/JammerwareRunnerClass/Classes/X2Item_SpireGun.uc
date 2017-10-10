class X2Item_SpireGun extends X2Item config(GameData_WeaponData);

var config WeaponDamageValue SPIREGUN_CONVENTIONAL_ABILITYDAMAGE;
var config int SPIREGUN_CONVENTIONAL_ISOUNDRANGE;
var config int SPIREGUN_CONVENTIONAL_IENVIRONMENTDAMAGE;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Weapons;
	
	Weapons.AddItem(CreateTemplate_SpireGun_Conventional());

	return Weapons;
}

static function X2DataTemplate CreateTemplate_SpireGun_Conventional()
{
	local X2WeaponTemplate Template;

	`CREATE_X2TEMPLATE(class'X2WeaponTemplate', Template, 'SpireGun');
	Template.WeaponPanelImage = "_PsiAmp";

	Template.ItemCat = 'weapon';
	Template.WeaponCat = 'spiregun';
	Template.WeaponTech = 'conventional';
	Template.strImage = "img:///UILibrary_Common.ConvSecondaryWeapons.PsiAmp";
	Template.EquipSound = "Psi_Amp_Equip";
	Template.InventorySlot = eInvSlot_PrimaryWeapon;
	Template.StowedLocation = eSlot_RightBack;

	// This all the resources; sounds, animations, models, physics, the works.
	Template.GameArchetype = "WP_PsiAmp_CV.WP_PsiAmp_CV";
	Template.Tier = 0;

	Template.NumUpgradeSlots = 0;
	Template.InfiniteAmmo = true;
	Template.iPhysicsImpulse = 5;

	Template.BaseDamage = default.SPIREGUN_CONVENTIONAL_ABILITYDAMAGE;
	Template.iSoundRange = default.SPIREGUN_CONVENTIONAL_ISOUNDRANGE;
	Template.iEnvironmentDamage = default.SPIREGUN_CONVENTIONAL_IENVIRONMENTDAMAGE;
	
	//Template.Aim = default.HOLYBLADE_CONVENTIONAL_AIM;
	//Template.CritChance = default.HOLYBLADE_CONVENTIONAL_CRITCHANCE;
	//Template.iSoundRange = default.HOLYBLADE_CONVENTIONAL_ISOUNDRANGE;
	//Template.iEnvironmentDamage = default.HOLYBLADE_CONVENTIONAL_IENVIRONMENTDAMAGE;
	//Template.BaseDamage.DamageType = 'Melee';
	//Template.DamageTypeTemplateName = 'Melee';

	Template.StartingItem = true;
	Template.CanBeBuilt = false;
	Template.bInfiniteItem = true;

	return Template;
}