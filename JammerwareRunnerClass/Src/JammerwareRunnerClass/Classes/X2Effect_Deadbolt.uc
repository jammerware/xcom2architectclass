class X2Effect_Deadbolt extends X2Effect_Persistent;

function RegisterForEvents(XComGameState_Effect EffectGameState)
{
    local X2EventManager EventMgr;
	local XComGameState_Unit UnitState;
	local Object EffectObj;

	EventMgr = `XEVENTMGR;

	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectGameState.ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	EffectObj = EffectGameState;

	EventMgr.RegisterForEvent
    (
        EffectObj, 
        'AbilityActivated', 
        class'X2Effect_Deadbolt'.static.ShotMissListener, 
        ELD_OnStateSubmitted, 
        , 
        UnitState
    );
}

static function EventListenerReturn ShotMissListener(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComGameStateContext_Ability AbilityContext;
	local X2AbilityTemplate AbilityTemplate;
	local XComGameState NewGameState;
	local XComGameState_Unit UnitState;
    local XComGameState_Item PrimaryWeapon;
    local Jammerware_JSRC_ItemStateService ItemStateService;

	AbilityContext = XComGameStateContext_Ability(GameState.GetContext());
	if (AbilityContext != none && AbilityContext.InterruptionStatus != eInterruptionStatus_Interrupt && AbilityContext.IsResultContextMiss())
	{
        `LOG("JSRC: shooter missed");
		AbilityTemplate = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager().FindAbilityTemplate(AbilityContext.InputContext.AbilityTemplateName);
		if (AbilityTemplate.Hostility == eHostility_Offensive)
		{
            `LOG("JSRC: ability is hostile");
			UnitState = XComGameState_Unit(EventSource);
			if (UnitState != none)
			{
                `LOG("JSRC: found unit state");
				NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Deadbolt Reload");
				UnitState = XComGameState_Unit(NewGameState.ModifyStateObject(UnitState.Class, UnitState.ObjectID));
                PrimaryWeapon = UnitState.GetPrimaryWeapon();

                if (InStr(PrimaryWeapon.GetMyTemplateName(), "AlienHunterRifle") >= 0)
                {
                    `LOG("JSRC: shooter is using a boltcaster");
                    ItemStateService = new class'Jammerware_JSRC_ItemStateService';
                    ItemStateService.LoadAmmo(PrimaryWeapon, 1, NewGameState);
                    `LOG("JSRC: reloaded");

                    //NewGameState.ModifyStateObject(class'XComGameState_Ability', AbilityContext.InputContext.AbilityRef.ObjectID);
                    //XComGameStateContext_ChangeContainer(NewGameState.GetContext()).BuildVisualizationFn = TriggerAbilityFlyoverVisualizationFn;
                    `TACTICALRULES.SubmitGameState(NewGameState);
                }
			}
		}
	}

	return ELR_NoInterrupt;
}