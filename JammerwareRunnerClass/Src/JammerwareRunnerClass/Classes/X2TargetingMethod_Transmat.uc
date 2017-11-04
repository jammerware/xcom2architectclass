class X2TargetingMethod_Transmat extends X2TargetingMethod_FloorTile;

// this will currently get weird if the shooter is adjacent to two spires
function Init(AvailableAction InAction, int NewTargetIndex)
{
	super.Init(InAction, NewTargetIndex);

    // infinite cursor range
    LockCursorRange(-1);
}

function name ValidateTargetLocations(const array<Vector> TargetLocations)
{
	local name AbilityAvailability;
	local TTile TargetTile;
	local XComWorldData World;
	local Jammerware_JSRC_ProximityService ProximityService;

	World = `XWORLD;
	// the parent class makes sure the tile isn't blocked and is a floor tile
	AbilityAvailability = super.ValidateTargetLocations(TargetLocations);

	if (AbilityAvailability == 'AA_Success')
	{
		ProximityService = new class'Jammerware_JSRC_ProximityService';
		World.GetFloorTileForPosition(TargetLocations[0], TargetTile);

		// we intentionally don't care if the unit is a spire here, because the architect can have the buff via soul of the architect
		if (!ProximityService.IsTileAdjacentToAlly(TargetTile, self.ShooterState.GetTeam(), , class'X2Ability_TransmatNetwork'.default.NAME_SPIRETRANSMATNETWORK))
		{
			AbilityAvailability = 'AA_NotInRange';
		}
	}
	return AbilityAvailability;
}