class X2Character_Spire extends X2Character config(JammerwareModClassArchitect);

var name NAME_CHARACTER_SPIRE_CONVENTIONAL;
var name NAME_CHARACTER_SPIRE_MAGNETIC;
var name NAME_CHARACTER_SPIRE_BEAM;
var name NAME_CHARACTERGROUP_SPIRE;

static function array<X2DataTemplate> CreateTemplates()
{
    local array<X2DataTemplate> Templates;

    Templates.AddItem(CreateSpire_Conventional());
	Templates.AddItem(CreateSpire_Magnetic());
	Templates.AddItem(CreateSpire_Beam());

    return Templates;
}

static function X2CharacterTemplate CreateSpire_Conventional()
{
	local X2CharacterTemplate Template;

	Template = CreateDefaultSpire(default.NAME_CHARACTER_SPIRE_CONVENTIONAL);
	Template.DefaultLoadout='Jammerware_JSRC_Loadout_Spire_Conventional';

	return Template;
}

static function X2CharacterTemplate CreateSpire_Magnetic()
{
	local X2CharacterTemplate Template;

	Template = CreateDefaultSpire(default.NAME_CHARACTER_SPIRE_MAGNETIC);
	Template.DefaultLoadout='Jammerware_JSRC_Loadout_Spire_Magnetic';

	return Template;
}

static function X2CharacterTemplate CreateSpire_Beam()
{
	local X2CharacterTemplate Template;

	Template = CreateDefaultSpire(default.NAME_CHARACTER_SPIRE_BEAM);
	Template.DefaultLoadout='Jammerware_JSRC_Loadout_Spire_Beam';

	return Template;
}

private static function X2CharacterTemplate CreateDefaultSpire(name TemplateName)
{
	local X2CharacterTemplate CharTemplate;

	`CREATE_X2CHARACTER_TEMPLATE(CharTemplate, TemplateName);
	CharTemplate.CharacterGroupName = default.NAME_CHARACTERGROUP_SPIRE;
	CharTemplate.BehaviorClass = class'XGAIBehavior';
    CharTemplate.strPawnArchetypes.AddItem("GameUnit_LostTowersTurret.ARC_GameUnit_LostTowersTurretM1");

	// Traversal Rules
	CharTemplate.bCanUse_eTraversal_Normal = true;
	CharTemplate.bCanUse_eTraversal_ClimbOver = true;
	CharTemplate.bCanUse_eTraversal_ClimbOnto = true;
	CharTemplate.bCanUse_eTraversal_ClimbLadder = true;
	CharTemplate.bCanUse_eTraversal_DropDown = true;
	CharTemplate.bCanUse_eTraversal_Grapple = false;
	CharTemplate.bCanUse_eTraversal_Landing = true;
	CharTemplate.bCanUse_eTraversal_BreakWindow = true;
	CharTemplate.bCanUse_eTraversal_KickDoor = true;
	CharTemplate.bCanUse_eTraversal_JumpUp = false;
	CharTemplate.bCanUse_eTraversal_WallClimb = false;
	CharTemplate.bCanUse_eTraversal_BreakWall = false;
	CharTemplate.bAppearanceDefinesPawn = false;
	CharTemplate.bCanTakeCover = false;
	CharTemplate.bBlocksPathingWhenDead = false;

	CharTemplate.bIsAlien = false;
	CharTemplate.bIsAdvent = false;
	CharTemplate.bIsCivilian = false;
	CharTemplate.bIsPsionic = false;
	CharTemplate.bIsRobotic = true;
	CharTemplate.bIsSoldier = false;
	CharTemplate.bIsTurret = true;

	CharTemplate.UnitSize = 1;
	CharTemplate.VisionArcDegrees = 360;

	CharTemplate.bCanBeTerrorist = false;
	CharTemplate.bCanBeCriticallyWounded = false;
	CharTemplate.bIsAfraidOfFire = false;

	CharTemplate.bAllowSpawnFromATT = false;
	CharTemplate.bSkipDefaultAbilities = true;
	CharTemplate.bBlocksPathingWhenDead = true;

	CharTemplate.ImmuneTypes.AddItem('Fire');
	CharTemplate.ImmuneTypes.AddItem('Poison');
	CharTemplate.ImmuneTypes.AddItem(class'X2Item_DefaultDamageTypes'.default.ParthenogenicPoisonType);
	CharTemplate.ImmuneTypes.AddItem('Panic');

	CharTemplate.strTargetIconImage = "Jammerware_JSRC.TargetIcons.target_icon_spire";
	CharTemplate.bDisablePodRevealMovementChecks = true;
	CharTemplate.Abilities.AddItem(class'X2Ability_RunnerAbilitySet'.default.NAME_LOAD_PERK_CONTENT);

    return CharTemplate;
}

DefaultProperties
{
	NAME_CHARACTER_SPIRE_CONVENTIONAL=Jammerware_JSRC_Character_Spire_Conventional
	NAME_CHARACTER_SPIRE_MAGNETIC=Jammerware_JSRC_Character_Spire_Magnetic
	NAME_CHARACTER_SPIRE_BEAM=Jammerware_JSRC_Character_Spire_Beam
	NAME_CHARACTERGROUP_SPIRE=Jammerware_JSRC_CharacterGroup_Spire
}