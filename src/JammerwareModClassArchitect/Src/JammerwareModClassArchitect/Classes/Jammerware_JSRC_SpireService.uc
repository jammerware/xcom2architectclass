class Jammerware_JSRC_SpireService extends Object;

public function bool IsSpire(XComGameState_Unit UnitState, optional bool AllowSoulOfTheArchitect)
{
    return
        UnitState.GetMyTemplate().CharacterGroupName == class'X2Character_Spire'.default.NAME_CHARACTERGROUP_SPIRE ||
        (
            AllowSoulOfTheArchitect &&
            UnitState.AffectedByEffectNames.Find(class'X2Ability_RunnerAbilitySet'.default.NAME_SOUL_OF_THE_ARCHITECT) != INDEX_NONE
        );
}