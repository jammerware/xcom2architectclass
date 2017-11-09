class X2TargetingMethod_Transmat extends X2TargetingMethod_FloorTile;

// people transmatting have to choose a space adjacent to an spirelike unit in the same network
var private array<TTile> LegalTargets;
var protected X2Actor_ValidTile ValidTileActor;

// this will currently get weird if the shooter is adjacent to two spires
function Init(AvailableAction InAction, int NewTargetIndex)
{
	super.Init(InAction, NewTargetIndex);

	LegalTargets = GetLegalTargets();
	DrawAOETiles(LegalTargets);
	ValidTileActor = `CURSOR.Spawn(class'X2Actor_ValidTile', `CURSOR);

    // infinite cursor range
    LockCursorRange(-1);
}

function Canceled()
{
	super.Canceled();
	ValidTileActor.Destroy();
}

function Committed()
{
	super.Committed();
	ValidTileActor.Destroy();
}

protected function DrawValidCursorLocation(TTile Tile)
{
	local vector TileLocation;
	local int TileZ;

	`XWORLD.GetFloorPositionForTile(Tile, TileLocation);
	ValidTileActor.SetLocation(TileLocation);
	ValidTileActor.SetHidden(false);
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

private function array<TTile> GetLegalTargets()
{
	local array<TTile> LegalTiles, AdjacentTilesIterator;
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
			LegalTiles.AddItem(TileIterator);
		}
	}

	return LegalTiles;
}

function name ValidateTargetLocations(const array<Vector> TargetLocations)
{
	local name AbilityAvailability;
	local TTile TargetTile, TileIterator;

	// the parent class makes sure the tile isn't blocked and is a floor tile
	AbilityAvailability = super.ValidateTargetLocations(TargetLocations);

	if (AbilityAvailability == 'AA_Success')
	{
		AbilityAvailability = 'AA_NotInRange';
		`XWORLD.GetFloorTileForPosition(TargetLocations[0], TargetTile);

		foreach self.LegalTargets(TileIterator)
		{
			if (TileIterator.X == TargetTile.X && TileIterator.Y == TargetTile.Y && TileIterator.Z == TargetTile.Z)
			{
				AbilityAvailability = 'AA_Success';
				break;
			}
		}
	}
	
	return AbilityAvailability;
}