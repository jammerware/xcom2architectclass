class X2Effect_SpawnSpire extends X2Effect_SpawnUnit;

var name NAME_SPIRE_SPAWN_TRIGGER;

function vector GetSpawnLocation(const out EffectAppliedData ApplyEffectParameters, XComGameState NewGameState)
{
	local vector SpawnLocation;
	local XComGameState_Unit SourceUnitGameState, TargetUnitGameState;

	SourceUnitGameState = XComGameState_Unit(NewGameState.GetGameStateForObjectID(ApplyEffectParameters.SourceStateObjectRef.ObjectID));
	TargetUnitGameState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));

	`LOG("JSRC: headstone's target is" @ TargetUnitGameState.GetMyTemplateName());
	`LOG("JSRC: target tile location is" @ `XWorld.GetPositionFromTileCoordinates(TargetUnitGameState.TileLocation));
	`LOG("JSRC: input location is" @ ApplyEffectParameters.AbilityInputContext.TargetLocations[0]);

	if (SourceUnitGameState.GetReference().ObjectID != TargetUnitGameState.GetReference().ObjectID)
	{
		// if this effect is cast on a target (like it is when Headstone is used), use the location of the target unit
		SpawnLocation = `XWorld.GetPositionFromTileCoordinates(TargetUnitGameState.TileLocation);
	}
	else
	{
		// otherwise, use user input location
		SpawnLocation = ApplyEffectParameters.AbilityInputContext.TargetLocations[0];
	}
	
	return SpawnLocation;
}

function name GetUnitToSpawnName(const out EffectAppliedData ApplyEffectParameters)
{
	local XComGameStateHistory History;
	local XComGameState_Item SourceWeaponState;
	local name SourceWeaponTemplateName;
	
	History = `XCOMHISTORY;
	SourceWeaponState = XComGameState_Item(History.GetGameStateForObjectID(ApplyEffectParameters.ItemStateObjectRef.ObjectID));
	SourceWeaponTemplateName = SourceWeaponState.GetMyTemplateName();

	// i'd love to somehow attach the name of the spire to summon to each individual weapon in config, but stuck with this for now
	switch (SourceWeaponTemplateName) 
	{
		case class'X2Item_SpireGun'.default.NAME_SPIREGUN_MAGNETIC: return class'X2Character_Spire'.default.NAME_CHARACTER_SPIRE_MAGNETIC;
		case class'X2Item_SpireGun'.default.NAME_SPIREGUN_BEAM: return class'X2Character_Spire'.default.NAME_CHARACTER_SPIRE_BEAM;
		default: return class'X2Character_Spire'.default.NAME_CHARACTER_SPIRE_CONVENTIONAL;
	}
}

function ETeam GetTeam(const out EffectAppliedData ApplyEffectParameters)
{
	return GetSourceUnitsTeam(ApplyEffectParameters);
}

function OnSpawnComplete(const out EffectAppliedData ApplyEffectParameters, StateObjectReference NewUnitRef, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Unit SourceUnitGameState, SpireUnitGameState, TargetUnitGameState;
	local Jammerware_SpireAbilitiesService SpireAbilitiesService;
	local Jammerware_SpireRegistrationService SpireRegistrationService;

	SpireAbilitiesService = new class'Jammerware_SpireAbilitiesService';
	SpireRegistrationService = new class'Jammerware_SpireRegistrationService';

	SourceUnitGameState = XComGameState_Unit(NewGameState.GetGameStateForObjectID(ApplyEffectParameters.SourceStateObjectRef.ObjectID));
	SpireUnitGameState = XComGameState_Unit(NewGameState.GetGameStateForObjectID(NewUnitRef.ObjectID));
	TargetUnitGameState = XComGameState_Unit(NewGameState.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));

	// if spawnspire was cast on a unit (like it is when Headstone is used), remove that unit from play
	if (ApplyEffectParameters.SourceStateObjectRef.ObjectID != ApplyEffectParameters.TargetStateObjectRef.ObjectID)
	{
		`XEVENTMGR.TriggerEvent('UnitRemovedFromPlay', TargetUnitGameState, TargetUnitGameState, NewGameState);
	}

	// TODO: look at X2Effect_SpawnPsiZombie to track relationship between runner and spire. this'll let us have a buff on the spire indicating the relationship if we want
	// (not to mention it's less gross)
	SpireRegistrationService.RegisterSpireToRunner(SpireUnitGameState, SourceUnitGameState);

	// DANGER, WILL ROBINSON
	// i'm super unsure of this implementation, especially because it results in using the dreaded InitAbilityForUnit method, which is indicated as
	// pretty dangerous by Firaxis. if the soldier who spawns the spire has certain abilities, the spire gets them too
	SpireAbilitiesService.ConfigureSpireAbilities(SpireUnitGameState, SourceUnitGameState, NewGameState);

	// set the cover state of the spire
	SpireUnitGameState.bGeneratesCover = true;
	SpireUnitGameState.CoverForceFlag = CoverForce_High;

	// if the source unit has FieldReloadModule, allied units adjacent to the spire should be reloaded
	`XEVENTMGR.TriggerEvent(default.NAME_SPIRE_SPAWN_TRIGGER, SpireUnitGameState, SourceUnitGameState, NewGameState);
}

defaultproperties
{
	bInfiniteDuration=true
	EffectName=Jammerware_JSRC_Effect_SpawnSpire
	NAME_SPIRE_SPAWN_TRIGGER=Jammerware_JSRC_EventTrigger_SpireSpawn
}