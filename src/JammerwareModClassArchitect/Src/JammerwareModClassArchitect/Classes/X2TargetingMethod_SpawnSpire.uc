class X2TargetingMethod_SpawnSpire extends X2TargetingMethod_FloorTile;

protected function int GetCursorRange()
{
	if (GetShooterHasUnity())
		return CURSOR_RANGE_UNLIMITED;

	return AbilityRangeUnits;
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
	if (GetShooterHasUnity())
	{
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
	}
	
	return Tiles;
}

private function bool GetShooterHasUnity()
{
	return ShooterState.AffectedByEffectNames.Find(class'JsrcAbility_Unity'.default.NAME_ABILITY) != INDEX_NONE;
}