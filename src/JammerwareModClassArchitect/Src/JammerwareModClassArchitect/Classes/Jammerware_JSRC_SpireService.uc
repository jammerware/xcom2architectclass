class Jammerware_JSRC_SpireService extends Object;

public function bool IsSpire(XComGameState_Unit UnitState, optional bool AllowSoulOfTheArchitect)
{
    return
        UnitState.GetMyTemplate().CharacterGroupName == class'X2Character_Spire'.default.NAME_CHARACTERGROUP_SPIRE ||
        (
            AllowSoulOfTheArchitect &&
            UnitState.FindAbility(class'JsrcAbility_SoulOfTheArchitect'.default.NAME_ABILITY).ObjectID > 0
        );
}