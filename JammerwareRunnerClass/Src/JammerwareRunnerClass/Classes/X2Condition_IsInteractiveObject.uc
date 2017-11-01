class X2Condition_IsInteractiveObject extends X2Condition;

var bool IsInteractiveObject;

event name CallMeetsCondition(XComGameState_BaseObject kTarget) 
{
    local XComGameState_InteractiveObject TypedTarget;

    TypedTarget = XComGameState_InteractiveObject(kTarget);
    if ((TypedTarget == none) != IsInteractiveObject)
    {
        return 'AA_Success';
    }

    return 'AA_UnitIsWrongType';
}