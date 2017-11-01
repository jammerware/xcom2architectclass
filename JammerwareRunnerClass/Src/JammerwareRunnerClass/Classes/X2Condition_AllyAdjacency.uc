class X2Condition_AllyAdjacency extends X2Condition;

// the check only passes if this is none or the ally doesn't have this effect
var name ExcludeAllyEffect;

// the check only passes if this is none or the ally has this effect
var name RequireAllyEffect;

// the check only passes if this is none or the ally is part of this character group
var name RequireAllyCharacterGroup;

event name CallMeetsCondition(XComGameState_BaseObject kTarget) 
{
	local XComGameState_Unit Target, Ally;
    local array<XComGameState_Unit> AdjacentUnits;
    local Jammerware_ProximityService ProximityService;
    local Jammerware_GameStateEffectsService EffectsService;

    Target = XComGameState_Unit(kTarget);
    EffectsService = new class'Jammerware_GameStateEffectsService';
    ProximityService = new class'Jammerware_ProximityService';
    AdjacentUnits = ProximityService.GetAdjacentUnits(Target, true);

    foreach AdjacentUnits(Ally)
    {
        if (
            (RequireAllyCharacterGroup == 'None' || Ally.GetMyTemplate().CharacterGroupName == RequireAllyCharacterGroup) &&
            (RequireAllyEffect == 'None' || EffectsService.IsUnitAffectedByEffect(Ally, RequireAllyEffect)) &&
            (ExcludeAllyEffect == 'None' || !EffectsService.IsUnitAffectedByEffect(Ally, ExcludeAllyEffect))
        ) { return 'AA_Success'; }
    }

    return 'AA_ValueCheckFailed';
}