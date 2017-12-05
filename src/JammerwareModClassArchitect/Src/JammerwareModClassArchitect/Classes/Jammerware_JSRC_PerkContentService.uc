class Jammerware_JSRC_PerkContentService extends Object;

var array<name> AbilitiesToRegister;

public function RegisterPerkContent()
{
    local XComContentManager Content;
    local name AbilityIterator;

    Content = `CONTENT;
    Content.BuildPerkPackageCache();

    foreach AbilitiesToRegister(AbilityIterator)
    {
        Content.CachePerkContent(AbilityIterator);
    }
}