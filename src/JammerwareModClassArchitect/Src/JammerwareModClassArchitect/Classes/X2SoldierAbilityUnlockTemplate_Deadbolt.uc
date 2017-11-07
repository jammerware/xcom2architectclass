class X2SoldierABilityUnlockTemplate_Deadbolt extends X2StrategyElement;

var name NAME_DEADBOLT;

static function array <X2DataTemplate> CreateTemplates()
{
    local array<X2DataTemplate> Templates;
    Templates.AddItem(CreateDeadboltUnlock());
    return Templates;
}

private static function X2SoldierAbilityUnlockTemplate CreateDeadboltUnlock()
{
    local X2SoldierAbilityUnlockTemplate Template;
	local ArtifactCost Resources;

	`CREATE_X2TEMPLATE(class'X2SoldierAbilityUnlockTemplate', Template, default.NAME_DEADBOLT);

	Template.AllowedClasses.AddItem('Jammerware_JSRC_Class_Architect');
	Template.AbilityName = 'Jammerware_JSRC_Ability_Deadbolt';
	Template.strImage = "img:///Jammerware_JSRC.gts_perk";

	// Requirements
	Template.Requirements.RequiredHighestSoldierRank = 5;
	Template.Requirements.RequiredSoldierClass = 'Jammerware_JSRC_Class_Architect';
	Template.Requirements.RequiredSoldierRankClassCombo = true;
	Template.Requirements.bVisibleIfSoldierRankGatesNotMet = true;

	// Cost
	Resources.ItemTemplateName = 'Supplies';
	Resources.Quantity = 75;
	Template.Cost.ResourceCosts.AddItem(Resources);
	
	return Template;
}

defaultproperties
{
	NAME_DEADBOLT=Jammerware_JSRC_AbilityUnlock_Deadbolt
}