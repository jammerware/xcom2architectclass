class Jammerware_JSRC_AbilityAvailabilityService extends object;

public static function ShowIfValueCheckPasses(out AvailableAction Action, XComGameState_Ability AbilityState, XComGameState_Unit OwnerState)
{
    if (Action.AvailableCode != 'AA_ValueCheckFailed')
    {
        Action.eAbilityIconBehaviorHUD = EAbilityIconBehavior_AlwaysShow;
    }
}