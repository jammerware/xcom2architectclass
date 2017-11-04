class Jammerware_JSRC_WorldMessageService extends object;

public function VisualizeMessage(XComGameState VisualizeGameState, VisualizationActionMetadata VisualizationTrack, BannerData MessageData)
{
    local X2Action_PlayMessageBanner WorldMessageAction;

    WorldMessageAction = X2Action_PlayMessageBanner(class'X2Action_PlayMessageBanner'.static.AddToVisualizationTree(VisualizationTrack, VisualizeGameState.GetContext(), false, VisualizationTrack.LastActionAdded));
	WorldMessageAction.AddMessageBanner
	(
		MessageData.Message,
		(MessageData.IconPath == "" ? "img:///UILibrary_XPACK_Common.WorldMessage" : MessageData.IconPath),
		MessageData.Subtitle,
		MessageData.Value,
		MessageData.eState,
        MessageData.OnMouseEvent
	);
}