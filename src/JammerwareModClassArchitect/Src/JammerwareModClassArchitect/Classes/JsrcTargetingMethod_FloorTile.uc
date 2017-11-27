class JsrcTargetingMethod_FloorTile extends X2TargetingMethod;

// UI thingies
var protected XCom3DCursor Cursor;
var protected XComActionIconManager IconManager;
var protected JsrcActor_ValidTile ValidTileActor;

// internal utility thingies
const CURSOR_RANGE_UNLIMITED = -1;

// state-based stuff computed on init
var protected float AbilityRangeUnits;
var protected XComGameState_Unit ShooterState;
var private array<TTile> LegalTiles;

function Init(AvailableAction InAction, int NewTargetIndex)
{
	super.Init(InAction, NewTargetIndex);

    // init actors and cursor
    Cursor = `CURSOR;
	IconManager = `PRES.GetActionIconMgr();
	IconManager.UpdateCursorLocation(true);
	ValidTileActor = Cursor.Spawn(class'JsrcActor_ValidTile', Cursor);
	ValidTileActor.SetHidden(true);

	// store shooter state for validation
	ShooterState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(Ability.OwnerStateObject.ObjectID));

    // store the range of the ability for use during validation
    AbilityRangeUnits = `METERSTOUNITS(Ability.GetAbilityCursorRangeMeters());

	// the idea behind this kind of targeting method is that the legal tiles are a subset of visible tiles and are known at init. we cache them here 
	LegalTiles = GetLegalTilesInternal();
	`LOG("JSRC: done getting all the tiles");

	// Draw them so the player can see their options
	DrawAOETiles(LegalTiles);
	`LOG("JSRC: drew the tiles");

	// lock the cursor to the range of the ability - subclasses can reimplement GetCursorRange to change the lock range
    LockCursorRange();
}

function Canceled()
{
	super.Canceled();
	Cleanup();
}

function Committed()
{
	super.Committed();
	Cleanup();
}

private function Cleanup()
{
	IconManager.ShowIcons(false);
	AOEMeshActor.Destroy();
	ValidTileActor.Destroy();
	Cursor.m_fMaxChainedDistance = CURSOR_RANGE_UNLIMITED;
}

function Update(float DeltaTime)
{
	local vector NewTargetLocation;
	local array<vector> PossibleTargetLocations;
	local TTile TargetTile;
	
	NewTargetLocation = Cursor.GetCursorFeetLocation();

	if (NewTargetLocation != CachedTargetLocation)
	{
		CachedTargetLocation = NewTargetLocation;
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

function name ValidateTargetLocations(const array<Vector> TargetLocations)
{
	local name AbilityAvailability;
	local TTile TargetTile, TileIterator;
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
	else
	{
		AbilityAvailability = 'AA_NotInRange';
		`XWORLD.GetFloorTileForPosition(TargetLocations[0], TargetTile);

		foreach self.LegalTiles(TileIterator)
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

function GetTargetLocations(out array<Vector> TargetLocations)
{
	TargetLocations.Length = 0;
	TargetLocations.AddItem(Cursor.GetCursorFeetLocation());
}

function int GetTargetIndex()
{
	return 0;
}

protected function array<TTile> GetLegalTiles()
{
	local array<TilePosPair> TilePosPairs;
	local vector ShooterPosition;
	local XComWorldData World;
	local array<TTile> Tiles;
	local TilePosPair PairIterator;

	if (AbilityRangeUnits != -1)
	{
		World = `XWORLD;
		ShooterPosition = World.GetPositionFromTileCoordinates(ShooterState.TileLocation);
		World.CollectTilesInSphere(TilePosPairs, ShooterPosition, AbilityRangeUnits);

		foreach TilePosPairs(PairIterator)
		{
			Tiles.AddItem(PairIterator.Tile);
		}
	}

	return Tiles;
}

private function array<TTile> GetLegalTilesInternal()
{
	local array<TTile> UnvalidatedTiles;
	local array<TTile> ValidatedTiles;
	local TTile TileIterator;
	local XComWorldData World;

	World = `XWORLD;
	UnvalidatedTiles = GetLegalTiles();

	foreach UnvalidatedTiles(TileIterator)
	{
		if (World.CanUnitsEnterTile(TileIterator) && !World.IsTileFullyOccupied(TileIterator))
		{
			ValidatedTiles.AddItem(TileIterator);
		}
	}

	return ValidatedTiles;
}

private function DrawValidCursorLocation(TTile Tile)
{
	local vector TileLocation;
	`XWORLD.GetFloorPositionForTile(Tile, TileLocation);

	ValidTileActor.SetLocation(TileLocation);
	ValidTileActor.SetHidden(false);
}

protected function int GetCursorRange()
{
	return AbilityRangeUnits;
}

private function LockCursorRange()
{
	Cursor.m_fMaxChainedDistance = GetCursorRange();
}