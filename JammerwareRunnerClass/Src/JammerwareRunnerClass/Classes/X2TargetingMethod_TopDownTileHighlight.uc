class X2TargetingMethod_TopDownTileHighlight extends X2TargetingMethod_TopDown;

function DirectSetTarget(int TargetIndex)
{
    local array<TTile> Tiles;
    local Actor TargetedActor;
    local XGUnit TargetedPawn;
    local vector TargetedLocation;

    super.DirectSetTarget(TargetIndex);

    TargetedActor = GetTargetedActor();
    TargetedPawn = XGUnit(TargetedActor);
	if( TargetedPawn != none )
	{
		TargetedLocation = TargetedPawn.GetFootLocation();
        Tiles.AddItem(`XWORLD.GetTileCoordinatesFromPosition(TargetedLocation));
    }

    DrawAOETiles(Tiles);
}