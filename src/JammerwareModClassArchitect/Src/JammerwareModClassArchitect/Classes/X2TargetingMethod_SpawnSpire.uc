class X2TargetingMethod_SpawnSpire extends X2TargetingMethod_FloorTile;

var private bool bShooterHasUnity;

function Init(AvailableAction InAction, int NewTargetIndex)
{
	super.Init(InAction, NewTargetIndex);

	// if the shooter has unity, the cursor needs to be unlocked to allow selection of tiles adjacent to allies
	if (ShooterState.AffectedByEffectNames.Find(class'X2Ability_RunnerAbilitySet'.default.NAME_UNITY) != INDEX_NONE)
	{
		bShooterHasUnity = true;
		LockCursorRange(-1);
	}
}

protected function array<TTile> GetLegalTiles()
{
	local Jammerware_JSRC_ProximityService ProximityService;
	local ETeam ShooterTeam;
	local array<TTile> Tiles, AdjacentTilesIterator;
	local TTile TileIterator;
	local XComGameState_Unit UnitIterator;

	ProximityService = new class'Jammerware_JSRC_ProximityService';	
	ShooterTeam = ShooterState.GetTeam();

	// get all tiles in the normal radius of the ability
	Tiles = super.GetLegalTiles();

	// then, if the shooter has unity, we add all the tiles adjacent to allies
	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_Unit', UnitIterator)
	{
		if (UnitIterator.GetTeam() == ShooterTeam)
		{
			AdjacentTilesIterator = ProximityService.GetAdjacentTiles(UnitIterator.TileLocation);
			foreach AdjacentTilesIterator(TileIterator)
			{
				Tiles.AddItem(TileIterator);
			}
		}
	}
	
	return Tiles;
}