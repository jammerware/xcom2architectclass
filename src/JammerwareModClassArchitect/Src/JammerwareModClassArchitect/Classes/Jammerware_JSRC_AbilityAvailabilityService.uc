class Jammerware_JSRC_AbilityAvailabilityService extends object;

public static function ShowIfValueCheckPasses(out AvailableAction Action, XComGameState_Ability AbilityState, XComGameState_Unit OwnerState)
{
    `LOG("JSRC: show if value check passes" @ Action.AvailableCode);
    `LOG("JSRC: -" @ AbilityState.GetMyTemplateName());
    if (Action.AvailableCode != 'AA_ValueCheckFailed')
    {
        `LOG("JSRC: nailed it");
        Action.eAbilityIconBehaviorHUD = EAbilityIconBehavior_AlwaysShow;
    }
}