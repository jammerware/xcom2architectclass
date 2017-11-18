class X2Effect_SpirePassive extends X2Effect_GenerateCover;

var name GAMEPLAY_VISIBLE_TAG;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	super.OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);
	kNewTargetState.bRequiresVisibilityUpdate = true;
}

simulated function OnEffectRemoved(const out EffectAppliedData ApplyEffectParameters, XComGameState NewGameState, bool bCleansed, XComGameState_Effect RemovedEffectState)
{
	local XComGameState_Unit Unit;

	super.OnEffectRemoved(ApplyEffectParameters, NewGameState, bCleansed, RemovedEffectState);

	Unit = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	Unit.bRequiresVisibilityUpdate = true;
}

function ModifyTurnStartActionPoints(XComGameState_Unit UnitState, out array<name> ActionPoints, XComGameState_Effect EffectState)
{
    ActionPoints.Length = 0;
}

function ModifyGameplayVisibilityForTarget(out GameRulesCache_VisibilityInfo InOutVisibilityInfo, XComGameState_Unit SourceUnit, XComGameState_Unit TargetUnit)
{
	if( SourceUnit.IsEnemyUnit(TargetUnit) )
	{
		InOutVisibilityInfo.bVisibleGameplay = false;
		InOutVisibilityInfo.GameplayVisibleTags.AddItem(default.GAMEPLAY_VISIBLE_TAG);
	}
}

function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local X2EventManager EventMgr;
	local XComGameState_Unit UnitState;
	local Object EffectObj;

	super.RegisterForEvents(EffectGameState);

	EventMgr = `XEVENTMGR;
	EffectObj = EffectGameState;
	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectGameState.ApplyEffectParameters.TargetStateObjectRef.ObjectID));

	// if the spire dies, we need to clean up its cover and remove it from play
	EventMgr.RegisterForEvent
	(
		EffectObj, 
		'UnitDied', 
		SpirePassive_SpireDied, 
		ELD_OnStateSubmitted,
		, 
		UnitState,
		,
		EffectObj
	);
}

private static function EventListenerReturn SpirePassive_SpireDied(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local XComGameStateContext_EffectRemoved RemoveContext;
	local XComGameState_Effect EffectState;
	local XComGameState_Unit UnitState;
	local XComGameState NewGameState;
	
	// remove the effect from the dead spire
	EffectState = XComGameState_Effect(CallbackData);
	UnitState = XComGameState_Unit(EventSource);
	RemoveContext = class'XComGameStateContext_EffectRemoved'.static.CreateEffectRemovedContext(EffectState);
	NewGameState = `XCOMHISTORY.CreateNewGameState(true, RemoveContext);
	EffectState.RemoveEffect(NewGameState, GameState);

	// update world cover data so the space doesn't provide cover anymore
	UpdateWorldCoverData(UnitState, NewGameState);

	// remove the spire wreck from play
    `XEVENTMGR.TriggerEvent('UnitRemovedFromPlay', UnitState, UnitState, NewGameState);

	// submit it and quit it
	`TACTICALRULES.SubmitGameState(NewGameState);

	return ELR_NoInterrupt;
}

DefaultProperties
{
	CoverType = CoverForce_High
	DuplicateResponse = eDupe_Ignore
	EffectName=Jammerware_JSRC_Effect_SpirePassive
	GAMEPLAY_VISIBLE_TAG=Jammerware_JSRC_GameplayVisibleTag_Spire
	bRemoveWhenMoved = false
	bRemoveOnOtherActivation = false
}