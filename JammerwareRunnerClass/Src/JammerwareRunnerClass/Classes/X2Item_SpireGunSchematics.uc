class X2Item_SpireGunSchematics extends X2Item;

var name NAME_SPIREGUN_SCHEMATIC_MAGNETIC;
var name NAME_SPIREGUN_SCHEMATIC_BEAM;

static function array<X2DataTemplate> CreateTemplates()
{
    local array<X2DataTemplate> Templates;

    Templates.AddItem(CreateSpireGunSchematic_Magnetic());
    Templates.AddItem(CreateSpireGunSchematic_Beam());

    return Templates;
}

static function X2DataTemplate CreateSpireGunSchematic_Magnetic()
{
    local X2SchematicTemplate Template;
	local ArtifactCost Resources;

	`CREATE_X2TEMPLATE(class'X2SchematicTemplate', Template, default.NAME_SPIREGUN_SCHEMATIC_MAGNETIC);

	Template.ItemCat = 'weapon';
	Template.strImage = "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_Psi_AmpMK2";
	Template.PointsToComplete = 0;
	Template.Tier = 2;
	Template.OnBuiltFn = UpgradeItems;

	// Reference Item
	Template.ReferenceItemTemplate = class'X2Item_SpireGun'.default.NAME_SPIREGUN_MAGNETIC;
	Template.HideIfPurchased = class'X2Item_SpireGun'.default.NAME_SPIREGUN_BEAM;

	// Requirements
	Template.Requirements.RequiredTechs.AddItem('MagnetizedWeapons');
	Template.Requirements.RequiredEngineeringScore = 15;
	Template.Requirements.bVisibleIfPersonnelGatesNotMet = true;

	// Cost
	Resources.ItemTemplateName = 'Supplies';
	Resources.Quantity = 25;
	Template.Cost.ResourceCosts.AddItem(Resources);

	Resources.ItemTemplateName = 'EleriumDust';
	Resources.Quantity = 5;
	Template.Cost.ResourceCosts.AddItem(Resources);

	Resources.ItemTemplateName = 'AlienAlloy';
	Resources.Quantity = 5;
	Template.Cost.ResourceCosts.AddItem(Resources);

	return Template;
}

static function X2DataTemplate CreateSpireGunSchematic_Beam()
{
    local X2SchematicTemplate Template;
	local ArtifactCost Resources;

	`CREATE_X2TEMPLATE(class'X2SchematicTemplate', Template, default.NAME_SPIREGUN_SCHEMATIC_BEAM);

	Template.ItemCat = 'weapon';
	Template.strImage = "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_Psi_AmpMK3";
	Template.PointsToComplete = 0;
	Template.Tier = 4;
	Template.OnBuiltFn = UpgradeItems;

	// Reference Item
	Template.ReferenceItemTemplate = class'X2Item_SpireGun'.default.NAME_SPIREGUN_BEAM;

	// Requirements
	Template.Requirements.RequiredTechs.AddItem('PlasmaRifle');
	Template.Requirements.RequiredEngineeringScore = 20;
	Template.Requirements.bVisibleIfPersonnelGatesNotMet = true;

	// Cost
	Resources.ItemTemplateName = 'Supplies';
	Resources.Quantity = 50;
	Template.Cost.ResourceCosts.AddItem(Resources);

	Resources.ItemTemplateName = 'AlienAlloy';
	Resources.Quantity = 10;
	Template.Cost.ResourceCosts.AddItem(Resources);

	Resources.ItemTemplateName = 'EleriumDust';
	Resources.Quantity = 10;
	Template.Cost.ResourceCosts.AddItem(Resources);

	return Template;
}

static function UpgradeItems(XComGameState NewGameState, XComGameState_Item ItemState)
{
	class'XComGameState_HeadquartersXCom'.static.UpgradeItems(NewGameState, ItemState.GetMyTemplateName());
}

defaultproperties
{
    NAME_SPIREGUN_SCHEMATIC_MAGNETIC=Jammerware_JSRC_Item_SpireGun_Magnetic_Schematic
    NAME_SPIREGUN_SCHEMATIC_BEAM=Jammerware_JSRC_Item_SpireGun_Beam_Schematic
}