class X2Condition_AllyAdjacency extends X2Condition;

// the check only passes if this is none or the ally doesn't have this effect
var name ExcludeAllyEffect;

// the check only passes if this is none or the ally has this effect
var name RequireAllyEffect;

// the check only passes if this is none or the ally isn't part of this character group
var name ExcludeAllyCharacterGroup;

// the check only passes if this is none or the ally is part of this character group
var name RequireAllyCharacterGroup;

event name CallMeetsCondition(XComGameState_BaseObject kTarget) 
{
	local XComGameState_Unit Target, Ally;
    local array<XComGameState_Unit> AdjacentUnits;
    local Jammerware_JSRC_ProximityService ProximityService;

    Target = XComGameState_Unit(kTarget);
    ProximityService = new class'Jammerware_JSRC_ProximityService';
    AdjacentUnits = ProximityService.GetAdjacentUnits(Target, true);

    foreach AdjacentUnits(Ally)
    {
        if (
            (ExcludeAllyCharacterGroup == 'None' || Ally.GetMyTemplate().CharacterGroupName != ExcludeAllyCharacterGroup) &&
            (RequireAllyCharacterGroup == 'None' || Ally.GetMyTemplate().CharacterGroupName == RequireAllyCharacterGroup) &&
            (RequireAllyEffect == 'None' || Ally.AffectedByEffectNames.Find(RequireAllyEffect) != INDEX_NONE) &&
            (ExcludeAllyEffect == 'None' || Ally.AffectedByEffectNames.Find(ExcludeAllyEffect) == INDEX_NONE)
        ) { return 'AA_Success'; }
    }

    return 'AA_ValueCheckFailed';
}