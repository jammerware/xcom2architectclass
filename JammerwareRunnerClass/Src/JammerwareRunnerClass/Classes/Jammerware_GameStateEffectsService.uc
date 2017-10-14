class Jammerware_GameStateEffectsService extends Object;

function bool IsUnitAffectedByEffect(XComGameState_Unit Unit, name EffectName)
{
    local name UnitEffect;

    foreach Unit.AffectedByEffectNames(UnitEffect)
    {
        if (UnitEffect == EffectName) {
            return true;
        }
    }

    return false;
}