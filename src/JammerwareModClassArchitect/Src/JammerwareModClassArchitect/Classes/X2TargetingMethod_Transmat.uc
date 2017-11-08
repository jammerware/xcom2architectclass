class X2TargetingMethod_Transmat extends X2TargetingMethod_FloorTile;

// people transmatting have to choose a space adjacent to an spirelike unit in the same network
var private int NetworkID;

// this will currently get weird if the shooter is adjacent to two spires
function Init(AvailableAction InAction, int NewTargetIndex)
{
	super.Init(InAction, NewTargetIndex);

	NetworkID = GetNetworkID();

    // infinite cursor range
    LockCursorRange(-1);
}

private function int GetNetworkID()
{
	local Jammerware_JSRC_ProximityService ProximityService;
	local Jammerware_JSRC_TransmatNetworkService TransmatService;
	local array<XComGameState_Unit> AdjacentUnits;

	ProximityService = new class'Jammerware_JSRC_ProximityService';
	TransmatService = new class'Jammerware_JSRC_TransmatNetworkService';
	// get all allies adjacent to the shooter that have the transmat network node buff
	AdjacentUnits = ProximityService.GetAdjacentUnits(self.ShooterState, true, , class'X2Ability_TransmatNetwork'.default.NAME_SPIRETRANSMATNETWORK);

	if (AdjacentUnits.Length == 0)
		`REDSCREEN("JSRC: X2TargetingMethod_Transmat couldn't find an adjacent transmat network node");
	
	// later on, we'll do some kind of multiple-network-handling thing
	return TransmatService.GetNetworkIDFromUnitState(AdjacentUnits[0]);
}

function name ValidateTargetLocations(const array<Vector> TargetLocations)
{
	local name AbilityAvailability;
	local TTile TargetTile;
	local XComWorldData World;
	local array<XComGameState_Unit> AdjacentUnits;
	local XComGameState_Unit UnitIterator;
	local Jammerware_JSRC_ProximityService ProximityService;
	local Jammerware_JSRC_TransmatNetworkService TxmatService;

	World = `XWORLD;
	// the parent class makes sure the tile isn't blocked and is a floor tile
	AbilityAvailability = super.ValidateTargetLocations(TargetLocations);

	if (AbilityAvailability == 'AA_Success')
	{
		AbilityAvailability = 'AA_NotInRange';
		ProximityService = new class'Jammerware_JSRC_ProximityService';
		TxmatService = new class'Jammerware_JSRC_TransmatNetworkService';
		World.GetFloorTileForPosition(TargetLocations[0], TargetTile);

		AdjacentUnits = ProximityService.GetAdjacentUnitsFromTile(TargetTile, ShooterState.GetTeam(), , class'X2Ability_TransmatNetwork'.default.NAME_SPIRETRANSMATNETWORK);

		foreach AdjacentUnits(UnitIterator)
		{
			if (TxmatService.GetNetworkIDFromUnitState(UnitIterator) == self.NetworkID) 
			{
				AbilityAvailability = 'AA_Success';
				break;
			}
		}
	}
	
	return AbilityAvailability;
}