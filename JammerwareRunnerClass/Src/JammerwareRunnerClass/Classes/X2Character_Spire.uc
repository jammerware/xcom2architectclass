class X2Character_Spire extends X2Character config(JammerwareRunnerClass);

static function array<X2DataTemplate> CreateTemplates()
{
    local array<X2DataTemplate> Templates;

    Templates.AddItem(CreateSpire());

    return Templates;
}

static function X2CharacterTemplate CreateSpire()
{
    // TODO: this is lifted from CreateDefaultTurretTemplate in X2Character_DefaultCharacters - make sure this is set up how we want
    local X2CharacterTemplate CharTemplate;

	`CREATE_X2CHARACTER_TEMPLATE(CharTemplate, 'Jammerware_JSRC_Spire');
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
	CharTemplate.bSkipDefaultAbilities = false;
	CharTemplate.bBlocksPathingWhenDead = true;

	CharTemplate.ImmuneTypes.AddItem('Fire');
	CharTemplate.ImmuneTypes.AddItem('Poison');
	CharTemplate.ImmuneTypes.AddItem(class'X2Item_DefaultDamageTypes'.default.ParthenogenicPoisonType);
	CharTemplate.ImmuneTypes.AddItem('Panic');

	CharTemplate.strTargetIconImage = class'UIUtilities_Image'.const.TargetIcon_Turret;

    // TODO: abilities

	CharTemplate.bDisablePodRevealMovementChecks = true;

    return CharTemplate;
}