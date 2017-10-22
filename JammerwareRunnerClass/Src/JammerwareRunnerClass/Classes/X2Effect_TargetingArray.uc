class X2Effect_TargetingArray extends X2Effect_Persistent;

function GetToHitModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
	local ShotModifierInfo AccuracyInfo;

	AccuracyInfo.ModType = eHit_Success;
	AccuracyInfo.Value = 20;
	AccuracyInfo.Reason = FriendlyName;
	ShotModifiers.AddItem(AccuracyInfo);
}

function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local X2EventManager EventMgr;
	local XComGameState_Unit UnitState;
	local Object EffectObj;

	EventMgr = `XEVENTMGR;
	EffectObj = EffectGameState;
	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectGameState.ApplyEffectParameters.SourceStateObjectRef.ObjectID));

	EventMgr.RegisterForEvent
	(
		EffectObj, 
		'UnitMoveFinished', 
		OnUnitMoved, 
		ELD_OnStateSubmitted, 
		, 
		UnitState,
		,
		EffectGameState
	);
}

static function EventListenerReturn OnUnitMoved(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComGameState_Unit UnitState;
	local XComGameState_Effect EffectState;
	local XComGameStateContext_EffectRemoved RemoveContext;
	local XComGameState NewGameState;
	local Jammerware_ProximityService ProximityService;

	ProximityService = new class'Jammerware_ProximityService';
	EffectState = XComGameState_Effect(CallbackData);
	UnitState = XComGameState_Unit(EventData);
	
	if (!EffectState.bRemoved && !ProximityService.IsUnitAdjacentToSpire(UnitState))
	{
		RemoveContext = class'XComGameStateContext_EffectRemoved'.static.CreateEffectRemovedContext(EffectState);
		NewGameState = `XCOMHISTORY.CreateNewGameState(true, RemoveContext);
		EffectState.RemoveEffect(NewGameState, GameState);
		`TACTICALRULES.SubmitGameState(NewGameState);
	}

	return ELR_NoInterrupt;
}

defaultproperties
{
    EffectName=Jammerware_JSRC_Effect_TargetingArray
}