class X2AbilityCost_Ammo_MagSizeOrAmountMin extends X2AbilityCost_Ammo;

private function int GetAmmoCostInternal(XComGameState_Item WeaponState)
{
    local int ClipSize;

    ClipSize = WeaponState.GetClipSize();
    if (ClipSize < iAmmo)
        return ClipSize;

    return iAmmo;
}

simulated function int CalcAmmoCost(XComGameState_Ability Ability, XComGameState_Item ItemState, XComGameState_BaseObject TargetState)
{
    if (bConsumeAllAmmo)
	{
		if (ItemState.Ammo > 0)
			return ItemState.Ammo;
		return 1;
	}

    return GetAmmoCostInternal(ItemState);
}

simulated function name CanAfford(XComGameState_Ability kAbility, XComGameState_Unit ActivatingUnit)
{
	local XComGameState_Item Weapon, SourceAmmo;

	if (UseLoadedAmmo)
	{
		SourceAmmo = kAbility.GetSourceAmmo();
		if (SourceAmmo != None)
		{
			if (SourceAmmo.HasInfiniteAmmo() || SourceAmmo.Ammo >= iAmmo)
				return 'AA_Success';
		}
	}
	else
	{
		Weapon = kAbility.GetSourceWeapon();
		if (Weapon != none)
		{
			// If the weapon has infinite ammo, the weapon must still have an ammo value
			// of at least one. This could happen if the weapon becomes disabled.
			if ((Weapon.HasInfiniteAmmo() && (Weapon.Ammo > 0)) || Weapon.Ammo >= GetAmmoCostInternal(Weapon))
				return 'AA_Success';
		}	
	}

	if (bReturnChargesError)
		return 'AA_CannotAfford_Charges';

	return 'AA_CannotAfford_AmmoCost';
}