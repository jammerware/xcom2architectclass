class Jammerware_GameStateEffectsService extends Object;

function bool IsUnitAffectedByEffect(XComGameState_Unit Unit, name EffectName)
{
    local int LoopIndex;

    for (LoopIndex = 0; LoopIndex < Unit.AffectedByEffectNames.Length; LoopIndex++)
    {
        if (Unit.AffectedByEffectNames[LoopIndex] == EffectName) {
            return true;
        }
    }

    return false;
}