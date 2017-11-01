class X2Effect_FieldReload extends X2Effect_Persistent;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
    local Object TypedEffect;
    local Object TypedTargetState;
    local Object TypedAbilityState;

    TypedEffect = NewEffectState;
    TypedTargetState = kNewTargetState;
    TypedAbilityState = NewGameState.GetGameStateForObjectID(ApplyEffectParameters.AbilityStateObjectRef.ObjectID);

    `XEVENTMGR.RegisterForEvent
    (
        TypedEffect,
        class'X2Effect_SpawnSpire'.default.NAME_SPIRE_SPAWN_TRIGGER,
        OnSpireSpawned,
        ELD_OnStateSubmitted,
        ,
        TypedTargetState,
        true,
        TypedAbilityState
    );
}

private static function EventListenerReturn OnSpireSpawned(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
    local Jammerware_JSRC_FlyoverService FlyoverService;
	local Jammerware_JSRC_ItemStateService ItemsService;
	local Jammerware_ProximityService ProximityService;

	local array<XComGameState_Unit> AdjacentAllies;
    local XComGameState NewGameState;
    local XComGameState_Unit Shooter, Spire;
	local XComGameState_Unit IterAlly;
	local XComGameState_Item SpireGunState;
	local X2WeaponTemplate_SpireGun SpireGunTemplate;
    local XComGameState_Ability AbilityState;

    Shooter = XComGameState_Unit(EventSource);
    Spire = XComGameState_Unit(EventData);

	ItemsService = new class'Jammerware_JSRC_ItemStateService';
    ProximityService = new class'Jammerware_ProximityService';
    AdjacentAllies = ProximityService.GetAdjacentUnits(Spire, true);
    SpireGunState = Shooter.GetSecondaryWeapon();
    SpireGunTemplate = X2WeaponTemplate_SpireGun(SpireGunState.GetMyTemplate());
    AbilityState = XComGameState_Ability(CallbackData);

    if (AdjacentAllies.Length > 0)
    {
        NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Field Reload - Triggered");
        AbilityState = XComGameState_Ability(NewGameState.ModifyStateObject(class'XComGameState_Ability', AbilityState.ObjectID));
        FlyoverService = new class'Jammerware_JSRC_FlyoverService';

        foreach AdjacentAllies(IterAlly)
        {
            // TODO: maybe preserve "restore all ammo" via config too
            NewGameState.ModifyStateObject(class'XComGameState_Unit', IterAlly.ObjectID);
            ItemsService.LoadAmmo(IterAlly.GetPrimaryWeapon(), SpireGunTemplate.FieldReloadAmmoGranted, NewGameState);
            `LOG("JSRC: reloaded" @ IterAlly.GetMyTemplateName());
        }

        XComGameStateContext_ChangeContainer(NewGameState.GetContext()).BuildVisualizationFn = FlyoverService.VisualizeFlyovers;
        NewGameState.GetContext().SetDesiredVisualizationBlockIndex(GameState.HistoryIndex);
        `TACTICALRULES.SubmitGameState(NewGameState);
    }

    return ELR_NoInterrupt;
}