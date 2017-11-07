// pretty much recreating a lot of X2TargetingMethod_TopDown, but i want the camera to look
// at the furthest actor (enemy) that would be hit by the ability rather than the spire
// which is the primary target
class X2TargetingMethod_RelayedShot extends X2TargetingMethod;

var private X2Camera_LookAtActor LookatCamera;
var protected int LastTarget;

function Init(AvailableAction InAction, int NewTargetIndex)
{
	super.Init(InAction, NewTargetIndex);
	
	LookatCamera = new class'X2Camera_LookAtActor';
	LookatCamera.UseTether = false;
	`CAMERASTACK.AddCamera(LookatCamera);

	DirectSetTarget(0);
}

function Canceled()
{
	super.Canceled();
	`CAMERASTACK.RemoveCamera(LookatCamera);
	ClearTargetedActors();
}

function Committed()
{
	Canceled();
}

function NextTarget()
{
	DirectSetTarget(LastTarget + 1);
}

function PrevTarget()
{
	DirectSetTarget(LastTarget - 1);
}

function int GetTargetIndex()
{
	return LastTarget;
}

function DirectSetTarget(int TargetIndex)
{
	local XComPresentationLayer Pres;
	local UITacticalHUD TacticalHud;
	local Actor TargetedActor;
	local array<TTile> Tiles;
	local TTile TargetedActorTile;
	local XGUnit TargetedPawn;
	local vector TargetedLocation;
	local XComWorldData World;
	local int NewTarget;
	local array<Actor> CurrentlyMarkedTargets;
	local X2AbilityTemplate AbilityTemplate;

	World = `XWORLD;

	// put the targeting reticle on the new target
	Pres = `PRES;
	TacticalHud = Pres.GetTacticalHUD();

	// advance the target counter
	NewTarget = TargetIndex % Action.AvailableTargets.Length;
	if(NewTarget < 0) NewTarget = Action.AvailableTargets.Length + NewTarget;

	LastTarget = NewTarget;
	TacticalHud.TargetEnemy(Action.AvailableTargets[NewTarget].PrimaryTarget.ObjectID);

	// have the idle state machine look at the new target
	if(FiringUnit != none)
	{
		FiringUnit.IdleStateMachine.CheckForStanceUpdate();
	}

	TargetedActor = GetTargetedActor();
	TargetedPawn = XGUnit(TargetedActor);

	if( TargetedPawn != none )
	{
		TargetedLocation = TargetedPawn.GetFootLocation();
		TargetedActorTile = World.GetTileCoordinatesFromPosition(TargetedLocation);
		TargetedLocation = World.GetPositionFromTileCoordinates(TargetedActorTile);
	}
	else
	{
		TargetedLocation = TargetedActor.Location;
	}

	AbilityTemplate = Ability.GetMyTemplate();

	if ( AbilityTemplate.AbilityMultiTargetStyle != none)
	{
		AbilityTemplate.AbilityMultiTargetStyle.GetValidTilesForLocation(Ability, TargetedLocation, Tiles);
	}

	if( AbilityTemplate.AbilityTargetStyle != none )
	{
		AbilityTemplate.AbilityTargetStyle.GetValidTilesForLocation(Ability, TargetedLocation, Tiles);
	}

	if( Tiles.Length > 1 )
	{
		GetTargetedActors(TargetedLocation, CurrentlyMarkedTargets, Tiles);
		CheckForFriendlyUnit(CurrentlyMarkedTargets);
		MarkTargetedActors(CurrentlyMarkedTargets, (!AbilityIsOffensive) ? FiringUnit.GetTeam() : eTeam_None);
		DrawAOETiles(Tiles);
	}

    // determine which actor is furthest from the shooter, then look at that (or the source unit if no target is available)
    LookatCamera.ActorToFollow = GetLookAtActor(CurrentlyMarkedTargets);
}

function bool GetCurrentTargetFocus(out Vector Focus)
{
	local Actor TargetedActor;
	local X2VisualizerInterface TargetVisualizer;

	TargetedActor = GetTargetedActor();

	if(TargetedActor != none)
	{
		TargetVisualizer = X2VisualizerInterface(TargetedActor);
		if( TargetVisualizer != None )
		{
			Focus = TargetVisualizer.GetTargetingFocusLocation();
		}
		else
		{
			Focus = TargetedActor.Location;
		}
		
		return true;
	}
	
	return false;
}

private function Actor GetLookAtActor(array<Actor> CurrentlyMarkedActors)
{
    local array<XComGameState_Unit> CurrentlyMarkedUnitStates;
    local Actor ActorIterator;
    local XGUnit UnitIterator;
    local XComGameState_Unit FurthestUnitState;
    local Jammerware_JSRC_ProximityService ProximityService;

    ProximityService = new class'Jammerware_JSRC_ProximityService';

    foreach CurrentlyMarkedActors(ActorIterator)
    {
        UnitIterator = XGUnit(ActorIterator);

		if (UnitIterator != none)
			CurrentlyMarkedUnitStates.AddItem(UnitIterator.GetVisualizedGameState());
    }

    FurthestUnitState = ProximityService.GetFurthestUnitFrom(FiringUnit.GetVisualizedGameState(), CurrentlyMarkedUnitStates);

    // if there aren't any enemy units targeted, just look at the targeted spire actor
    if (FurthestUnitState == None)
    {
        return GetTargetedActor();
    }

    return FurthestUnitState.GetVisualizer();
}