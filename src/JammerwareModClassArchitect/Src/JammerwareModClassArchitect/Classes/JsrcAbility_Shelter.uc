class JsrcAbility_Shelter extends X2Ability
    config(JammerwareModClassArchitect);

var string ICON_SHELTER;
var name NAME_SHELTER;
var name NAME_SPIRE_SHELTER;

var config int SHELTER_DURATION;

public static function array<X2DataTemplate> CreateTemplates()
{
    local array<X2DataTemplate> Templates;
    
    Templates.AddItem(CreateShelter());
    Templates.AddItem(CreateSpireShelter());

    return Templates;
}

private static function X2AbilityTemplate CreateShelter()
{
	return PurePassive(default.NAME_SHELTER, default.ICON_SHELTER);
}

private static function X2AbilityTemplate CreateSpireShelter()
{
	local X2AbilityTemplate Template;
	local X2AbilityTrigger_EventListener TurnEndTrigger;
	local X2Effect_ShelterShield ShieldEffect;
	local X2Condition_AllyAdjacency AllyAdjacencyCondition;
	local X2Condition_UnitProperty PropertyCondition;
	local X2Condition_IsSpire IsSpireCondition;
	local X2Condition_SpireAbilityCondition SpireAbilityCondition;

	`CREATE_X2ABILITY_TEMPLATE(Template, default.NAME_SPIRE_SHELTER);

	// hud behavior
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.IconImage = default.ICON_SHELTER;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_CORPORAL_PRIORITY;

	// uses the forge of either the architect or the spire with the skill
	Template.DefaultSourceItemSlot = eInvSlot_SecondaryWeapon;

	// targeting
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityMultiTargetStyle = new class'X2AbilityMultiTargetStyle_PBAoE';

	// hit chance
	Template.AbilityToHitCalc = default.DeadEye;

	// concealment and tactical behavior
	Template.ConcealmentRule = eConceal_Always;

	// conditions
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	SpireAbilityCondition = new class'X2Condition_SpireAbilityCondition';
	SpireAbilityCondition.RequiredArchitectAbility = default.NAME_SHELTER;
	Template.AbilityShooterConditions.AddItem(SpireAbilityCondition);
	
	// the ability can only go off if there's an adjacent ally, and since spires can't receive shelter, they don't trigger it
	AllyAdjacencyCondition = new class'X2Condition_AllyAdjacency';
	AllyAdjacencyCondition.ExcludeAllyCharacterGroup = class'X2Character_Spire'.default.NAME_CHARACTERGROUP_SPIRE;
	Template.AbilityShooterConditions.AddItem(AllyAdjacencyCondition);
	
	// multitarget valid targets are friendly squadmates
	PropertyCondition = new class'X2Condition_UnitProperty';
	PropertyCondition.ExcludeFriendlyToSource = false;
	PropertyCondition.ExcludeHostileToSource = true;
	PropertyCondition.RequireSquadmates = true;
	Template.AbilityMultiTargetConditions.AddItem(PropertyCondition);

	// can't apply to spires for gameplay clarity (damage is supposed to be basically irrelevant to spires)
	IsSpireCondition = new class'X2Condition_IsSpire';
	IsSpireCondition.IsNegated = true;
	Template.AbilityMultiTargetConditions.AddItem(IsSpireCondition);

	// trigger
	TurnEndTrigger = new class'X2AbilityTrigger_EventListener';
	TurnEndTrigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	TurnEndTrigger.ListenerData.EventID = 'PlayerTurnEnded';
	TurnEndTrigger.ListenerData.Filter = eFilter_Player;
	TurnEndTrigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	Template.AbilityTriggers.AddItem(TurnEndTrigger);

	// effects
	ShieldEffect = new class'X2Effect_ShelterShield';
	ShieldEffect.BuildPersistentEffect(default.SHELTER_DURATION, false, true, , eGameRule_PlayerTurnBegin);
	ShieldEffect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.GetMyLongDescription(), "img:///UILibrary_PerkIcons.UIPerk_adventshieldbearer_energyshield", true);
	Template.AddMultiTargetEffect(ShieldEffect);

	// game state and visualization
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bShowActivation = true;
	Template.bSkipFireAction = true;

	return Template;
}

DefaultProperties
{
    ICON_SHELTER="img:///UILibrary_PerkIcons.UIPerk_adventshieldbearer_energyshield"
	NAME_SHELTER=Jammerware_JSRC_Ability_Shelter
	NAME_SPIRE_SHELTER=Jammerware_JSRC_Ability_SpireShelter
}