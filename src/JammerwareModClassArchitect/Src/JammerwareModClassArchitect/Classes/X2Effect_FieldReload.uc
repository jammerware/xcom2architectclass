class X2Effect_FieldReload extends X2Effect;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
    local Jammerware_JSRC_ItemStateService ItemsService;
    local XComGameState_Unit ShooterState, TargetState;
    local XComGameState_Item WeaponState;
    local X2WeaponTemplate_SpireGun WeaponTemplate;

    ItemsService = new class'Jammerware_JSRC_ItemStateService';
	ShooterState = XComGameState_Unit(NewGameState.GetGameStateForObjectID(ApplyEffectParameters.SourceStateObjectRef.ObjectID));
    WeaponState = ShooterState.GetSecondaryWeapon();
    WeaponTemplate = X2WeaponTemplate_SpireGun(WeaponState.GetMyTemplate());
    TargetState = XComGameState_Unit(kNewTargetState);

    // TODO: maybe preserve "restore all ammo" via config too
    NewGameState.ModifyStateObject(class'XComGameState_Unit', TargetState.ObjectID);
    ItemsService.LoadAmmo(TargetState.GetPrimaryWeapon(), WeaponTemplate.FieldReloadAmmoGranted, NewGameState);
}

simulated function AddX2ActionsForVisualization(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata, const name EffectApplyResult)
{
    local Jammerware_JSRC_FlyoverService FlyoverService;
	local XComGameState_Unit TargetState;
    local XComGameStateContext_Ability AbilityContext;
    local XComGameState_Ability AbilityState;
    local X2AbilityTemplate AbilityTemplate;

	// respect our elders
	super.AddX2ActionsForVisualization(VisualizeGameState, ActionMetadata, EffectApplyResult);

    if (EffectApplyResult == 'AA_Success')
    {
        AbilityContext = XComGameStateContext_Ability(VisualizeGameState.GetContext());
        TargetState = XComGameState_Unit(VisualizeGameState.GetGameStateForObjectID(ActionMetadata.StateObject_NewState.ObjectID));

        if (TargetState == none)
            return;

        AbilityState = XComGameState_Ability(VisualizeGameState.GetGameStateForObjectID(AbilityContext.InputContext.AbilityRef.ObjectID));
        AbilityTemplate = AbilityState.GetMyTemplate();

        FlyoverService = new class'Jammerware_JSRC_FlyoverService';
        FlyoverService.FlyoverText = AbilityTemplate.LocFlyoverText;
        FlyoverService.FlyoverIcon = AbilityTemplate.IconImage;
        FlyoverService.TargetPlayAnimation = 'HL_Reload';
        FlyoverService.VisualizeFlyover(VisualizeGameState, TargetState, ActionMetadata);
    }
}