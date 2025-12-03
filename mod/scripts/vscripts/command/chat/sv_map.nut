global function ServerChatCommand_Map_Init

bool For = false

void function ServerChatCommand_Map_Init()
{
    AddChatCommandCallback( "/map", ServerChatCommand_Map )
}

void function ServerChatCommand_Map(entity player, array<string> args)
{
    if( !Fire_IsPlayerAdmin( player ) ){
        Fire_ChatServerPrivateMessage(player, "你没有管理员权限")
        return
    }
    if(args.len() != 1){
        Fire_ChatServerPrivateMessage(player, "用法: /map <地图>")
        return
    }

    string args0 = args[0]
    if( !GetPrivateMatchMaps().contains(args0) ){
        Fire_ChatServerPrivateMessage(player, "地图不存在")
        return
    }

    Fire_ChatServerBroadcast( "正在切换地图: " + args0 )
    wait 1.5
    if(For)
    {
        for( int i = 5; i > 0; i-- ){
            Fire_ChatServerPrivateMessage( player, i.tostring() )
            wait 1.0
        }
        wait 0.2
    }
    GameRules_ChangeMap( args0, GameRules_GetGameMode() ) 
}