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