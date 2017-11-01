class Jammerware_JSRC_TagExpansionService extends object;

public function string ExpandAbilityTag(string Input)
{
    // this is ugly, but it's how they do it ¯\_(ツ)_/¯
    switch(Input)
    {
        case "SpawnSpireCooldown": return string(class'X2Ability_SpawnSpire'.default.SPAWNSPIRE_COOLDOWN);
    }

    return "";
}