class Jammerware_JSRC_SpireRegistrationService extends Object;

var name UNIT_VALUE_LASTSPIREID;

function XComGameState_Unit GetRunnerFromSpire(int SpireID)
{
    local XComGameStateHistory History;
    local XComGameState_Unit Spire;
    local UnitValue ArchitectIDValue;
    local int SpireCreatorID;

    History = `XCOMHISTORY;
    Spire = XComGameState_Unit(History.GetGameStateForObjectID(SpireID));
    Spire.GetUnitValue(class'Jammerware_JSRC_UnitSpawnService'.default.NAME_UNITVALUE_OWNER_ID, ArchitectIDValue);
    SpireCreatorID = int(ArchitectIDValue.fValue);

    if (ArchitectIDValue.fValue == 0)
        `REDSCREEN("JSRC: spire" @ SpireID @ "has no architect ID");
    
    return XComGameState_Unit(History.GetGameStateForObjectID(SpireCreatorID));
}

function XComGameState_Unit GetLastSpireFromRunner(XComGameState_Unit RunnerUnitGameState, XComGameState GameState)
{
    local UnitValue SpawnedUnitIDValue;

    RunnerUnitGameState.GetUnitValue(default.UNIT_VALUE_LASTSPIREID, SpawnedUnitIDValue);    
    if (SpawnedUnitIDValue.fValue == 0)
    {
        return none;
    }

    return XComGameState_Unit(GameState.GetGameStateForObjectID(int(SpawnedUnitIDValue.fValue)));
}

function RegisterSpireToArchitect(XComGameState_Unit SpireState, XComGameState_Unit ArchitectState)
{
    `LOG("JSRC: architect" @ ArchitectState.GetFullName());
    `LOG("JSRC: spire" @ SpireState.GetFullName());
    ArchitectState.SetUnitFloatValue(default.UNIT_VALUE_LASTSPIREID, SpireState.ObjectID, eCleanup_BeginTactical);
}

defaultproperties
{
    UNIT_VALUE_LASTSPIREID=Jammerware_JSRC_UnitValue_LastSpireID
}