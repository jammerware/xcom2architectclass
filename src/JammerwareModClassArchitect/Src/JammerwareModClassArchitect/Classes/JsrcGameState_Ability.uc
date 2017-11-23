class JsrcGameState_Ability extends XComGameState_Ability;

public function EventListenerReturn OnAbilityActivated(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local X2AbilityTrigger Trigger;
	local X2AbilityTemplate Template;

    local XComGameState_Ability ActivatedAbility, TriggerAbility;
    ActivatedAbility = XComGameState_Ability(EventData);
	// this might be the same as "self", not sure - refactor?
    TriggerAbility = XComGameState_Ability(CallbackData);

	if (TriggerAbility != none)
	{
		Template = GetMyTemplate();
		if (Template != None)
		{
			foreach Template.AbilityTriggers(Trigger)
			{
				if (Trigger.IsA('X2AbilityTrigger_OnShotMissed'))
				{
					if( X2AbilityTrigger_OnShotMissed(Trigger).CheckForDeadboltActivation(GameState, ActivatedAbility, TriggerAbility, EventID) )
						break;
				}
			}
		}
	}
	return ELR_NoInterrupt;
}

public function EventListenerReturn TriggerListener_SpireSpawned(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local Jammerware_JSRC_AbilityStateService AbilityService;
	local XComGameState_Unit SpireUnit;

	`LOG("JSRC: self is" @ self.GetMyTemplateName());

	AbilityService = new class'Jammerware_JSRC_AbilityStateService';
	SpireUnit = XComGameState_Unit(EventData);
	
	if (SpireUnit.ObjectID == self.OwnerStateObject.ObjectID)
		AbilityService.ActivateAbility(self);

	return ELR_NoInterrupt;
}