class Jammerware_SpireRegistrationService extends Object;

var name UNITVALUE_SPIRECREATORID;

function XComGameState_Unit GetRunnerFromSpire(XComGameState_Unit SpireUnitGameState, XComGameStateHistory GameState)
{
    local UnitValue SpireCreatorID;
    
    SpireUnitGameState.GetUnitValue(default.UNITVALUE_SPIRECREATORID, SpireCreatorID);

    if (SpireCreatorID.fValue == 0) 
    {
        return none;
    }
    
    return XComGameState_Unit(GameState.GetGameStateForObjectID(int(SpireCreatorID.fValue)));
}

function RegisterSpireToRunner(XComGameState_Unit SpireUnitGameState, XComGameState_Unit RunnerUnitGameState)
{
    SpireUnitGameState.SetUnitFloatValue(default.UNITVALUE_SPIRECREATORID, RunnerUnitGameState.ObjectID, eCleanup_BeginTactical);
}

defaultproperties
{
    UNITVALUE_SPIRECREATORID=Jammerware_JSRC_UnitValue_SpireCreatorUnitID
}