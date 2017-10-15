class Jammerware_UnitProximityService extends Object;

function bool AreAdjacent(XComGameState_Unit UnitA, XComGameState_Unit UnitB)
{
    local TTile TileA, TileB;

    UnitA.GetKeystoneVisibilityLocation(TileA);
	UnitB.GetKeystoneVisibilityLocation(TileB);

    return ((abs(TileA.X - TileB.X) + abs(TileA.Y - TileB.Y) + abs(TileA.Z - TileB.Z)) == 1);
}