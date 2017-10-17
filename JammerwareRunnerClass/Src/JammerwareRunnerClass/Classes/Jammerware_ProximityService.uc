class Jammerware_ProximityService extends Object;

// hard-coded (copy/pasted from XComWorldData) for speed
const WORLD_STEP_SIZE = 96.0f;

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
    local float Tiles;

	Tiles = GetUnitDistanceBetween(TileA, TileB) / WORLD_STEP_SIZE;
    
    return Tiles < 2;
}

public function float GetUnitDistanceBetween(TTile TileA, TTile TileB)
{
    local XComWorldData World;
    local vector LocA, LocB;
    World = `XWORLD;

    LocA = World.GetPositionFromTileCoordinates(TileA);
	LocB = World.GetPositionFromTileCoordinates(TileB);
	return VSize(LocA - LocB);
}