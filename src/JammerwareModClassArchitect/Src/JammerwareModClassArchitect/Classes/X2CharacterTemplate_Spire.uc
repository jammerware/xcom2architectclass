class X2CharacterTemplate_Spire extends X2CharacterTemplate;

function XComGameState_Unit CreateInstanceFromTemplate(XComGameState NewGameState)
{
	local JsrcGameState_SpireUnit Unit;

	Unit = JsrcGameState_SpireUnit(NewGameState.CreateNewStateObject(class'JsrcGameState_SpireUnit', self));

	return Unit;
}

DefaultProperties
{
    // general stuff
    strTargetIconImage="Jammerware_JSRC.TargetIcons.target_icon_spire"
    BehaviorClass=class'XGAIBehavior'
    bAppearanceDefinesPawn=false
    bSkipDefaultAbilities=true
    UnitSize=1

    // traversal Rules
    bBlocksPathingWhenDead=false
    bCanUse_eTraversal_Normal=true
	bCanUse_eTraversal_ClimbOver=true
	bCanUse_eTraversal_ClimbOnto=true
	bCanUse_eTraversal_ClimbLadder=true
	bCanUse_eTraversal_DropDown = true
	bCanUse_eTraversal_Grapple=false
	bCanUse_eTraversal_Landing=true
	bCanUse_eTraversal_BreakWindow=true
	bCanUse_eTraversal_KickDoor=true
	bCanUse_eTraversal_JumpUp=false
	bCanUse_eTraversal_WallClimb=false
	bCanUse_eTraversal_BreakWall=false

    // unit properties
	bIsAlien=false
	bIsAdvent=false
	bIsCivilian=false
	bIsPsionic=false
	bIsRobotic=true
	bIsSoldier=false
	bIsTurret=true

    // vision
    bDisablePodRevealMovementChecks=true
    VisionArcDegrees=360

    // combat
    bCanBeCriticallyWounded=false
    bCanTakeCover=false
    bIsAfraidOfFire=false
	
    // spawning
    bCanBeTerrorist=false
	bAllowSpawnFromATT=false
}