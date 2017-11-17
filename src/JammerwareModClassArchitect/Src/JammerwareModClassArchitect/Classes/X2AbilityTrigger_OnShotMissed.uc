class X2AbilityTrigger_OnShotMissed extends X2AbilityTrigger_EventListener;

var array<name> TriggeringAbilities;

public simulated function bool CheckForDeadboltActivation(XComGameState GameState, XComGameState_Ability ActivatedAbility, XComGameState_Ability TriggerAbility, Name InEventID)
{
	local X2AbilityTemplate ActivatedAbilityTemplate;
	local XComGameStateContext_Ability AbilityContext;

	ActivatedAbilityTemplate = ActivatedAbility.GetMyTemplate();
	AbilityContext = XComGameStateContext_Ability(GameState.GetContext());

	if (TriggeringAbilities.Find(ActivatedAbilityTemplate.DataName) != INDEX_NONE && ShouldTriggerDeadbolt(GameState, AbilityContext))
	{
		class'Jammerware_JSRC_AbilityStateService'.static.ActivateAbility(TriggerAbility);
		return true;
	}

	return false;
}

private function bool ShouldTriggerDeadbolt(XComGameState GameState, XComGameStateContext_Ability AbilityContext)
{
	local X2AbilityTemplate AbilityTemplate;
	local X2AbilityTemplateManager AbilityTemplateManager;
	local XComGameState_Unit SourceState;
	local XComGameState_Item PrimaryWeaponState;
	local int Rand;

	AbilityTemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	Rand = `SYNC_RAND(2);

	AbilityTemplate = AbilityTemplateManager.FindAbilityTemplate(AbilityContext.InputContext.AbilityTemplateName);
	if (AbilityTemplate.Hostility == eHostility_Offensive)
	{
		SourceState = XComGameState_Unit(GameState.GetGameStateForObjectID(AbilityContext.InputContext.SourceObject.ObjectID));
		if (SourceState != none)
		{
			PrimaryWeaponState = SourceState.GetPrimaryWeapon();
			if (PrimaryWeaponState.Ammo == 0 || Rand == 1)
			{
				return true;
			}
		}
	}

	return false;
}

public function SetListenerData()
{
	ListenerData.EventID = 'AbilityActivated';
	ListenerData.Deferral = ELD_OnStateSubmitted;
	ListenerData.Filter = eFilter_Unit;
	ListenerData.EventFn = class'JsrcGameState_Ability'.static.OnAbilityActivated;

	TriggeringAbilities.Length = 0;
	TriggeringAbilities.AddItem('StandardShot');
	TriggeringAbilities.AddItem('OverwatchShot');
}