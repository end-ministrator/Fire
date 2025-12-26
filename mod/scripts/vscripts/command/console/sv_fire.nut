global function ConsoleCommand_Fire_Init

string GithubUrl = "github.com/end-ministrator/Fire"

void function ConsoleCommand_Fire_Init()
{
    AddConsoleCommandCallback( "fire", ConsoleCommand_Fire )
}

bool function ConsoleCommand_Fire( entity player, array<string> args )
{
    Fire_ChatServerPrivateMessage( player, "Name: Fire" )
    Fire_ChatServerPrivateMessage( player, "Version: " + Fire_GetVersion() )
    Fire_ChatServerPrivateMessage( player, "GitHub: " + GithubUrl )
    Fire_ChatServerPrivateMessage( player, "IsDev: " + Fire_IsPlayerDev( player ).tostring() )
    Fire_ChatServerPrivateMessage( player, "IsAdmin: " + Fire_IsPlayerAdmin( player ).tostring() )
    return true
}