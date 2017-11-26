class JsrcAbilityCharges_Quicksilver extends X2AbilityCharges;

function int GetInitialCharges(XComGameState_Ability Ability, XComGameState_Unit Unit) 
{ 
	local int Charges;
    local XComGameState_Item WeaponState;
    local X2WeaponTemplate_SpireGun WeaponTemplate;

    Charges = super.GetInitialCharges(Ability, Unit);
	WeaponState = XComGameState_Item(`XCOMHISTORY.GetGameStateForObjectID(Ability.SourceWeapon.ObjectID));
	
	if (WeaponState != None)
	{
		WeaponTemplate = X2WeaponTemplate_SpireGun(WeaponState.GetMyTemplate());
        Charges += WeaponTemplate.QuicksilverChargesBonus;
	}
	
	return Charges; 
}