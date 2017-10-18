class X2TargetingMethod_SpawnSpire extends X2TargetingMethod;

var private XCom3DCursor Cursor;
var private X2Actor_InvalidTarget InvalidTileActor;
var private XComActionIconManager IconManager;

// shooter state info - unless this is preserved during init, we can't get to it in validation
var private bool bShooterHasUnity;
var private float AbilityRangeUnits;
var private XComGameState GameState;
var private XComGameState_Unit ShooterState;

function Init(AvailableAction InAction, int NewTargetIndex)
{
	local XComGameStateHistory History;
	local float TargetingRangeUnits;
	local Jammerware_GameStateEffectsService GameStateEffectsService;

	super.Init(InAction, NewTargetIndex);

	// this initialization is pretty much from X2TargetingMethod_Teleport
	InvalidTileActor = `BATTLE.Spawn(class'X2Actor_InvalidTarget');

	IconManager = `PRES.GetActionIconMgr();
	IconManager.UpdateCursorLocation(true);
	// end ripped-off code

	History = `XCOMHISTORY;
	GameState = History.GetGameStateFromHistory(History.GetCurrentHistoryIndex());
    ShooterState = XComGameState_Unit(History.GetGameStateForObjectID(Ability.OwnerStateObject.ObjectID));
	AbilityRangeUnits = `METERSTOUNITS(Ability.GetAbilityCursorRangeMeters());
	GameStateEffectsService = new class'Jammerware_GameStateEffectsService';

	// determine our targeting range (the range in which the cursor can potentially produce legal targets)
	if (!GameStateEffectsService.IsUnitAffectedByEffect(ShooterState, class'X2Ability_RunnerAbilitySet'.default.NAME_UNITY))
	{
		TargetingRangeUnits = AbilityRangeUnits;
	}
	else 
	{
		// caching this on startup to make validation faster if the runner doesn't have unity
		bShooterHasUnity = true;
		TargetingRangeUnits = -1;
	}

	// lock the cursor to that range
	Cursor = `Cursor;
	Cursor.m_fMaxChainedDistance = TargetingRangeUnits;
}

function Canceled()
{
	super.Canceled();
	InvalidTileActor.Destroy();
	IconManager.ShowIcons(false);
}

function Update(float DeltaTime)
{
	local vector NewTargetLocation;
	local array<vector> TargetLocations;
	local array<TTile> Tiles;
	local XComWorldData World;
	local TTile TargetTile;
	
	NewTargetLocation = Cursor.GetCursorFeetLocation();

	if( NewTargetLocation != CachedTargetLocation )
	{
		TargetLocations.AddItem(Cursor.GetCursorFeetLocation());
		if (ValidateTargetLocations(TargetLocations) == 'AA_Success')
		{
			// The current tile the cursor is on is a valid tile
			// Show the ExplosionEmitter
			//ExplosionEmitter.ParticleSystemComponent.ActivateSystem();
			InvalidTileActor.SetHidden(true);

			World = `XWORLD;
		
			TargetTile = World.GetTileCoordinatesFromPosition(TargetLocations[0]);
			Tiles.AddItem(TargetTile);
			DrawAOETiles(Tiles);
			IconManager.UpdateCursorLocation(, true);
		}
		else
		{
			DrawInvalidTile();
		}
	}

	super.UpdateTargetLocation(DeltaTime);
}

function GetTargetLocations(out array<Vector> TargetLocations)
{
	TargetLocations.Length = 0;
	TargetLocations.AddItem(Cursor.GetCursorFeetLocation());
}

simulated protected function DrawInvalidTile()
{
	local Vector Center;

	Center = Cursor.GetCursorFeetLocation();
	InvalidTileActor.SetHidden(false);
	InvalidTileActor.SetLocation(Center);
}

function name ValidateTargetLocations(const array<Vector> TargetLocations)
{
	local name AbilityAvailability;
	local TTile ShooterTile, TargetTile;
	local XComWorldData World;
	local bool bFoundFloorTile;
	local Jammerware_ProximityService ProximityService;

	AbilityAvailability = super.ValidateTargetLocations(TargetLocations);
	if( AbilityAvailability == 'AA_Success' )
	{
		// There is only one target location and visible by squadsight
		World = `XWORLD;
		
		`assert(TargetLocations.Length == 1);
		bFoundFloorTile = World.GetFloorTileForPosition(TargetLocations[0], TargetTile);
		if (bFoundFloorTile && !World.CanUnitsEnterTile(TargetTile))
		{
			AbilityAvailability = 'AA_TileIsBlocked';
		}
		else if (self.bShooterHasUnity)
		{
			// assuming here for performance that the cursor has been locked to legal range in init, so we only
			// bother to do this check if the runner has unity
			ProximityService = new class'Jammerware_ProximityService';
			ShooterState.GetKeystoneVisibilityLocation(ShooterTile);

			if (
				ProximityService.GetUnitDistanceBetween(ShooterTile, TargetTile) > AbilityRangeUnits && 
				!ProximityService.IsTileAdjacentToAlly(TargetTile, self.GameState, self.ShooterState)
			)
			{
				AbilityAvailability = 'AA_NotInRange';
			}
		}
	}

	return AbilityAvailability;
}

function int GetTargetIndex()
{
	return 0;
}