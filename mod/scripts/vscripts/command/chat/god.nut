global function ServerChatCommand_God_Init


void function ServerChatCommand_God_Init()
{
    AddChatCommandCallback( "/god",  ServerChatCommand_God )
}

void function ServerChatCommand_God(entity player, array<string> args)
{
    if( !Fire_IsPlayerAdmin( player ) ){
        Fire_ChatServerPrivateMessage(player, "你没有管理员权限")
        return
    }

    if( args.len() != 1 ){
        Fire_ChatServerPrivateMessage(player, "用法：/god <玩家名称/all>")
        return
    }

    string args0 = args[0]
    array<entity> targets

    switch(args0.tolower()){
        case"all":
            targets = GetPlayerArray()
            break
        default:
            targets = GetPlayersByNamePrefix(args0)
            break
    }

    if(targets.len() == 0){
        Fire_ChatServerPrivateMessage( player, "未找到玩家: " + args0 )
        return
    }

    foreach( target in targets ){
        if( !IsValid( target ) || !IsAlive( target ) )
        {
            Fire_ChatServerPrivateMessage(player, "玩家 " + target.GetPlayerName() + " 无效或死亡")
            continue
        }
        if( !target.IsInvulnerable() )
        {
            target.SetInvulnerable()
            Fire_ChatServerPrivateMessage(player, "已设置玩家 " + target.GetPlayerName() + " 无敌")
        }else
        {
            target.ClearInvulnerable()
            Fire_ChatServerPrivateMessage(player, "已取消玩家 " + target.GetPlayerName() + " 无敌")
        }
    }
}