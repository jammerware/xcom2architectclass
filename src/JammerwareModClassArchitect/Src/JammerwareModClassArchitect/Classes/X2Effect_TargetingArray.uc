class X2Effect_TargetingArray extends X2Effect_Persistent;

var string FlyoverText;
var string RemovedFlyoverText;
var string FlyoverIcon;

function GetToHitModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
	local ShotModifierInfo AccuracyInfo;
	local XComGameState_Item WeaponState;
	local X2WeaponTemplate_SpireGun WeaponTemplate;

	WeaponState = XComGameState_Item(`XCOMHISTORY.GetGameStateForObjectID(EffectState.ApplyEffectParameters.ItemStateObjectRef.ObjectID));
	WeaponTemplate = X2WeaponTemplate_SpireGun(WeaponState.GetMyTemplate());

	AccuracyInfo.ModType = eHit_Success;
	AccuracyInfo.Value = WeaponTemplate.TargetingArrayAccuracyBonus;
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
	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectGameState.ApplyEffectParameters.TargetStateObjectRef.ObjectID));

	// if the target moves, check to remove the effect
	EventMgr.RegisterForEvent(EffectObj, 'UnitMoveFinished', OnUnitMovedOrDied, ELD_OnStateSubmitted, , UnitState, , EffectObj);
	// if any unit dies, check to make sure the soldier is still next to a spire
	EventMgr.RegisterForEvent(EffectObj, 'UnitDied', OnUnitMovedOrDied, ELD_OnStateSubmitted, , , , EffectObj);
}

simulated function AddX2ActionsForVisualization(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata, const name EffectApplyResult)
{
	local XComGameState_Unit TargetState;

	// respect our elders
	super.AddX2ActionsForVisualization(VisualizeGameState, ActionMetadata, EffectApplyResult);

	TargetState = XComGameState_Unit(VisualizeGameState.GetGameStateForObjectID(ActionMetadata.StateObject_NewState.ObjectID));
	if (TargetState == none)
		return;

	if (EffectApplyResult == 'AA_Success')
	{
		class'X2StatusEffects'.static.AddEffectSoundAndFlyOverToTrack(ActionMetadata, VisualizeGameState.GetContext(), self.FlyoverText, '', eColor_Good, self.FlyoverIcon);
		class'X2StatusEffects'.static.UpdateUnitFlag(ActionMetadata, VisualizeGameState.GetContext());
	}
}

simulated function AddX2ActionsForVisualization_Removed(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata, const name EffectApplyResult, XComGameState_Effect RemovedEffect)
{
	local XComGameState_Unit TargetState;

	// respect our elders
	super.AddX2ActionsForVisualization(VisualizeGameState, ActionMetadata, EffectApplyResult);

	TargetState = XComGameState_Unit(VisualizeGameState.GetGameStateForObjectID(ActionMetadata.StateObject_NewState.ObjectID));
	if (TargetState == none)
		return;

	if (EffectApplyResult == 'AA_Success')
	{
		class'X2StatusEffects'.static.AddEffectSoundAndFlyOverToTrack(ActionMetadata, VisualizeGameState.GetContext(), self.RemovedFlyoverText, '', eColor_Bad, FlyoverIcon);
		class'X2StatusEffects'.static.UpdateUnitFlag(ActionMetadata, VisualizeGameState.GetContext());
	}
}

private static function EventListenerReturn OnUnitMovedOrDied(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComGameState_Effect EffectState;
	local XComGameState_Unit UnitState;
	local XComGameState NewGameState;
	local XComGameStateContext_EffectRemoved RemoveContext;
	local Jammerware_JSRC_ProximityService ProximityService;

	EffectState = XComGameState_Effect(CallbackData);
	// if we only cared about move finished, we could use the event data instead of the history lookup to find the target, but on unit died, the event data is the dead unit
	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectState.ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	ProximityService = new class'Jammerware_JSRC_ProximityService';

	if (UnitState != none && !EffectState.bRemoved && !ProximityService.IsUnitAdjacentToAlly(UnitState, class'X2Ability_TargetingArray'.default.NAME_TARGETING_ARRAY_SPIRE))
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
	DuplicateResponse=eDupe_Ignore
    EffectName=Jammerware_JSRC_Effect_TargetingArray
}