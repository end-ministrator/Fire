global function ServerChatCommand_Ban_Init
global function Fire_BanPlayer

bool debug = false

void function ServerChatCommand_Ban_Init()
{
    AddChatCommandCallback("/ban", ServerChatCommand_Ban)
}

void function ServerChatCommand_Ban(entity player, array<string> args)
{
    if( !Fire_IsPlayerAdmin( player ) ){
        Fire_ChatServerPrivateMessage(player, "你没有管理员权限")
        return
    }

    if(args.len() != 1){
        Fire_ChatServerPrivateMessage(player, "用法: /ban < 玩家名称 >")
        return
    }
    
    string args0 = args[0]
    entity target = GetPlayerByNamePrefix(args0)

    if( target == null ){
        Fire_ChatServerPrivateMessage( player, "未找到玩家: " + args0 )
        return
    }
    if( !IsValid( target ) ){
        Fire_ChatServerPrivateMessage( player, "无效玩家: " + args0 )
        return
    }
    
    Fire_BanPlayer( target )
}

void function Fire_BanPlayer( entity player )
{
    string playerName = player.GetPlayerName()
    string playerUID = GetPlayerUID(player)

    if(!debug)
        ServerCommand( "ban " + playerUID )

    Fire_ChatServerBroadcast( "|==================[BAN]==================|")
    Fire_ChatServerBroadcast( " 玩家: " + playerName + " (" + playerUID + ")" )
    Fire_ChatServerBroadcast( "|========================================|" )
}