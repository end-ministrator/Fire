global function Fire_GetDevArray
global function Fire_IsPlayerDev

array<string> DeveloperUIDs = [
    "1013199872353" // Endmstr
]

array<entity> function Fire_GetDevArray()
{
    array<entity> devs = []
    foreach(player in GetPlayerArray())
    {
        if( !IsValid(player) )
            continue
        if( DeveloperUIDs.contains( player.GetUID() ) )
            devs.append(player)
    }
    return devs
}

bool function Fire_IsPlayerDev( entity player )
{
    return DeveloperUIDs.contains( player.GetUID() )
}