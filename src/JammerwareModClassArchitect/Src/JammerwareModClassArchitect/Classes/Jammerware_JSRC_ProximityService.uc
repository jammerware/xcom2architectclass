class Jammerware_JSRC_ProximityService extends Object;

public function bool AreAdjacent(XComGameState_Unit UnitA, XComGameState_Unit UnitB)
{
    return AreTilesAdjacent(UnitA.TileLocation, UnitB.TileLocation);
}

private function bool AreTilesAdjacent(TTile TileA, TTile TileB)
{
    local float Tiles;

	Tiles = GetUnitDistanceBetween(TileA, TileB) / `XWORLD.WORLD_StepSize;
    return Tiles < 2;
}

public function array<TTile> GetAdjacentTiles(TTile Tile)
{
	local int x, y;
	local TTile TempTile;
	local array<TTile> Tiles;

	for (x = -1; x <= 1; x++)
	{
		for (y = -1; y <=1; y++)
		{
			TempTile = Tile;
			TempTile.X += x;
			TempTile.Y += y;

			if (TempTile.X != Tile.X || TempTile.Y != Tile.Y)
			{
				Tiles.AddItem(TempTile);
			}
		}
	}

	return Tiles;
}

public function TTile GetClosestTile(TTile StartTile, array<TTile> Tiles)
{
	local XComWorldData World;
	local Vector StartLocation;
	local Vector TileLocation;
	local TTile ClosestTile, TileIterator;
	local float Distance, MinDistance;

	World = `XWORLD;
	StartLocation = World.GetPositionFromTileCoordinates(StartTile);
	// what am i even doing with my life
	MinDistance = 999999999999;

	foreach Tiles(TileIterator)
	{
		World.ClampTile(TileIterator);
		TileLocation = World.GetPositionFromTileCoordinates(TileIterator);
		Distance = VSize2D(TileLocation - StartLocation);

		if (Distance < MinDistance)
		{
			MinDistance = Distance;
			ClosestTile = TileIterator;
		}
	}

	return ClosestTile;
}

public function XComGameState_Unit GetFurthestUnitFrom(XComGameState_Unit Source, array<XComGameState_Unit> OtherUnits)
{
    local TTile ShooterTile;
    local float MaxDistance, Distance;
    local XComGameState_Unit UnitIterator, MaxDistanceUnit;

    ShooterTile = Source.TileLocation;

    foreach OtherUnits(UnitIterator)
    {
        Distance = GetUnitDistanceBetween(ShooterTile, UnitIterator.TileLocation);
        if (Distance > MaxDistance)
        {
            MaxDistance = Distance;
            MaxDistanceUnit = UnitIterator;
        }
    }

    return MaxDistanceUnit;
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

function bool IsTileAdjacentToAlly(TTile Tile, ETeam Team, optional name AllyCharacterGroup, optional name RequiredAllyEffect)
{
    local XComGameState_Unit IterateUnitState;

    foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_Unit', IterateUnitState)
    {
        if (MeetsAdjacencyCriteria(Tile, IterateUnitState, Team, AllyCharacterGroup, RequiredAllyEffect))
        {
            return true;
        }
    }

    return false;
}

public function array<XComGameState_Unit> GetAdjacentUnitsFromTile(
    TTile Tile, 
    optional ETeam RequiredTeam = eTeam_None, 
    optional name RequiredCharacterGroup,
    optional name RequiredEffect)
{
    local XComGameState_Unit IterateUnitState;
    local array<XComGameState_Unit> Results;

    foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_Unit', IterateUnitState)
    {
        if 
        (
            IterateUnitState.TileLocation != Tile &&
            MeetsAdjacencyCriteria(Tile, IterateUnitState, RequiredTeam, RequiredCharacterGroup, RequiredEffect)
        )
        {
            Results.AddItem(IterateUnitState);
        }
    }

    return Results;
}

public function array<XComGameState_Unit> GetAdjacentUnits(
    XComGameState_Unit Unit, 
    bool RequireAllies = false, 
    optional name RequiredCharacterGroup, 
    optional name RequiredEffect)
{
    return GetAdjacentUnitsFromTile
    (
        Unit.TileLocation,
        (RequireAllies ? Unit.GetTeam() : eTeam_None),
        RequiredCharacterGroup,
        RequiredEffect
    );
}

private function bool MeetsAdjacencyCriteria(
    TTile SourceTile,
    XComGameState_Unit CandidateUnit,
    optional ETeam RequiredCandidateTeam = eTeam_None, 
    optional name RequiredCandidateCharacterGroup, 
    optional name RequiredCandidateEffect)
{
    return
        !CandidateUnit.IsDead() &&
        (RequiredCandidateTeam == eTeam_None || CandidateUnit.GetTeam() == RequiredCandidateTeam) && 
        (RequiredCandidateEffect == 'None' || CandidateUnit.AffectedByEffectNames.Find(RequiredCandidateEffect) != INDEX_NONE) &&
        (RequiredCandidateCharacterGroup == 'None' || CandidateUnit.GetMyTemplate().CharacterGroupName == RequiredCandidateCharacterGroup) &&
        AreTilesAdjacent(SourceTile, CandidateUnit.TileLocation);
}

public function bool IsUnitAdjacentToAlly(XComGameState_Unit Unit, optional name RequiredAllyEffect)
{
    return IsTileAdjacentToAlly(Unit.TileLocation, Unit.GetTeam(), , RequiredAllyEffect);
}

public function bool IsUnitAdjacentToSpire(XComGameState_Unit Unit, optional name RequiredSpireEffect)
{
    return IsTileAdjacentToAlly(Unit.TileLocation, Unit.GetTeam(), class'X2Character_Spire'.default.NAME_CHARACTERGROUP_SPIRE, RequiredSpireEffect);
}