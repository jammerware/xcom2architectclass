class JsrcAbility_SpirePassive extends X2Ability;

var name NAME_ABILITY;

public static function array<X2DataTemplate> CreateTemplates()
{
    local array<X2DataTemplate> Templates;
    Templates.AddItem(CreateSpirePassive());
    return Templates;
}

private static function X2DataTemplate CreateSpirePassive()
{
    local X2AbilityTemplate Template;
	local JsrcEffect_SpirePassive SpirePassiveEffect;

	// general properties
	`CREATE_X2ABILITY_TEMPLATE(Template, default.NAME_ABILITY);
	Template.Hostility = eHostility_Neutral;

	// hud behavior
	Template.IconImage = "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_volt";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_SQUADDIE_PRIORITY;
    
	// targeting and chance to hit
	Template.AbilityTargetStyle = default.SelfTarget;
    Template.AbilityToHitCalc = default.Deadeye;
	
	// triggering
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	
	// effects
	SpirePassiveEffect = new class'JsrcEffect_SpirePassive';
	SpirePassiveEffect.BuildPersistentEffect(1, true, false);
	SpirePassiveEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage,,,Template.AbilitySourceName);
	Template.AddTargetEffect(SpirePassiveEffect);

	// game state and visualization
	Template.bShowActivation = false;
    Template.bSkipFireAction = true;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;
}

DefaultProperties
{
    NAME_ABILITY=Jammerware_JSRC_Ability_SpirePassive
}