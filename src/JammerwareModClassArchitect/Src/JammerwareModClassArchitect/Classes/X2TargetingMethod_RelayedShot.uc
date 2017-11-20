// pretty much recreating a lot of X2TargetingMethod_TopDown, but i want the camera to look
// at the furthest actor (enemy) that would be hit by the ability rather than the spire
// which is the primary target
class X2TargetingMethod_RelayedShot extends X2TargetingMethod;

var private X2Camera_Midpoint Camera;
var protected int LastTarget;

function Init(AvailableAction InAction, int NewTargetIndex)
{
	super.Init(InAction, NewTargetIndex);
	
	Camera = new class'X2Camera_Midpoint';
	`CAMERASTACK.AddCamera(Camera);

	DirectSetTarget(0);
}

function Canceled()
{
	super.Canceled();
	`CAMERASTACK.RemoveCamera(Camera);
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
	local Actor TargetedActor, ActorIterator;
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

	Camera.ClearFocusActors();
	if( Tiles.Length > 1 )
	{
		GetTargetedActors(TargetedLocation, CurrentlyMarkedTargets, Tiles);
		CheckForFriendlyUnit(CurrentlyMarkedTargets);
		MarkTargetedActors(CurrentlyMarkedTargets, (!AbilityIsOffensive) ? FiringUnit.GetTeam() : eTeam_None);
		DrawAOETiles(Tiles);

		foreach CurrentlyMarkedTargets(ActorIterator)
		{
			Camera.AddFocusActor(ActorIterator);
		}

		Camera.RecomputeLookatPointAndZoom(false);
	}
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