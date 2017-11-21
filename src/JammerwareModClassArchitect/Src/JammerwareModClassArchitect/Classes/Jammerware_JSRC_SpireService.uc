class Jammerware_JSRC_SpireService extends Object;

public function bool IsSpire(XComGameState_Unit UnitState, optional bool AllowSoulOfTheArchitect)
{
    return
        UnitState.GetMyTemplate().CharacterGroupName == class'X2Character_Spire'.default.NAME_CHARACTERGROUP_SPIRE ||
        (
            AllowSoulOfTheArchitect &&
            UnitState.FindAbility(class'JsrcAbility_SoulOfTheArchitect'.default.NAME_ABILITY).ObjectID > 0
        );
}

// this is currently only used in JsrcCondition_OwnedSpire to check if the spire can actually use its activated abilities 
// (by virtue of the runner having the appropriate passive), but this is a spire-only concern, so i chonked it in here for now
public function bool SpireCanCast(XComGameState_Ability AbilityState)
{
    local X2Condition ConditionIterator;
    local X2Condition_SpireAbilityCondition Condition;

    foreach AbilityState.GetMyTemplate().AbilityShooterConditions(ConditionIterator)
    {
        if (ConditionIterator.IsA('X2Condition_SpireAbilityCondition'))
        {
            Condition = X2Condition_SpireAbilityCondition(ConditionIterator);
            if (Condition.CallAbilityMeetsCondition(AbilityState, none) != 'AA_Success')
            {
                return false;
            }

            break;
        }
    }

    return true;
}