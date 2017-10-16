class X2Ability_SpireShelter extends X2Ability;

var name NAME_SPIRE_SHELTER;

static function X2AbilityTemplate CreateSpireShelter()
{
	local X2AbilityTemplate Template;
	local X2AbilityTrigger_EventListener TurnEndTrigger;
	local X2Effect_ShelterShield ShieldEffect;
	local X2Condition_UnitEffects EffectsCondition;
	local X2Condition_UnitProperty PropertyCondition;

	`CREATE_X2ABILITY_TEMPLATE(Template, default.NAME_SPIRE_SHELTER);

	// hud behavior
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_adventshieldbearer_energyshield";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_CORPORAL_PRIORITY;

	// targeting
	Template.AbilityTargetStyle = default.SimpleSingleTarget;

	// hit chance
	Template.AbilityToHitCalc = default.DeadEye;

	// conditions
	EffectsCondition = new class'X2Condition_UnitEffects';
	EffectsCondition.AddExcludeEffect(class'X2Effect_ShelterShield'.default.EffectName, 'AA_DuplicateEffectIgnored');
	Template.AbilityTargetConditions.AddItem(EffectsCondition);

	PropertyCondition = new class'X2Condition_UnitProperty';
	PropertyCondition.ExcludeFriendlyToSource = false;
	PropertyCondition.ExcludeHostileToSource = true;
	PropertyCondition.RequireSquadmates = true;
	PropertyCondition.RequireWithinRange = true;
	PropertyCondition.WithinRange = `METERSTOUNITS(class'XComWorldData'.const.WORLD_Melee_Range_Meters);
	Template.AbilityTargetConditions.AddItem(PropertyCondition);

	// trigger
	TurnEndTrigger = new class'X2AbilityTrigger_EventListener';
	TurnEndTrigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	TurnEndTrigger.ListenerData.EventID = 'PlayerTurnEnded';
	TurnEndTrigger.ListenerData.Filter = eFilter_None;
	TurnEndTrigger.ListenerData.EventFn = Shelter_ProximityListener;
	Template.AbilityTriggers.AddItem(TurnEndTrigger);

	// effects
	ShieldEffect = new class'X2Effect_ShelterShield';
	// TODO: enable config and weapon-based computation for shield strength and duration
	ShieldEffect.BuildPersistentEffect(2, false, true, , eGameRule_PlayerTurnBegin);
	ShieldEffect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.GetMyLongDescription(), "img:///UILibrary_PerkIcons.UIPerk_adventshieldbearer_energyshield", true);
	ShieldEffect.AddPersistentStatChange(eStat_ShieldHP, 3);
	Template.AddTargetEffect(ShieldEffect);

	// game state and visualization
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bShowActivation = true;

	return Template;
}

static function EventListenerReturn Shelter_ProximityListener(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
    local Jammerware_ProximityService ProximityService;
    local XComGameStateHistory History;
    local XComGameState_Unit UnitState;
    local XComGameState_Unit SpireState;
    local XComGameState_Ability AbilityState;
    local array<XComGameState_Unit> SoldierStates;
    local array<XComGameState_Unit> SpireStates;

    History = `XCOMHISTORY;
    ProximityService = new class'Jammerware_ProximityService';
    AbilityState = XComGameState_Ability(CallbackData);

    if (AbilityState == none)
    {
        `REDSCREEN("JSRC: Shelter_ProximityListener - Callback data wasn't an ability state." @ Callbackdata.name);
    }

    foreach History.IterateByClassType(class'XComGameState_Unit', UnitState)
	{
		if(UnitState.GetMyTemplateName() == class'X2Character_Spire'.default.NAME_CHARACTER_SPIRE)
		{
            SpireStates.AddItem(UnitState);
		}
        else if (UnitState.GetMyTemplateName() == 'Soldier')
        {
            SoldierStates.AddItem(UnitState);
        }
	}

    foreach SoldierStates(UnitState)
    {
        foreach SpireStates(SpireState)
        {
            if (ProximityService.AreAdjacent(UnitState, SpireState))
            {
                AbilityState.AbilityTriggerAgainstSingleTarget(UnitState.GetReference(), false);
                continue;
            }
        }
    }

    return ELR_NoInterrupt;
}

defaultproperties
{
	NAME_SPIRE_SHELTER=Jammerware_JSRC_Ability_SpireShelter
}