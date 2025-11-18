global function ServerChatCommand_Hide_Init

void function ServerChatCommand_Hide_Init()
{
    AddChatCommandCallback( "/hide", ServerChatCommand_Hide )
}

void function ServerChatCommand_Hide(entity player, array<string> args)
{
    if(!Fire_IsPlayerAdmin(player)){
        Fire_ChatServerPrivateMessage(player, "你没有管理员权限")
        return
    }
    if(args.len() != 1){
        Fire_ChatServerPrivateMessage(player, "用法: /hide < name/all/imc/militia >")
        return
    }

    string args0 = args[0]
    array<entity> targets

    switch( args0.tolower() ){
        case "all":
            targets = GetPlayerArray()
            break
        case "imc":
            targets = GetPlayerArrayOfTeam( TEAM_IMC )
            break
        case "militia":
            targets = GetPlayerArrayOfTeam( TEAM_MILITIA )
            break
        default:
            targets = GetPlayersByNamePrefix( args0 )
            break
    }
    if(targets.len() == 0){
        Fire_ChatServerPrivateMessage(player, "未找到玩家: " + args0)
        return
    }

    foreach(target in targets){
        if( !IsValid(target) || !IsAlive(target)){
            Fire_ChatServerPrivateMessage(player, "玩家 " + target.GetPlayerName() + " 无效或死亡")
            continue
        }
        target.kv.VisibilityFlags = 0
        Fire_ChatServerPrivateMessage( player, "已隐藏玩家 " + target.GetPlayerName())
    }
}