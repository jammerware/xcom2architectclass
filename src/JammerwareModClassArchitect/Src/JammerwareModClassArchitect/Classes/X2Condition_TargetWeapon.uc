class X2Condition_TargetWeapon extends X2Condition;

var eInventorySlot InventorySlot;
var bool CanReload;

event name CallAbilityMeetsCondition(XComGameState_Ability kAbility, XComGameState_BaseObject kTarget)
{
	local XComGameState_Unit TargetUnitState;
	local XComGameState_Item WeaponState;
	
    TargetUnitState = XComGameState_Unit(kTarget);
    WeaponState = TargetUnitState.GetItemInSlot(InventorySlot);

    if (WeaponState == none)
        return 'AA_ValueCheckFailed';
    
    if (CanReload)
    {
        if (WeaponState.Ammo == WeaponState.GetClipSize())
            return 'AA_AmmoAlreadyFull';
    }

    return 'AA_Success';
}

DefaultProperties
{
    CanReload=true
    InventorySlot=eInvSlot_PrimaryWeapon
}