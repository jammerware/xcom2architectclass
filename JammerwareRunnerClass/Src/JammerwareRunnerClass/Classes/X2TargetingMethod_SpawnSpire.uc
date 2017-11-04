class X2TargetingMethod_SpawnSpire extends X2TargetingMethod_FloorTile;

var private bool bShooterHasUnity;

function Init(AvailableAction InAction, int NewTargetIndex)
{
	super.Init(InAction, NewTargetIndex);

	// if the shooter has unity, the cursor needs to be unlocked to allow selection of tiles adjacent to allies
	if (ShooterState.AffectedByEffectNames.Find(class'X2Ability_RunnerAbilitySet'.default.NAME_UNITY) != INDEX_NONE)
	{
		bShooterHasUnity = true;
		LockCursorRange(-1);
	}
}

function name ValidateTargetLocations(const array<Vector> TargetLocations)
{
	local name AbilityAvailability;
	local TTile TargetTile;
	local XComWorldData World;
	local Jammerware_JSRC_ProximityService ProximityService;

	World = `XWORLD;
	// the parent class makes sure the tile isn't blocked and is a floor tile
	AbilityAvailability = super.ValidateTargetLocations(TargetLocations);

	// we assume the cursor has been locked to the ability range in init if the shooter doesn't have unity
	if (AbilityAvailability == 'AA_Success' && self.bShooterHasUnity)
	{
		ProximityService = new class'Jammerware_JSRC_ProximityService';
		World.GetFloorTileForPosition(TargetLocations[0], TargetTile);

		if (
			!super.IsInAbilityRange(TargetTile) &&
			!ProximityService.IsTileAdjacentToAlly(TargetTile, self.ShooterState.GetTeam())
		)
		{
			AbilityAvailability = 'AA_NotInRange';
		}
	}
	return AbilityAvailability;
}