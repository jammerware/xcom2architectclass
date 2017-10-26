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
	local Jammerware_ProximityService ProximityService;

	World = `XWORLD;
	// the parent class makes sure the tile isn't blocked and is a floor tile
	AbilityAvailability = super.ValidateTargetLocations(TargetLocations);

	if (AbilityAvailability == 'AA_Success')
	{
		ProximityService = new class'Jammerware_ProximityService';
		World.GetFloorTileForPosition(TargetLocations[0], TargetTile);

		if (!ProximityService.IsTileAdjacentToAlly(TargetTile, self.ShooterState.GetTeam(), class'X2Character_Spire'.default.NAME_CHARACTERGROUP_SPIRE, class'X2Ability_TransmatNetwork'.default.NAME_SPIRETRANSMATNETWORK))
		{
			AbilityAvailability = 'AA_NotInRange';
		}
	}
	return AbilityAvailability;
}