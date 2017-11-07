class Jammerware_JSRC_GtsUnlockService extends Object;

public function AddUnlock(name Unlock)
{
    local X2FacilityTemplate FacilityTemplate;

	// Find the GTS facility template
	FacilityTemplate = X2FacilityTemplate(class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager().FindStrategyElementTemplate('OfficerTrainingSchool'));
	if (FacilityTemplate == none)
    {
        `REDSCREEN("JSRC: Couldn't find the GTS to add the architect unlock.");
		return;
    }

    FacilityTemplate.SoldierUnlockTemplates.AddItem(Unlock);
}