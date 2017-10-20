class X2Template_SpireGun extends X2WeaponTemplate;

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
	WeaponCat = "spiregun"
	InventorySlot = eInvSlot_SecondaryWeapon
	StowedLocation = eSlot_RightBack
    WeaponPanelImage = "_PsiAmp"
}