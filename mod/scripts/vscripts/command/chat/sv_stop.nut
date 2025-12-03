global function ServerChatCommand_Stop_Init


void function ServerChatCommand_Stop_Init()
{
    AddChatCommandCallback( "/stop",  ServerChatCommand_Stop )
}

void function ServerChatCommand_Stop(entity player, array<string> args)
{
    if( !Fire_IsPlayerAdmin( player ) )
    {
        Fire_ChatServerPrivateMessage(player, "你没有管理员权限")
        return
    }
    if(args.len() != 1){
        Fire_ChatServerPrivateMessage(player, "用法: /stop < 原因 >")
        return
    }

    foreach(player in GetPlayerArray())
    {
        if( !IsValid( player ) )
            continue
        NSDisconnectPlayer( player, args[0] )
    }
    wait 0.2
    ServerCommand( "quit" )
}