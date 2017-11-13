class X2WeaponTemplate_SpireGun extends X2WeaponTemplate;

var int FieldReloadAmmoGranted;
var int QuicksilverChargesBonus;
var int ShelterShieldBonus;
var int TargetingArrayAccuracyBonus;

DefaultProperties
{
    CanBeBuilt = false
    bInfiniteItem = true
    NumUpgradeSlots = 0
	iPhysicsImpulse = 5
    EquipSound = "Psi_Amp_Equip"
	ItemCat = "weapon"
	WeaponCat = "Jammerware_JSRC_WeaponCat_SpireGun"
	InventorySlot = eInvSlot_SecondaryWeapon
	StowedLocation = eSlot_RightBack
    WeaponPanelImage = "_PsiAmp"
}