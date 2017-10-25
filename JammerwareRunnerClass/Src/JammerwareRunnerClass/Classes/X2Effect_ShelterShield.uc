class X2Effect_ShelterShield extends X2Effect_ModifyStats;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Item WeaponState;
	local X2Template_SpireGun Template;
	local array<StatChange> StatChanges;
	local StatChange ShieldChange;

	`LOG("JSRC: shield added");

	// read the amount of shield from the spiregun's template
	WeaponState = XComGameState_Item(NewGameState.GetGameStateForObjectID(ApplyEffectParameters.ItemStateObjectRef.ObjectID));
	Template = X2Template_SpireGun(WeaponState.GetMyTemplate());

	ShieldChange.StatType = eStat_ShieldHP;
	ShieldChange.StatAmount = Template.ShelterShieldBonus;
	ShieldChange.ModOp = MODOP_Addition;
	StatChanges.AddItem(ShieldChange);
	NewEffectState.StatChanges = StatChanges;

	super.OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);
}

function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local X2EventManager EventMgr;
	local XComGameState_Unit UnitState;
	local Object EffectObj;

	EventMgr = `XEVENTMGR;

	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectGameState.ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	EffectObj = EffectGameState;

	EventMgr.RegisterForEvent(EffectObj, 'ShieldsExpended', EffectGameState.OnShieldsExpended, ELD_OnStateSubmitted, , UnitState);
}

defaultproperties 
{
	DuplicateResponse=eDupe_Refresh
	EffectName=Jammerware_JSRC_Effect_ShelterShield
}