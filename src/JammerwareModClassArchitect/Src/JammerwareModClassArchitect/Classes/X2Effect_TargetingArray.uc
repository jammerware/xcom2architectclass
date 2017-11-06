class X2Effect_TargetingArray extends X2Effect_Persistent;

// i have no idea why i can't get this from the ability template in VisualizeTargetingArray, but it's empty string there :/
var string FlyoverText;
var string RemovedFlyoverText;
// the icon isn't available during effect removed, so i'm just tossing that on here as well :/
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
	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectGameState.ApplyEffectParameters.SourceStateObjectRef.ObjectID));

	// the source of this effect is the soldier who has Targeting Array. if they move, check to remove it
	EventMgr.RegisterForEvent(EffectObj, 'UnitMoveFinished', OnUnitMoved, ELD_OnStateSubmitted, , UnitState, , EffectObj);
	// if any unit dies, check to make sure the soldier is still next to a spire
	EventMgr.RegisterForEvent(EffectObj, 'UnitDied', OnUnitMoved, ELD_OnStateSubmitted, , , , EffectObj);
}

simulated function VisualizeTargetingArray(XComGameState VisualizeGameState, out VisualizationActionMetadata ModifyTrack, const name EffectApplyResult)
{
	if (EffectApplyResult == 'AA_Success')
	{
		class'X2StatusEffects'.static.AddEffectSoundAndFlyOverToTrack(ModifyTrack, VisualizeGameState.GetContext(), self.FlyoverText, '', eColor_Good, self.FlyoverIcon);
		class'X2StatusEffects'.static.UpdateUnitFlag(ModifyTrack, VisualizeGameState.GetContext());
	}
}

simulated function VisualizeTargetingArrayRemoved(XComGameState VisualizeGameState, out VisualizationActionMetadata ModifyTrack, const name EffectApplyResult)
{
	if (EffectApplyResult == 'AA_Success')
	{
		class'X2StatusEffects'.static.AddEffectSoundAndFlyOverToTrack(ModifyTrack, VisualizeGameState.GetContext(), self.RemovedFlyoverText, '', eColor_Bad, FlyoverIcon);
		class'X2StatusEffects'.static.UpdateUnitFlag(ModifyTrack, VisualizeGameState.GetContext());
	}
}

static function EventListenerReturn OnUnitMoved(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComGameState_Effect EffectState;
	local XComGameState_Unit UnitState;
	local XComGameStateContext_EffectRemoved RemoveContext;
	local XComGameState NewGameState;
	local Jammerware_JSRC_ProximityService ProximityService;

	ProximityService = new class'Jammerware_JSRC_ProximityService';
	EffectState = XComGameState_Effect(CallbackData);
	UnitState = XComGameState_Unit(GameState.GetGameStateForObjectID(EffectState.ApplyEffectParameters.TargetStateObjectRef.ObjectID));

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
	DuplicateResponse=eDupe_Ignore
    EffectName=Jammerware_JSRC_Effect_TargetingArray
	VisualizationFn=VisualizeTargetingArray
	EffectRemovedVisualizationFn=VisualizeTargetingArrayRemoved
}