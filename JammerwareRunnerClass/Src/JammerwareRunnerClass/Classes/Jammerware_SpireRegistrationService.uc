class Jammerware_SpireRegistrationService extends Object;

var name UNITVALUE_LASTSPIREID;
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

function XComGameState_Unit GetLastSpireFromRunner(XComGameState_Unit RunnerUnitGameState, XComGameState GameState)
{
    local UnitValue SpawnedUnitIDValue;

    RunnerUnitGameState.GetUnitValue(default.UNITVALUE_LASTSPIREID, SpawnedUnitIDValue);

    if (SpawnedUnitIDValue.fValue == 0)
    {
        return none;
    }

    return XComGameState_Unit(GameState.GetGameStateForObjectID(int(SpawnedUnitIDValue.fValue)));
}

function RegisterSpireToRunner(XComGameState_Unit SpireUnitGameState, XComGameState_Unit RunnerUnitGameState)
{
    SpireUnitGameState.SetUnitFloatValue(default.UNITVALUE_SPIRECREATORID, RunnerUnitGameState.ObjectID, eCleanup_BeginTactical);
    RunnerUnitGameState.SetUnitFloatValue(default.UNITVALUE_LASTSPIREID, SpireUnitGameState.ObjectID, eCleanup_BeginTactical);
}

defaultproperties
{
    UNITVALUE_LASTSPIREID=Jammerware_JSRC_UnitValue_LastSpireID
    UNITVALUE_SPIRECREATORID=Jammerware_JSRC_UnitValue_SpireCreatorUnitID
}