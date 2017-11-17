class X2TargetingMethod_Transmat extends X2TargetingMethod_FloorTile;

protected function int GetCursorRange()
{
	return CURSOR_RANGE_UNLIMITED;
}

protected function array<TTile> GetLegalTiles()
{
	local array<TTile> Tiles, AdjacentTilesIterator;
	local TTile TileIterator;
	local array<XComGameState_Unit> UnitsInNetwork;
	local XComGameState_Unit UnitIterator;
	local Jammerware_JSRC_ProximityService ProximityService;
	local Jammerware_JSRC_TransmatNetworkService TxmatService;

	ProximityService = new class'Jammerware_JSRC_ProximityService';
	TxmatService = new class'Jammerware_JSRC_TransmatNetworkService';

	UnitsInNetwork = TxmatService.GetUnitsInNetwork(GetNetworkID());

	foreach UnitsInNetwork(UnitIterator)
	{
		AdjacentTilesIterator = ProximityService.GetAdjacentTiles(UnitIterator.TileLocation);

		foreach AdjacentTilesIterator(TileIterator)
		{
			Tiles.AddItem(TileIterator);
		}
	}

	return Tiles;
}

// this will currently get weird if the shooter is adjacent to two spires
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