class Jammerware_SpireRegistrationService extends Object;

var name UNITVALUE_LASTSPIREID;

function XComGameState_Unit GetRunnerFromSpire(int SpireID)
{
    local XComGameStateHistory History;
    local XComGameState_Unit Spire;
    local int SpireCreatorID, i;
    local StateObjectReference IteratorEffectRef;
    local XComgameState_Effect EffectState;

    History = `XCOMHISTORY;
    Spire = XComGameState_Unit(History.GetGameStateForObjectID(SpireID));

    for (i = 0; i < Spire.AffectedByEffectNames.Length; i++)
    {
        if (Spire.AffectedByEffectNames[i] == class'X2Ability_SpireAbilitySet'.default.NAME_SPIRE_PASSIVE)
        {
            EffectState = XComGameState_Effect(History.GetGameStateForObjectID(Spire.AffectedByEffects[i].ObjectID));
            SpireCreatorID = EffectState.ApplyEffectParameters.SourceStateObjectRef.ObjectID;
            break;
        }
    }
    
    return XComGameState_Unit(History.GetGameStateForObjectID(SpireCreatorID));
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

function RegisterSpireToRunner(const out EffectAppliedData ApplyEffectParameters, StateObjectReference SpireUnitRef, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
    local EffectAppliedData NewEffectParams;
    local XComGameState_Unit RunnerState, SpireState;
    local X2Effect_SpirePassive SpirePassiveEffect;

    `LOG("JSRC: REGISTERING SPIRE TO RUNNER");
    `LOG("JSRC: REGISTERING SPIRE TO RUNNER");
    `LOG("JSRC: REGISTERING SPIRE TO RUNNER");

    RunnerState = XComGameState_Unit(NewGameState.GetGameStateForObjectID(ApplyEffectParameters.SourceStateObjectRef.ObjectID));
    `LOG("JSRC: runner state during registration is" @ RunnerState.GetMyTemplateName() @ RunnerState.ObjectID);
    SpireState = XComGameState_Unit(NewGameState.GetGameStateForObjectID(SpireUnitRef.ObjectID));
    `LOG("JSRC: spire state during registration is" @ SpireState.GetMyTemplateName() @ SpireState.ObjectID);

	NewEffectParams = ApplyEffectParameters;
	NewEffectParams.EffectRef.ApplyOnTickIndex = INDEX_NONE;
	NewEffectParams.EffectRef.LookupType = TELT_AbilityTargetEffects;
	NewEffectParams.EffectRef.SourceTemplateName = class'X2Ability_SpireAbilitySet'.default.NAME_SPIRE_PASSIVE;
	NewEffectParams.EffectRef.TemplateEffectLookupArrayIndex = 0;
	NewEffectParams.TargetStateObjectRef = SpireState.GetReference();

	SpirePassiveEffect = X2Effect_SpirePassive(class'X2Effect'.static.GetX2Effect(NewEffectParams.EffectRef));
	`assert(SpirePassiveEffect != none);
	SpirePassiveEffect.ApplyEffect(NewEffectParams, SpireState, NewGameState);

    // make a note of the last spire spawned by this runner. yes, i hate this
    RunnerState.SetUnitFloatValue(default.UNITVALUE_LASTSPIREID, SpireState.ObjectID, eCleanup_BeginTactical);
}

defaultproperties
{
    UNITVALUE_LASTSPIREID=Jammerware_JSRC_UnitValue_LastSpireID
}