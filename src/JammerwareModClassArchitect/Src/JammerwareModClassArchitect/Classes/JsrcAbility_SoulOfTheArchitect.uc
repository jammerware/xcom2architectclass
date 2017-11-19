class JsrcAbility_SoulOfTheArchitect extends X2Ability;

var name NAME_ABILITY;

public static function array<X2DataTemplate> CreateTemplates()
{
    local array<X2DataTemplate> Templates;
    Templates.AddItem(CreateSoulOfTheArchitect());
    return Templates;
}

private static function X2AbilityTemplate CreateSoulOfTheArchitect()
{
	local X2AbilityTemplate Template;
	local X2Effect_GenerateCover GenerateCoverEffect;
	local X2Effect_Persistent PersistentEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, default.NAME_ABILITY);

	Template.IconImage = "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_Pillar";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	
	// targeting and ability to hit
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityToHitCalc = default.DeadEye;

	// triggering
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	GenerateCoverEffect = new class'X2Effect_GenerateCover';
	GenerateCoverEffect.BuildPersistentEffect(1, true, false);
	GenerateCoverEffect.bRemoveWhenMoved = false;
	GenerateCoverEffect.bRemoveOnOtherActivation = false;
	Template.AddTargetEffect(GenerateCoverEffect);

	PersistentEffect = new class'X2Effect_Persistent';
	PersistentEffect.BuildPersistentEffect(1, true, false);
	PersistentEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,, Template.AbilitySourceName);
	Template.AddTargetEffect(PersistentEffect);

	Template.AdditionalAbilities.AddItem(class'JsrcAbility_TargetingArray'.default.NAME_TARGETING_ARRAY_SPIRE);
	Template.AdditionalAbilities.AddItem(class'JsrcAbility_Shelter'.default.NAME_SPIRE_SHELTER);
	Template.AdditionalAbilities.AddItem(class'JsrcAbility_Quicksilver'.default.NAME_SPIRE_QUICKSILVER);
	Template.AdditionalAbilities.AddItem(class'JsrcAbility_KineticRigging'.default.NAME_KINETIC_BLAST);
	Template.AdditionalAbilities.AddItem(class'JsrcAbility_TransmatNetwork'.default.NAME_SPIRETRANSMATNETWORK);

	Template.bSkipFireAction = true;
	Template.bShowActivation = true;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	return Template;
}

DefaultProperties
{
    NAME_ABILITY=Jammerware_JSRC_Ability_SoulOfTheArchitect
}