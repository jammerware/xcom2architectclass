class X2AbilityCooldown_SoulOfTheArchitect extends X2AbilityCooldown;

var int NonSpireCooldown;

// abilities of the spire have a single-turn cooldown, but the cooldown is longer if they're owned by the architect via Soul of the Architect
simulated function int GetNumTurns(XComGameState_Ability kAbility, XComGameState_BaseObject AffectState, XComGameState_Item AffectWeapon, XComGameState NewGameState)
{
	local XComGameState_Unit OwnerUnit;

	OwnerUnit = XComGameState_Unit(NewGameState.GetGameStateForObjectID(kAbility.OwnerStateObject.ObjectID));
	if (OwnerUnit == none)
		OwnerUnit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(kAbility.OwnerStateObject.ObjectID));

    if (OwnerUnit.GetMyTemplate().CharacterGroupName != class'X2Character_Spire'.default.NAME_CHARACTERGROUP_SPIRE)
    {
        return NonSpireCooldown;
    }
	
	return iNumTurns;
}

DefaultProperties
{
	iNumTurns = 1;
}