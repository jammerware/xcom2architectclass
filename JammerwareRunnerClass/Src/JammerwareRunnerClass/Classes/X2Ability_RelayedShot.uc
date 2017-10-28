class X2Ability_RelayedShot extends X2Ability;

var name NAME_RELAYED_SHOT;

static function X2DataTemplate CreateRelayedShot()
{
    local X2AbilityTemplate Template;
	local X2AbilityCooldown Cooldown;
	local X2AbilityCost_Ammo AmmoCost;
	local X2Condition_UnitProperty TargetPropertiesCondition;
	local X2Condition_UnitType UnitTypeCondition;

	// general properties
	`CREATE_X2ABILITY_TEMPLATE(Template, default.NAME_RELAYED_SHOT);
	Template.Hostility = eHostility_Offensive;

	// hud behavior
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_nulllance";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.bDisplayInUITacticalText = false;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_MAJOR_PRIORITY;
	Template.bLimitTargetIcons = true;
	Template.bFriendlyFireWarning = false;

	// cost
	Template.AbilityCosts.AddItem(default.WeaponActionTurnEnding);

	AmmoCost = new class'X2AbilityCost_Ammo';
	AmmoCost.iAmmo = 1;
	AmmoCost.bConsumeAllAmmo = true;
	Template.AbilityCosts.AddItem(AmmoCost);
	
	// Cooldown
	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = 5;
	Template.AbilityCooldown = Cooldown;

	// targeting style (how targets are determined by game rules)
	Template.AbilityTargetStyle = default.SimpleSingleTarget;
    Template.AbilityMultiTargetStyle = new class'X2AbilityMultiTarget_Line';

	Template.TargetingMethod = class'X2TargetingMethod_Line';
	Template.SkipRenderOfTargetingTemplate = true;

	// hit chance
	Template.AbilityToHitCalc = default.DeadEye;

	// conditions
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	UnitTypeCondition = new class'X2Condition_UnitType';
	UnitTypeCondition.IncludeTypes.AddItem(class'X2Character_Spire'.default.NAME_CHARACTERGROUP_SPIRE);
	Template.AbilityTargetConditions.AddItem(UnitTypeCondition);

	// need to make sure the primary target (spire) is owned by the shooter

    TargetPropertiesCondition = new class'X2Condition_UnitProperty';
	TargetPropertiesCondition.ExcludeHostileToSource = false;
	TargetPropertiesCondition.ExcludeFriendlyToSource = true;
	Template.AbilityMultiTargetConditions.AddItem(TargetPropertiesCondition);

	// triggering
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	// effects
	Template.bAllowAmmoEffects = true;
	Template.AddMultiTargetEffect(new class'X2Effect_ApplyWeaponDamage');
	
	// game state and visualization
	Template.bUsesFiringCamera = true;
	Template.CinescriptCameraType = "StandardGunFiring";
	//Template.ModifyNewContextFn = RelayedShot_ModifyActivatedAbilityContext;
	Template.BuildNewGameStateFn = RelayedShot_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	return Template;
}

static function RelayedShot_ModifyActivatedAbilityContext(XComGameStateContext Context)
{
	local XComWorldData World;
	local XComGameStateContext_Ability AbilityContext;
	local XComGameState_Ability AbilityState;
	local StateObjectReference MultiTargetObjectRef;
	local XComGameState_Unit MultiTargetUnit;
	local int i;

	AbilityContext = XComGameStateContext_Ability(Context);
	AbilityContext.ResultContext.ProjectileHitLocations.Length = 0;
	AbilityState = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(AbilityContext.InputContext.AbilityRef.ObjectID, eReturnType_Reference));
	World = `XWORLD;

	`LOG("JSRC: input target location length" @ AbilityContext.InputContext.TargetLocations.Length);
	`LOG("JSRC: input multitargets length" @ AbilityContext.InputContext.MultiTargets.Length);
	`LOG("JSRC: input projectile events length" @ AbilityContext.InputContext.ProjectileEvents.Length);

	for (i = 0; i < AbilityContext.InputContext.MultiTargets.Length; i++)
	{
		MultiTargetObjectRef = AbilityContext.InputContext.MultiTargets[i];
		MultiTargetUnit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(MultiTargetObjectRef.ObjectID));

		if (MultiTargetUnit != None)
		{
			AbilityContext.ResultContext.ProjectileHitLocations.AddItem(World.GetPositionFromTileCoordinates(MultiTargetUnit.TileLocation));
		}
	}

	`LOG("JSRC: projectile hit locations" @ AbilityContext.ResultContext.ProjectileHitLocations.Length);
}

static function XComGameState RelayedShot_BuildGameState(XComGameStateContext Context)
{
	local XComGameState GameState;
	local XComGameStateContext_Ability AbilityContext;
	local XComGameState_Ability AbilityState;
	local XComGameState_Item SourceWeapon;

	local X2AbilityTemplate AbilityTemplate;
	local X2AmmoTemplate AmmoTemplate;

	`LOG("JSRC: building gamestate");

	// TypicalAbility_BuildGameState is so close, but it doesn't apply ammo effects to multitargets, even if bAllowAmmoEffects is true
	GameState = TypicalAbility_BuildGameState(Context);

	`LOG("JSRC: original gamestate built");

	// need to get the relayed shot ability so we can look at the weapon for ammo
	AbilityContext = XComGameStateContext_Ability(GameState.GetContext());
	AbilityState = XComGameState_Ability(GameState.GetGameStateForObjectID(AbilityContext.InputContext.AbilityRef.ObjectID));	
	AbilityTemplate = AbilityState.GetMyTemplate();
	SourceWeapon = AbilityState.GetSourceWeapon();

	`LOG("JSRC: ability template allows ammo" @ AbilityTemplate.bAllowAmmoEffects);
	`LOG("JSRC: SourceWeapon has loaded ammo" @ SourceWeapon.HasLoadedAmmo());

	if (AbilityTemplate.bAllowAmmoEffects && SourceWeapon != none && SourceWeapon.HasLoadedAmmo())
	{
		`LOG("JSRC: source weapon has ammo");
		`LOG("JSRC: source weapon has ammo");
		`LOG("JSRC: source weapon has ammo");

		AmmoTemplate = X2AmmoTemplate(SourceWeapon.GetLoadedAmmoTemplate(AbilityState));
		if (AmmoTemplate != none && AmmoTemplate.TargetEffects.Length > 0)
		{
			`LOG("JSRC: ammo template is ready to rock");
		}
	}

	return GameState;
}

defaultproperties
{
    NAME_RELAYED_SHOT=Jammerware_JSRC_Ability_RelayedShot
}