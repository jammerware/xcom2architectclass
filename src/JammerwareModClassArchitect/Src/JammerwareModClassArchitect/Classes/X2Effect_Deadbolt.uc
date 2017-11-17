class X2Effect_Deadbolt extends X2Effect;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
    local XComGameState_Unit TargetState;
    local XComGameState_Item PrimaryWeaponState;
    local Jammerware_JSRC_ItemStateService ItemStateService;

    TargetState = XComGameState_Unit(kNewTargetState);
    PrimaryWeaponState = TargetState.GetPrimaryWeapon();

    ItemStateService = new class'Jammerware_JSRC_ItemStateService';
    ItemStateService.LoadAmmo(PrimaryWeaponState, 1, NewGameState);
}

simulated function AddX2ActionsForVisualization(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata, const name EffectApplyResult)
{
    local Jammerware_JSRC_FlyoverService FlyoverService;
    local XComGameState_Unit TargetState;
    local X2AbilityTemplateManager AbilityTemplateManager;
    local X2AbilityTemplate DeadboltTemplate;
    local XComGameStateContext_Ability AbilityContext;

    if (EffectApplyResult == 'AA_Success')
    {
        AbilityContext = XComGameStateContext_Ability(VisualizeGameState.GetContext());
        AbilityTemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
        DeadboltTemplate = AbilityTemplateManager.FindAbilityTemplate(class'JsrcAbility_Deadbolt'.default.NAME_DEADBOLT);
        FlyoverService = new class'Jammerware_JSRC_FlyoverService';
        TargetState = XComGameState_Unit(VisualizeGameState.GetGameStateForObjectID(AbilityContext.InputContext.PrimaryTarget.ObjectID));

        FlyoverService.FlyoverText = DeadboltTemplate.LocFlyoverText;
        FlyoverService.FlyoverIcon = DeadboltTemplate.IconImage;
        FlyoverService.VisualizeFlyover(VisualizeGameState, TargetState, ActionMetadata);
    }
}