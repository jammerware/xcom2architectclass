// thanks to aleosiss and robojumper for these tools
class Jammerware_JSRC_DebugStateMachines extends UIScreen;
 
struct UnitTextMapping
{
    var name ActorName;
    var UIText Text;
};
 
var array<UnitTextMapping> Texts;
 
static function Jammerware_JSRC_DebugStateMachines GetThisScreen()
{
    local Jammerware_JSRC_DebugStateMachines Scr;
    foreach `TACTICALGRI.AllActors(class'Jammerware_JSRC_DebugStateMachines', Scr)
    {
        return Scr;
    }
    Scr = `PRES.Spawn(class'Jammerware_JSRC_DebugStateMachines', `PRES);
    Scr.InitScreen(XComPlayerController(`PRES.GetALocalPlayerController()), `PRES.Get2DMovie());
    `PRES.Get2DMovie().LoadScreen(Scr);
    return Scr;
}
 
 
event Tick(float fDeltaTime)
{
    local XGUnit Unit;
    if (!bIsVisible)
    {
        return;
    }
    foreach DynamicActors(class'XGUnit', Unit)
    {
        UpdateFlagForUnit(Unit);
    }
}
 
simulated function UpdateFlagForUnit(XGUnit Unit)
{
    local int i;
    local UnitTextMapping NewMapping;
    local vector2d TextLoc;
    i = Texts.Find('ActorName', Unit.Name);
    if (i == INDEX_NONE)
    {
        `log("Created flag for" @ Unit.Name);
        i = Texts.Length;
        NewMapping.ActorName = Unit.Name;
        NewMapping.Text = Spawn(class'UIText', self).InitText();
        Texts.AddItem(NewMapping);
    }
    if (!Unit.IsVisible())
    {
        Texts[i].Text.Hide();
    }
    else
    {
        if (class'UIUtilities'.static.IsOnscreen(Unit.GetPawn().GetHeadshotLocation(), TextLoc))
        {
            Texts[i].Text.Show();
            Texts[i].Text.SetNormalizedPosition(TextLoc);
            Texts[i].Text.SetText("<font color='#ffffff'>"$ Unit.Name @ Unit.GetPawn().arrPawnPerkContent[0].GetAbilityName() $ "</font>");
            //Texts[i].Text.SetText(Unit.Name @ Unit.IdleStateMachine.GetStateName());
        }
        else
        {
            Texts[i].Text.Hide();
        }
    }
}
 
 
// Aleosiss code to follow
// Trying to determine if my PerkContents are even managing to make it onto my units!
simulated static function PrintOutPerkContentsForXComUnits() {
    local XGUnit Unit;
   
    foreach `TACTICALGRI.AllActors(class'XGUnit', Unit)
    {
        if(Unit.GetTeam() == eTeam_XCom) {
            PrintOutPerkContentsForUnit(Unit);
        }
    }
}
 
simulated static function PrintOutPerkContentsForUnit(XGUnit Unit) {
    local XComUnitPawn UnitPawn;
    local XComPerkContent IteratorPerkContent;
 
    UnitPawn = Unit.GetPawn();
    `log(Unit.Name $ " -------" $ XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(UnitPawn.m_kGameUnit.ObjectID)).GetFullName());
    if(UnitPawn.arrPawnPerkDefinitions.Length > 0)
        `log("This UnitPawn has "$ UnitPawn.arrPawnPerkDefinitions.Length $" Perks defined, and here they are: ");
    else `log("This UnitPawn has no Perks defined.");
    foreach UnitPawn.arrPawnPerkDefinitions(IteratorPerkContent) {
        `log(IteratorPerkContent.Name);
    }
}
 
simulated static function PrintOutLoadedPerkContents() {
    local XComContentManager Content;
    local XComPerkContent PerkDef;
   
    Content = `CONTENT;
 
    `LOG("Printing all loaded PerkContent names:");
    foreach Content.PerkContent( PerkDef ) {
        `LOG(PerkDef.Name);
    }
}
 
simulated static function TryForceAppendAbilityPerks(name AbilityName) {
    local XComUnitPawnNativeBase UnitPawnNativeBase;
   
    UnitPawnNativeBase = XComTacticalController(class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController()).GetActiveUnitPawn();
    `CONTENT.AppendAbilityPerks(AbilityName, UnitPawnNativeBase);
}
 
simulated static function TryForceCachePerkContent(name AbilityName) {
    `CONTENT.CachePerkContent(AbilityName);
}
 
simulated static function TryForceBuildPerkContentCache() {
    `CONTENT.BuildPerkPackageCache();
}
 
defaultproperties
{
    bIsVisible=false
    TickGroup=TG_PostAsyncWork
}