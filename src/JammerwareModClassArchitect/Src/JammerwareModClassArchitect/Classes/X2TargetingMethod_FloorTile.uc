class X2TargetingMethod_FloorTile extends X2TargetingMethod;

var protected XCom3DCursor Cursor;
var protected XComActionIconManager IconManager;

var protected float AbilityRangeUnits;
var protected XComGameState_Unit ShooterState;

function Init(AvailableAction InAction, int NewTargetIndex)
{
	super.Init(InAction, NewTargetIndex);

    // this initialization is pretty much from X2TargetingMethod_Teleport
	IconManager = `PRES.GetActionIconMgr();
	IconManager.UpdateCursorLocation(true);
	// end ripped-off code

    // cache cursor reference for later use
    Cursor = `CURSOR;

	// store shooter state for validation
	ShooterState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(Ability.OwnerStateObject.ObjectID));

    // store the range of the ability for use during validation
    AbilityRangeUnits = `METERSTOUNITS(Ability.GetAbilityCursorRangeMeters());

    // lock the cursor to ability range - subclasses may re-lock in their RangeInUnits
    LockCursorRange(AbilityRangeUnits);
}

function Canceled()
{
	super.Canceled();
	IconManager.ShowIcons(false);
}

function Committed()
{
	super.Committed();
	AOEMeshActor.Destroy();
}

function Update(float DeltaTime)
{
	local vector NewTargetLocation;
	local array<vector> PossibleTargetLocations;
	local TTile TargetTile;
	
	NewTargetLocation = Cursor.GetCursorFeetLocation();

	if (NewTargetLocation != CachedTargetLocation)
	{
		PossibleTargetLocations.AddItem(Cursor.GetCursorFeetLocation());
		if (ValidateTargetLocations(PossibleTargetLocations) == 'AA_Success')
		{
			TargetTile = `XWORLD.GetTileCoordinatesFromPosition(PossibleTargetLocations[0]);
			DrawValidCursorLocation(TargetTile);
			IconManager.UpdateCursorLocation(, true);
		}
	}

	super.UpdateTargetLocation(DeltaTime);
}

protected function DrawValidCursorLocation(TTile Tile)
{
	local array<TTile> Tiles;

	Tiles.AddItem(Tile);
	DrawAOETiles(Tiles);
}

function name ValidateTargetLocations(const array<Vector> TargetLocations)
{
	local name AbilityAvailability;
	local TTile TargetTile;
	local XComWorldData World;
	local bool bFoundFloorTile;

	AbilityAvailability = 'AA_Success';
	World = `XWORLD;
		
	`assert(TargetLocations.Length == 1);
	bFoundFloorTile = World.GetFloorTileForPosition(TargetLocations[0], TargetTile);
	if (bFoundFloorTile && !World.CanUnitsEnterTile(TargetTile))
	{
		AbilityAvailability = 'AA_TileIsBlocked';
	}

	return AbilityAvailability;
}

function GetTargetLocations(out array<Vector> TargetLocations)
{
	TargetLocations.Length = 0;
	TargetLocations.AddItem(Cursor.GetCursorFeetLocation());
}

function int GetTargetIndex()
{
	return 0;
}

protected function LockCursorRange(float RangeInUnits)
{
	Cursor.m_fMaxChainedDistance = RangeInUnits;
}

protected function bool IsInAbilityRange(TTile TargetTile)
{
    local Jammerware_JSRC_ProximityService ProximityService;

    ProximityService = new class'Jammerware_JSRC_ProximityService';
    return AbilityRangeUnits == -1 || ProximityService.GetUnitDistanceBetween(ShooterState.TileLocation, TargetTile) <= AbilityRangeUnits;
}