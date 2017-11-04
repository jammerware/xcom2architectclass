class X2Effect_Impetus extends X2Effect_Knockback;

// gets the 8 tiles surrounding the input tile
private function array<TTile> GetAdjacentTiles(TTile Tile)
{
	local int x, y;
	local TTile StartingTile, TempTile;
	local array<TTile> Tiles;

	for (x = -1; x <= 1; x++)
	{
		for (y = -1; y <=1; y++)
		{
			TempTile = StartingTile;
			TempTile.X += x;
			TempTile.Y += y;

			if (TempTile.X != StartingTile.X || TempTile.Y != StartingTile.Y)
			{
				Tiles.AddItem(TempTile);
			}
		}
	}

	return Tiles;
}

private function TTile GetClosestTile(TTile StartTile, array<TTile> Tiles)
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
		TileLocation = World.GetPositionFromTileCoordinates(TileIterator);
		Distance = VSize2D(TileLocation - StartLocation);

		if (Distance < MinDistance)
		{
			`LOG("New tile" @ TileLocation @ "is closer" @ Distance);
			MinDistance = Distance;
			ClosestTile = TileIterator;
		}
	}

	return ClosestTile;
}

private function bool CanBeDestroyed(XComInteractiveLevelActor InteractiveActor, float DamageAmount)
{
	//make sure the knockback damage can destroy this actor.
	//check the number of interaction points to prevent larger objects from being destroyed.
	return InteractiveActor != none && DamageAmount >= InteractiveActor.Health && InteractiveActor.InteractionPoints.Length <= 8;
}

private function int GetKnockbackDistance(XComGameStateContext_Ability AbilityContext, XComGameState_BaseObject kNewTargetState)
{
	local int UpdatedKnockbackDistance_Meters, ReasonIndex;
	local XComGameState_Unit TargetUnitState;
	local name UnitTypeName;

	UpdatedKnockbackDistance_Meters = KnockbackDistance;

	TargetUnitState = XComGameState_Unit(kNewTargetState);
	if (TargetUnitState != none)
	{
		UnitTypeName = TargetUnitState.GetMyTemplate().CharacterGroupName;
	}

	// For now, the only OverrideReason is CharacterGroupName. If otheres are desired, add extra checks here.
	ReasonIndex = KnockbackDistanceOverrides.Find('OverrideReason', UnitTypeName);

	if (ReasonIndex != INDEX_NONE)
	{
		UpdatedKnockbackDistance_Meters = KnockbackDistanceOverrides[ReasonIndex].NewKnockbackDistance_Meters;
	}

	return UpdatedKnockbackDistance_Meters;
}

simulated function ApplyEffectToWorld(const out EffectAppliedData ApplyEffectParameters, XComGameState NewGameState)
{
	local XComGameStateContext_Ability AbilityContext;
	local XComGameState_BaseObject kNewTargetState;
	local int Index;
	local XComGameState_EnvironmentDamage DamageEvent;
	local XComWorldData WorldData;
	local TTile HitTile;
	local array<TTile> TilesEntered;
	local Vector AttackDirection;
	local XComGameState_Item SourceItemStateObject;
	local XComGameStateHistory History;
	local X2WeaponTemplate WeaponTemplate;
	local array<StateObjectReference> Targets;
	local StateObjectReference CurrentTarget;
	local XComGameState_Unit TargetUnit;
	local TTile NewTileLocation;
	local float KnockbackDamage;
	local float KnockbackRadius;
	local int EffectIndex, MultiTargetIndex;
	local X2Effect_Knockback KnockbackEffect;

	AbilityContext = XComGameStateContext_Ability(NewGameState.GetContext());
	if(AbilityContext != none)
	{
		if (AbilityContext.InputContext.PrimaryTarget.ObjectID > 0)
		{
			// Check the Primary Target for a successful knockback
			for (EffectIndex = 0; EffectIndex < AbilityContext.ResultContext.TargetEffectResults.Effects.Length; ++EffectIndex)
			{
				KnockbackEffect = X2Effect_Knockback(AbilityContext.ResultContext.TargetEffectResults.Effects[EffectIndex]);
				if (KnockbackEffect != none)
				{
					if (AbilityContext.ResultContext.TargetEffectResults.ApplyResults[EffectIndex] == 'AA_Success')
					{
						Targets.AddItem(AbilityContext.InputContext.PrimaryTarget);
						break;
					}
				}
			}
		}

		for (MultiTargetIndex = 0; MultiTargetIndex < AbilityContext.InputContext.MultiTargets.Length; ++MultiTargetIndex)
		{
			// Check the MultiTargets for a successful knockback
			for (EffectIndex = 0; EffectIndex < AbilityContext.ResultContext.MultiTargetEffectResults[MultiTargetIndex].Effects.Length; ++EffectIndex)
			{
				KnockbackEffect = X2Effect_Knockback(AbilityContext.ResultContext.MultiTargetEffectResults[MultiTargetIndex].Effects[EffectIndex]);
				if (KnockbackEffect != none)
				{
					if (AbilityContext.ResultContext.MultiTargetEffectResults[MultiTargetIndex].ApplyResults[EffectIndex] == 'AA_Success')
					{
						`LOG("JSRC: found a multitarget");
						Targets.AddItem(AbilityContext.InputContext.MultiTargets[MultiTargetIndex]);
						break;
					}
				}
			}
		}

		foreach Targets(CurrentTarget)
		{
			History = `XCOMHISTORY;
				SourceItemStateObject = XComGameState_Item(History.GetGameStateForObjectID(ApplyEffectParameters.ItemStateObjectRef.ObjectID));
			if (SourceItemStateObject != None)
				WeaponTemplate = X2WeaponTemplate(SourceItemStateObject.GetMyTemplate());

			if (WeaponTemplate != none)
			{
				KnockbackDamage = WeaponTemplate.fKnockbackDamageAmount >= 0.0f ? WeaponTemplate.fKnockbackDamageAmount : DefaultDamage;
				KnockbackRadius = WeaponTemplate.fKnockbackDamageRadius >= 0.0f ? WeaponTemplate.fKnockbackDamageRadius : DefaultRadius;
			}
			else
			{
				KnockbackDamage = DefaultDamage;
				KnockbackRadius = DefaultRadius;
			}

			kNewTargetState = NewGameState.GetGameStateForObjectID(CurrentTarget.ObjectID);
			TargetUnit = XComGameState_Unit(kNewTargetState);
			if(TargetUnit != none) //Only units can be knocked back
			{
				TilesEntered.Length = 0;
				GetTilesEnteredArray(AbilityContext, kNewTargetState, TilesEntered, AttackDirection, KnockbackDamage, NewGameState);

				//Only process the code below if the target went somewhere
				if(TilesEntered.Length > 0)
				{
					WorldData = `XWORLD;

					if(bKnockbackDestroysNonFragile)
					{
						for(Index = 0; Index < TilesEntered.Length; ++Index)
						{
							HitTile = TilesEntered[Index];
							HitTile.Z += 1;

							DamageEvent = XComGameState_EnvironmentDamage(NewGameState.CreateNewStateObject(class'XComGameState_EnvironmentDamage'));
							DamageEvent.DEBUG_SourceCodeLocation = "UC: X2Effect_Knockback:ApplyEffectToWorld";
							DamageEvent.DamageAmount = KnockbackDamage;
							DamageEvent.DamageTypeTemplateName = 'Melee';
							DamageEvent.HitLocation = WorldData.GetPositionFromTileCoordinates(HitTile);
							DamageEvent.Momentum = AttackDirection;
							DamageEvent.DamageDirection = AttackDirection; //Limit environmental damage to the attack direction( ie. spare floors )
							DamageEvent.PhysImpulse = 100;
							DamageEvent.DamageRadius = KnockbackRadius;
							DamageEvent.DamageCause = ApplyEffectParameters.SourceStateObjectRef;
							DamageEvent.DamageSource = DamageEvent.DamageCause;
							DamageEvent.bRadialDamage = false;
						}
					}

					NewTileLocation = TilesEntered[TilesEntered.Length - 1];
					TargetUnit.SetVisibilityLocation(NewTileLocation);
				}
			}			
		}
	}
}

