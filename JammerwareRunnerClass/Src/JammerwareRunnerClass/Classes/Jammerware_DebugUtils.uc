class Jammerware_DebugUtils extends Object;

static function LogUnitAffectedByEffects(XComGameState_Unit Unit)
{
    local int LoopIndex;

    `LOG("JSRC - Unit" @ Unit.GetMyTemplate().DataName @ "affected by...");
    for (LoopIndex = 0; LoopIndex < Unit.AffectedByEffectNames.Length; LoopIndex++)
    {
        `LOG(" - " @ Unit.AffectedByEffectNames[LoopIndex]);
    }
}

static function LogUnitAbilities(XComGameState_Unit Unit)
{
    local int LoopIndex;
    local XComGameState_Ability AbilityState;
    local XComGameStateHistory History;

    History = `XCOMHISTORY;

    `LOG("JSRC - Unit" @ Unit.GetMyTemplate().DataName @ "has" @ Unit.Abilities.Length @ " abilities...");
    for (LoopIndex = 0; LoopIndex < Unit.Abilities.Length; LoopIndex++)
    {
        AbilityState = XComGameState_Ability(History.GetGameStateForObjectID(Unit.Abilities[LoopIndex].ObjectID));
        `LOG(" - " @ AbilityState.GetMyTemplate().DataName);
    }
}

static function LogUnitFValue(XComGameState_Unit Unit, name UnitValueName)
{
    local UnitValue UnitValue;
    Unit.GetUnitValue(UnitValueName, UnitValue);

    `LOG("JSRC: Unit " @ GetUnitLogName(Unit) @ "has value for" @ UnitValueName @ ":" @ UnitValue.fValue);
}

static function LogUnitLocation(XComGameState_Unit Unit)
{
    `LOG("JSRC: unit" @ Unit.GetMyTemplateName() @ Unit.GetReference().ObjectID @ "is located at" @ `XWORLD.GetPositionFromTileCoordinates(Unit.TileLocation));
}

static function string GetUnitLogName(XComGameState_Unit Unit)
{
    return Unit.GetMyTemplateName() @ "(" @ Unit.GetReference().ObjectID @ ")";
}