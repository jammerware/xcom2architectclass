class X2AbilityCooldown_SoulOfTheArchitect extends X2AbilityCooldown;

var int NonSpireCooldown;

// abilities of the spire have a single-turn cooldown, but the cooldown is longer if they're owned by the architect via Soul of the Architect
simulated function int GetNumTurns(XComGameState_Ability kAbility, XComGameState_BaseObject AffectState, XComGameState_Item AffectWeapon, XComGameState NewGameState)
{
	local Jammerware_JSRC_SpireService SpireService;
	local XComGameState_Unit OwnerUnit;
	
	OwnerUnit = XComGameState_Unit(NewGameState.GetGameStateForObjectID(kAbility.OwnerStateObject.ObjectID));
	SpireService = new class'Jammerware_JSRC_SpireService';

	if (OwnerUnit == none)
		OwnerUnit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(kAbility.OwnerStateObject.ObjectID));

    if (!SpireService.IsSpire(OwnerUnit))
    {
        return NonSpireCooldown;
    }
	
	return iNumTurns;
}

DefaultProperties
{
	iNumTurns = 1;
}