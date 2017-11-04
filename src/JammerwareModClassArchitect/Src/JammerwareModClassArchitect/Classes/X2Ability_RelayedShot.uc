class X2Ability_RelayedShot extends X2Ability
	config(JammerwareModClassArchitect);

var name NAME_RELAYED_SHOT;
var config int COOLDOWN_RELAYED_SHOT;

static function X2DataTemplate CreateRelayedShot()
{
    local X2AbilityTemplate Template;
	local X2AbilityCooldown Cooldown;
	local X2AbilityMultiTarget_Line MultiTargetStyle;
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
	Cooldown.iNumTurns = default.COOLDOWN_RELAYED_SHOT;
	Template.AbilityCooldown = Cooldown;

	// targeting style (how targets are determined by game rules)
	Template.AbilityTargetStyle = default.SimpleSingleTarget;

	MultiTargetStyle = new class'X2AbilityMultiTarget_Line';
	MultiTargetStyle.TileWidthExtension = 1;
    Template.AbilityMultiTargetStyle = MultiTargetStyle;

	//Template.TargetingMethod = class'X2TargetingMethod_RelayedShot';

	// hit chance
	Template.AbilityToHitCalc = default.DeadEye;

	// conditions
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	UnitTypeCondition = new class'X2Condition_UnitType';
	UnitTypeCondition.IncludeTypes.AddItem(class'X2Character_Spire'.default.NAME_CHARACTERGROUP_SPIRE);
	Template.AbilityTargetConditions.AddItem(UnitTypeCondition);
	Template.AbilityTargetConditions.AddItem(default.GameplayVisibilityCondition);

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
	Template.ModifyNewContextFn = RelayedShot_ModifyActivatedAbilityContext;
	Template.BuildNewGameStateFn = RelayedShot_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	return Template;
}

static function RelayedShot_ModifyActivatedAbilityContext(XComGameStateContext Context)
{
	local XComWorldData World;
	local XComGameStateContext_Ability AbilityContext;
	local StateObjectReference MultiTargetObjectRef;
	local XComGameState_Unit MultiTargetUnit;
	local int i;

	AbilityContext = XComGameStateContext_Ability(Context);
	AbilityContext.ResultContext.ProjectileHitLocations.Length = 0;
	World = `XWORLD;

	for (i = 0; i < AbilityContext.InputContext.MultiTargets.Length; i++)
	{
		MultiTargetObjectRef = AbilityContext.InputContext.MultiTargets[i];
		MultiTargetUnit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(MultiTargetObjectRef.ObjectID));

		if (MultiTargetUnit != None)
		{
			AbilityContext.ResultContext.ProjectileHitLocations.AddItem(World.GetPositionFromTileCoordinates(MultiTargetUnit.TileLocation));
		}
	}
}

// TypicalAbility_BuildGameState is SO CLOSE in this case, but it doesn't seem to respect bAllowAmmoEffects or bAllowBonusWeaponEffects for multitargets.
// we add that handling here
static function XComGameState RelayedShot_BuildGameState(XComGameStateContext Context)
{
	// history and gamestate
	local XComGameStateHistory History;
	local XComGameState GameState;

	// ability and weapon
	local XComGameStateContext_Ability AbilityContext;
	local XComGameState_Ability AbilityState;
	local X2AbilityTemplate AbilityTemplate;
	local X2AmmoTemplate AmmoTemplate;
	local XComGameState_Item Weapon;
	local X2WeaponTemplate WeaponTemplate;

	// ammo and bonus weapon effects to apply
	local array<X2Effect> EffectsToApply;

	// multitarget states
	local XComGameState_BaseObject SourceObject_OriginalState, AffectedTargetObject_OriginalState, AffectedTargetObject_NewState;

	// loop nonsense;
	local StateObjectReference IterMultiTarget;
	local int i;
	local EffectResults MultiTargetEffectResults;
	local X2Effect IterEffect;

	// use TypicalAbility_BuildGameState to get started and load up the history
	GameState = TypicalAbility_BuildGameState(Context);
	History = `XCOMHISTORY;

	// need to get the relayed shot ability so we can look at the weapon for ammo
	AbilityContext = XComGameStateContext_Ability(GameState.GetContext());
	AbilityState = XComGameState_Ability(GameState.GetGameStateForObjectID(AbilityContext.InputContext.AbilityRef.ObjectID));	
	AbilityTemplate = AbilityState.GetMyTemplate();
	Weapon = AbilityState.GetSourceWeapon();
	WeaponTemplate = X2WeaponTemplate(Weapon.GetMyTemplate());

	// gather all effects from ammo or weapon bonuses for potential application
	if (Weapon != none)
	{
		// add ammo effects
		if (AbilityTemplate.bAllowAmmoEffects && Weapon.HasLoadedAmmo())
		{
			AmmoTemplate = X2AmmoTemplate(Weapon.GetLoadedAmmoTemplate(AbilityState));

			if (AmmoTemplate != none && AmmoTemplate.TargetEffects.Length > 0)
			{
				foreach AmmoTemplate.TargetEffects(IterEffect)
				{
					EffectsToApply.AddItem(IterEffect);
				}
			}
		}

		// add bonus effects
		if (AbilityTemplate.bAllowBonusWeaponEffects)
		{
			if (WeaponTemplate != none && WeaponTemplate.BonusWeaponEffects.Length > 0)
			{
				foreach WeaponTemplate.BonusWeaponEffects(IterEffect)
				{
					EffectsToApply.AddItem(IterEffect);
				}
			}
		}
	}

	if (EffectsToApply.Length > 0)
	{
		SourceObject_OriginalState = History.GetGameStateForObjectID(AbilityContext.InputContext.SourceObject.ObjectID);

		for (i = 0; i < AbilityContext.InputContext.MultiTargets.Length; i++)
		{
			IterMultiTarget = AbilityContext.InputContext.MultiTargets[i];
			AffectedTargetObject_OriginalState = History.GetGameStateForObjectID(IterMultiTarget.ObjectID, eReturnType_Reference);
			AffectedTargetObject_NewState = GameState.ModifyStateObject(AffectedTargetObject_OriginalState.Class, IterMultiTarget.ObjectID);
			MultiTargetEffectResults = AbilityContext.ResultContext.MultiTargetEffectResults[i];

			class'X2Ability'.static.ApplyEffectsToTarget
			(
				AbilityContext, 
				AffectedTargetObject_OriginalState, 
				SourceObject_OriginalState, 
				AbilityState, 
				AffectedTargetObject_NewState, 
				GameState, 
				AbilityContext.ResultContext.MultiTargetHitResults[i],
				AbilityContext.ResultContext.MultiTargetArmorMitigation[i],
				AbilityContext.ResultContext.MultiTargetStatContestResult[i],
				EffectsToApply,
				MultiTargetEffectResults,
				AmmoTemplate.DataName,
				TELT_AmmoTargetEffects
			);
			
			`LOG("JSRC:" @ EffectsToApply.Length @ "effects applied to target" @ AffectedTargetObject_NewState.GetMyTemplateName());
		}
	}

	return GameState;
}

defaultproperties
{
    NAME_RELAYED_SHOT=Jammerware_JSRC_Ability_RelayedShot
}