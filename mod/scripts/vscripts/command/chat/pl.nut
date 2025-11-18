global function ServerChatCommand_Pl_Init


void function ServerChatCommand_Pl_Init()
{
    AddChatCommandCallback( "/pl", ServerChatCommand_Pl )
}

void function ServerChatCommand_Pl(entity player, array<string> args)
{
    if(args.len() != 0){
        Fire_ChatServerPrivateMessage(player, "用法: /pl")
        return
    }
    foreach( target in GetPlayerArray() ){
        if( !IsValid(target) )
            continue
        string name = "Name: " + target.GetPlayerName()
        string uid = "UID: " + target.GetUID() + " | "
        string team = "Team: " + target.GetTeam() + " | "
        // Team: 2 | UID: 12345678901234567 | Name: PlayerName
        
        Fire_ChatServerPrivateMessage( player , team + uid + name )
    }
}