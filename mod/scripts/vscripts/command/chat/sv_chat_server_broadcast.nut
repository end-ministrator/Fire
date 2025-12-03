global function ServerChatCommand_Csb_Init

void function ServerChatCommand_Csb_Init()
{
    AddChatCommandCallback( "/csb", ServerChatCommand_Csb )
}

void function ServerChatCommand_Csb(entity player, array<string> args)
{
    if( !Fire_IsPlayerAdmin( player ) )
    {
        Fire_ChatServerPrivateMessage(player, "你没有管理员权限")
        return
    }

    string msg = ""
    for(int i; i < args.len(); i++)
    {
        msg += args[i] + " "
    }

    Fire_ChatServerBroadcast( msg )
}