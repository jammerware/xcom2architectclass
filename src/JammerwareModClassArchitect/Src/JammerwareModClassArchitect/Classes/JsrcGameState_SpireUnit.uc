class JsrcGameState_SpireUnit extends XComGameState_Unit;

var localized string LocSpireKilledTitle;
var localized string LocSpireKilledMessage;
var localized string LocSpireName;

function string GetName(ENameType eType)
{
	local XGParamTag kTag;
    local XComGameState_Unit ArchitectState;
    local Jammerware_JSRC_SpireRegistrationService SpireRegistrationService;

    SpireRegistrationService = new class'Jammerware_JSRC_SpireRegistrationService';
    ArchitectState = SpireRegistrationService.GetRunnerFromSpire(self.ObjectID);

	if (ArchitectState == none)
		return super.GetName(eType);

	kTag = XGParamTag(`XEXPANDCONTEXT.FindTag("XGParam"));
	kTag.StrValue0 = ResolveArchitectName(ArchitectState);
	kTag.StrValue1 = GetMyTemplate().strCharacterName;
    
    return `XEXPAND.ExpandString(default.LocSpireName);
}

private function string ResolveArchitectName(XComGameState_Unit ArchitectState)
{
    if (ArchitectState.strNickName != "") 
		return Repl(ArchitectState.strNickName, "'", "");

    return ArchitectState.strLastName;
}

// not sure if this is worth
// this is overriden from XComGameState_Unit so that the world callout says "was destroyed" instead of "was killed" when a spire is killed by the enemy
// the only thing that's really even changed is the call to AddMessageBanner and to AddWorldMessage
function UnitDeathVisualizationWorldMessage(XComGameState VisualizeGameState)
{
	local XComGameStateHistory History;
	local VisualizationActionMetadata ActionMetadata;
	local X2Action_PlayMessageBanner MessageAction;
	local X2Action_PlayWorldMessage WorldMessageAction;
	local X2Action_UpdateFOW FOWUpdateAction;
	local XGParamTag kTag;
	local ETeam UnitTeam;
	local XComGameStateVisualizationMgr LocalVisualizationMgr;
	local X2Action_CameraLookAt CameraLookAt;
	
	History = `XCOMHISTORY;
	LocalVisualizationMgr = `XCOMVISUALIZATIONMGR;

	History.GetCurrentAndPreviousGameStatesForObjectID(ObjectID, ActionMetadata.StateObject_OldState, ActionMetadata.StateObject_NewState, eReturnType_Reference, VisualizeGameState.HistoryIndex);
	ActionMetadata.VisualizeActor = History.GetVisualizer(ObjectID);

	// try to parent to the death action if there is one
	ActionMetadata.LastActionAdded = LocalVisualizationMgr.GetNodeOfType(LocalVisualizationMgr.BuildVisTree, class'X2Action_Death', none, ObjectID);

	kTag = XGParamTag(`XEXPANDCONTEXT.FindTag("XGParam"));
	kTag.StrValue0 = GetFullName();

	// no need to display death world messages for enemies; most enemies will display loot messages when killed
	UnitTeam = GetTeam();
	if( UnitTeam == eTeam_XCom )
	{
		CameraLookAt = X2Action_CameraLookAt(class'X2Action_CameraLookAt'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, ActionMetadata.LastActionAdded));
		CameraLookAt.LookAtObject = ActionMetadata.StateObject_NewState;
		CameraLookAt.LookAtDuration = 2.0;
		CameraLookAt.BlockUntilActorOnScreen = true;
		CameraLookAt.UseTether = false;
		CameraLookAt.DesiredCameraPriority = eCameraPriority_GameActions; // increased camera priority so it doesn't get stomped

		MessageAction = X2Action_PlayMessageBanner(class'X2Action_PlayMessageBanner'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, ActionMetadata.LastActionAdded));
		MessageAction.AddMessageBanner
		(
			default.LocSpireKilledTitle,
			/*class'UIUtilities_Image'.const.UnitStatus_Unconscious*/,
			GetName(eNameType_RankFull),
			`XEXPAND.ExpandString(default.LocSpireKilledMessage),
			eUIState_Bad
		);
	}
	else
	{
		WorldMessageAction = X2Action_PlayWorldMessage(class'X2Action_PlayWorldMessage'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, ActionMetadata.LastActionAdded));
		WorldMessageAction.AddWorldMessage(`XEXPAND.ExpandString(default.LocSpireKilledMessage));
	}

	FOWUpdateAction = X2Action_UpdateFOW(class'X2Action_UpdateFOW'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, ActionMetadata.LastActionAdded));
	FOWUPdateAction.Remove = true;
}