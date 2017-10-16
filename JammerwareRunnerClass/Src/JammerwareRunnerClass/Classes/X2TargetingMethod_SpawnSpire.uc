class X2TargetingMethod_SpawnSpire extends X2TargetingMethod;

var private XCom3DCursor Cursor;
var private bool bRestrictToSquadsightRange;

function Init(AvailableAction InAction, int NewTargetIndex)
{
	local XComGameStateHistory History;
    local XComGameState_Unit SourceUnit;
	local float TargetingRange;
	local X2AbilityTarget_Cursor CursorTarget;

	super.Init(InAction, NewTargetIndex);

	History = `XCOMHISTORY;
    SourceUnit = XComGameState_Unit(History.GetGameStateForObjectID(Ability.OwnerStateObject.ObjectID));
    `LOG("JSRC: Targeting method source unit");
    class'Jammerware_DebugUtils'.static.LogUnitLocation(SourceUnit);

	// determine our targeting range
    // TODO: if the source has Unity, unlock the targeting range so we can target ally-adjacent tiles
	TargetingRange = Ability.GetAbilityCursorRangeMeters();

	// lock the cursor to that range
	Cursor = `Cursor;
	Cursor.m_fMaxChainedDistance = `METERSTOUNITS(TargetingRange);

	CursorTarget = X2AbilityTarget_Cursor(Ability.GetMyTemplate().AbilityTargetStyle);
	if (CursorTarget != none)
		bRestrictToSquadsightRange = CursorTarget.bRestrictToSquadsightRange;
}