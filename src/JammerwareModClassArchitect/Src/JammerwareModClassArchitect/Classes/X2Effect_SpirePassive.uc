class X2Effect_SpirePassive extends X2Effect_GenerateCover;

function ModifyTurnStartActionPoints(XComGameState_Unit UnitState, out array<name> ActionPoints, XComGameState_Effect EffectState)
{
    ActionPoints.Length = 0;
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

	// if the spire dies, we need to clean up its cover
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

	// submit it and quit it
	`TACTICALRULES.SubmitGameState(NewGameState);
	return ELR_NoInterrupt;
}

DefaultProperties
{
	CoverType = CoverForce_High
	DuplicateResponse = eDupe_Ignore
	EffectName=Jammerware_JSRC_Effect_SpirePassive
	bRemoveWhenMoved = false
	bRemoveOnOtherActivation = false
}