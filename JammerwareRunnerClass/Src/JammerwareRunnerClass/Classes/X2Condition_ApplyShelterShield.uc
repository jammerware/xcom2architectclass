class X2Condition_ApplyShelterShield extends X2Condition_UnitProperty;

// the passive ability that triggers the shield can appear both on the runner and on his/her spires. if a spire is the source of the ability,
// we can go ahead and accept the trigger, because the spires get their abilities from the runner. if the source is the runner,
// the runner has to have "Soul of the Architect" if we're going to let the trigger fire.
event name CallAbilityMeetsCondition(XComGameState_Ability kAbility, XComGameState_BaseObject kTarget)
{
	local XComGameState_Unit SourceState;
	local XComGameState_Unit TargetState;	
	local Jammerware_GameStateEffectsService EffectsService;

	EffectsService = new class'Jammerware_GameStateEffectsService';
	SourceState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(kAbility.OwnerStateObject.ObjectID));
	TargetState = XComGameState_Unit(kTarget);

	// don't even trigger the effect if the target has the buff already
	if (EffectsService.IsUnitAffectedByEffect(TargetState, class'X2Effect_ShelterShield'.default.EffectName)) {
		return 'AA_DuplicateEffectIgnored';
	}

	// if the source is coming from a nonspire, the condition is only met if that source has soul of the architect
	if (SourceState.GetMyTemplate().DataName != class'X2Character_Spire'.default.NAME_CHARACTER_SPIRE && !EffectsService.IsUnitAffectedByEffect(SourceState, class'X2Ability_RunnerAbilitySet'.default.NAME_SOUL_OF_THE_ARCHITECT)) {
		return 'AA_ValueCheckFailed';
	}

	return 'AA_Success';
}