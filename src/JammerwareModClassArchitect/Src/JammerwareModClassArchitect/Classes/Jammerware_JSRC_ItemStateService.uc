class Jammerware_JSRC_ItemStateService extends Object;

public function LoadAmmo(XComGameState_Item Weapon, int Amount, XComGameState GameState)
{
    local XComGameState_Item NewWeaponState;
    local int MaxLegalAmmo;

    NewWeaponState = XComGameState_Item(GameState.ModifyStateObject(class'XComGameState_Item', Weapon.ObjectID));
    MaxLegalAmmo = NewWeaponState.Ammo + Amount;

    if (MaxLegalAmmo > NewWeaponState.GetClipSize()) 
    {
        MaxLegalAmmo = NewWeaponState.GetClipSize();
    }

    NewWeaponState.Ammo = MaxLegalAmmo;
}

public function bool CanLoadAmmo(XComGameState_Item Weapon)
{
    return Weapon.Ammo < Weapon.GetClipSize();
}