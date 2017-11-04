class X2AbilityCharges_Quicksilver extends X2AbilityCharges;

function int GetInitialCharges(XComGameState_Ability Ability, XComGameState_Unit Unit) 
{ 
	local int Charges;
    local XComGameState_Item WeaponState;
    local X2WeaponTemplate_SpireGun WeaponTemplate;

    Charges = super.GetInitialCharges(Ability, Unit);

	// this is maybe a little crazy
	// the architect can have this ability, but we also dynamically put it on spires during tactical.
	// when that happens, the ability state doesn't know what weapon it goes with, so we have to inspect
	// the shooter to determine how many charges we get. this'll break if the spire gun ever changes slots
	// or something. i feel icky
	WeaponState = Unit.GetSecondaryWeapon();
	if (WeaponState != None)
	{
		WeaponTemplate = X2WeaponTemplate_SpireGun(WeaponState.GetMyTemplate());
        Charges += WeaponTemplate.QuicksilverChargesBonus;
	}
	
	return Charges; 
}