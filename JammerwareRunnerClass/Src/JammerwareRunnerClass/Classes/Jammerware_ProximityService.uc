class Jammerware_ProximityService extends Object;

function bool AreAdjacent(XComGameState_Unit UnitA, XComGameState_Unit UnitB)
{
    return UnitA.TileDistanceBetween(UnitB) <= 1;
}

function bool IsTileAdjacentToAlly(TTile Tile, XComGameState GameState, XComGameState_Unit UnitGameState)
{
    local XComGameState_Unit IterateUnitState;
    local TTile IterateUnitTile;

    foreach GameState.IterateByClassType(class'XComGameState_Unit', IterateUnitState)
    {
        if (IterateUnitState.GetTeam() == UnitGameState.GetTeam())
        {
            IterateUnitState.GetKeystoneVisibilityLocation(IterateUnitTile);

            if (AreTilesAdjacent(Tile, IterateUnitTile))
            {
                return true;
            }
        }
    }

    return false;
}

private function bool AreTilesAdjacent(TTile TileA, TTile TileB)
{
    local XComWorldData World;
    local vector LocA, LocB;
    local float Dist, Tiles;

    World = `XWORLD;

    LocA = World.GetPositionFromTileCoordinates(TileA);
	LocB = World.GetPositionFromTileCoordinates(TileB);
	Dist = VSize(LocA - LocB);
	Tiles = Dist / World.WORLD_StepSize;
    
    `LOG("JSRC: tiles" @ Tiles);
    return Tiles < 2;
}