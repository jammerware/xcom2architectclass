class Jammerware_ProximityService extends Object;

function bool AreAdjacent(XComGameState_Unit UnitA, XComGameState_Unit UnitB)
{
    return AreTilesAdjacent(UnitA.TileLocation, UnitB.TileLocation);
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

public function array<XComGameState_Unit> GetAdjacentUnits(
    XComGameState_Unit Unit, 
    bool RequireAllies = false, 
    optional name RequiredCharacterGroup, 
    optional name RequiredEffect)
{
    local XComGameState_Unit IterateUnitState;
    local array<XComGameState_Unit> Results;
    local ETeam RequiredTeam;

    RequiredTeam = eTeam_All;
    if(RequireAllies) { RequiredTeam = Unit.GetTeam(); }

    foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_Unit', IterateUnitState)
    {
        if (MeetsAdjacencyCriteria(Unit.TileLocation, IterateUnitState, RequiredTeam, RequiredCharacterGroup, RequiredEffect))
        {
            Results.AddItem(IterateUnitState);
        }
    }

    return Results;
}

private function bool MeetsAdjacencyCriteria(
    TTile SourceTile,
    XComGameState_Unit CandidateUnit,
    optional ETeam RequiredCandidateTeam = eTeam_All, 
    optional name RequiredCandidateCharacterGroup, 
    optional name RequiredCandidateEffect)
{
    local Jammerware_GameStateEffectsService EffectsService;

    EffectsService = new class'Jammerware_GameStateEffectsService';

    return
        !CandidateUnit.IsDead() &&
        (RequiredCandidateTeam == eTeam_All || CandidateUnit.GetTeam() == RequiredCandidateTeam) && 
        (RequiredCandidateEffect == 'None' || EffectsService.IsUnitAffectedByEffect(CandidateUnit, RequiredCandidateEffect)) &&
        (RequiredCandidateCharacterGroup == 'None' || CandidateUnit.GetMyTemplate().CharacterGroupName == RequiredCandidateCharacterGroup) &&
        AreTilesAdjacent(SourceTile, CandidateUnit.TileLocation);
}

public function bool IsUnitAdjacentToSpire(XComGameState_Unit Unit, optional name RequiredSpireEffect)
{
    return IsTileAdjacentToAlly(Unit.TileLocation, Unit.GetTeam(), class'X2Character_Spire'.default.NAME_CHARACTERGROUP_SPIRE, RequiredSpireEffect);
}