// this is simplified from the original implementation that i lifted from X2Effect_Knockback
// Unlike effects in the base game that apply knockbacks, i'm applying mine via a cone targeting thing. this differs from the original implementation in that
// it doesn't handle a lot of random cases that the general effect does, and it calculates the tile adjacent to the target that is closest the shooter and just 
// lies and says that the knockback came from there instead. it'll be cool if it works.
private function GetTilesEnteredArray(XComGameStateContext_Ability AbilityContext, XComGameState_BaseObject kNewTargetState, out array<TTile> OutTilesEntered, out Vector OutAttackDirection, float DamageAmount, XComGameState NewGameState)
{
	local XComGameStateHistory History;
	local XComWorldData WorldData;

	local XComGameState_Unit ShooterUnit;
	local Vector ShooterLocation;
	local TTile ShooterTile;

	local TTile KnockbackSourceTile;
	local Vector KnockbackSourceLocation;

	local XComGameState_Unit TargetUnit;
	local array<TTile> TargetAdjacentTiles;
	local TTile TargetTile;
	local XGUnit TargetVisualizer;
	local XComUnitPawn TargetUnitPawn;
	local Vector TargetLocation;

	local Vector StartLocation;
	local TTile  TempTile, LastTempTile;
	local Vector KnockbackToLocation;	
	local float  StepDistance;
	local Vector TestLocation;
	local float  TestDistanceUnits;
	local Vector Extents;
	local float StepSize;

	local ActorTraceHitInfo TraceHitInfo;
	local array<ActorTraceHitInfo> Hits;
	local Actor FloorTileActor;

	local int UpdatedKnockbackDistance_Meters;
	local array<StateObjectReference> TileUnits;

	WorldData = `XWORLD;
	History = `XCOMHISTORY;
	
	StepSize = 8.0;

	// find the shooter and target
	TargetUnit = XComGameState_Unit(kNewTargetState);
	TargetTile = TargetUnit.TileLocation;
	TargetLocation = WorldData.GetPositionFromTileCoordinates(TargetTile);
	TargetAdjacentTiles = GetAdjacentTiles(TargetTile);

	`LOG("JSRC: there are" @ TargetAdjacentTiles.Length @ "adjacent tiles");

	ShooterUnit = XComGameState_Unit(NewGameState.GetGameStateForObjectID(AbilityContext.InputContext.SourceObject.ObjectID));
	ShooterTile = ShooterUnit.TileLocation;
	ShooterLocation = WorldData.GetPositionFromTileCoordinates(ShooterTile);

	KnockbackSourceTile = GetClosestTile(ShooterTile, TargetAdjacentTiles);
	KnockbackSourceLocation = WorldData.GetPositionFromTileCoordinates(KnockbackSourceTile);

	`LOG("JSRC: shooter at" @ ShooterLocation);
	`LOG("JSRC: target at" @ TargetLocation);
	`LOG("JSRC: knockback coming from" @ KnockbackSourceLocation);

	OutAttackDirection = Normal(TargetLocation - KnockbackSourceLocation);
	OutAttackDirection.Z = 0.0f;
	StartLocation = TargetLocation;

	UpdatedKnockbackDistance_Meters = GetKnockbackDistance(AbilityContext, kNewTargetState);
	KnockbackToLocation = StartLocation + (OutAttackDirection * float(UpdatedKnockbackDistance_Meters) * 64.0f); //Convert knockback distance to meters

	TargetVisualizer = XGUnit(History.GetVisualizer(TargetUnit.ObjectID));
	if (TargetVisualizer != None)
	{
		TargetUnitPawn = TargetVisualizer.GetPawn();
		if( TargetUnitPawn != None )
		{
			Extents.X = TargetUnitPawn.CylinderComponent.CollisionRadius;
			Extents.Y = TargetUnitPawn.CylinderComponent.CollisionRadius; 
			Extents.Z = TargetUnitPawn.CylinderComponent.CollisionHeight;
		}
	}

	if (WorldData.GetAllActorsTrace(StartLocation, KnockbackToLocation, Hits, Extents))
	{
		foreach Hits(TraceHitInfo)
		{
			TempTile = WorldData.GetTileCoordinatesFromPosition(TraceHitInfo.HitLocation);
			FloorTileActor = WorldData.GetFloorTileActor(TempTile);

			if (TraceHitInfo.HitActor == FloorTileActor)
			{
				continue;
			}

			if ((!CanBeDestroyed(XComInteractiveLevelActor(TraceHitInfo.HitActor), DamageAmount) && XComFracLevelActor(TraceHitInfo.HitActor) == none) || !bKnockbackDestroysNonFragile)
			{
				//We hit an indestructible object
				KnockbackToLocation = TraceHitInfo.HitLocation + (-OutAttackDirection * 16.0f); //Scoot the hit back a bit and use that as the knockback location
				break;
			}
		}
	}

	// Walk in increments down the attack vector. We will stop if we can't find a floor, or have reached the knock back distance, or we encounter another unit.
	TestDistanceUnits = VSize2D(KnockbackToLocation - StartLocation);
	StepDistance = 0.0f;
	OutTilesEntered.Length = 0;
	LastTempTile = TargetTile;
	while (StepDistance < TestDistanceUnits)
	{
		TestLocation = StartLocation + (OutAttackDirection * StepDistance);			

		if (!WorldData.GetFloorTileForPosition(TestLocation, TempTile, true))
		{
			break;
		}

		if (TempTile != TargetTile)		//	don't check the start tile, since the target unit would be on it
		{
			TileUnits = WorldData.GetUnitsOnTile(TempTile);
			if (TileUnits.Length > 0)
				break;
		}

		if (LastTempTile != TempTile)
		{
			OutTilesEntered.AddItem(TempTile);
			LastTempTile = TempTile;
		}

		StepDistance += StepSize;
	}

	//Move the target unit to the knockback location			
	if (OutTilesEntered.Length == 0 || OutTilesEntered[OutTilesEntered.Length - 1] != LastTempTile)
		OutTilesEntered.AddItem(LastTempTile);
}

defaultproperties
{
	DamageTypes.Add("KnockbackDamage");
	OverrideRagdollFinishTimerSec=-1
	ApplyChanceFn=WasTargetPreviouslyDead
}