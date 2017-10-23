class Jammerware_ProximityService extends Object;

function bool AreAdjacent(XComGameState_Unit UnitA, XComGameState_Unit UnitB)
{
    return AreTilesAdjacent(UnitA.TileLocation, UnitB.TileLocation);
}

function bool IsTileAdjacentToAlly(TTile Tile, XComGameState_Unit UnitGameState, optional name AllyCharacterGroup)
{
    local XComGameState_Unit IterateUnitState;

    foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_Unit', IterateUnitState)
    {
        if (
            IterateUnitState.GetTeam() == UnitGameState.GetTeam() && 
            (AllyCharacterGroup == 'None' || IterateUnitState.GetMyTemplate().CharacterGroupName == AllyCharacterGroup) &&
            AreTilesAdjacent(Tile, IterateUnitState.TileLocation)
        )
        {
            return true;
        }
    }

    return false;
}

private function bool AreTilesAdjacent(TTile TileA, TTile TileB)
{
    local float Tiles;

	Tiles = GetUnitDistanceBetween(TileA, TileB) / `XWORLD.WORLD_StepSize;
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

public function bool IsUnitAdjacentToSpire(XComGameState_Unit UnitState, bool RequireOwnership = false)
{
    return IsTileAdjacentToAlly(UnitState.TileLocation, UnitState, class'X2Character_Spire'.default.NAME_CHARACTERGROUP_SPIRE);
}