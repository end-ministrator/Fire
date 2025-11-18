global function ServerChatCommand_Mhp_Init

void function ServerChatCommand_Mhp_Init()
{
    AddChatCommandCallback( "/mhp", ServerChatCommand_Mhp )
}

void function ServerChatCommand_Mhp(entity player, array<string> args)
{
    if(!Fire_IsPlayerAdmin(player)){
        Fire_ChatServerPrivateMessage(player, "你没有管理员权限")
        return
    }
    if(args.len() != 2){
        Fire_ChatServerPrivateMessage(player, "用法: /mhp < 玩家名称/all > < 血量 >")
        return
    }

    string args0 = args[0]
    array<entity> targets

    switch(args0.tolower()){
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
        Fire_ChatServerPrivateMessage(player, "未找到玩家: " + args[1])
        return
    }

    string args1 = args[1]

    if(hasNonDigit(args1)){
        Fire_ChatServerPrivateMessage(player, "血量必须是数字")
        return
    }
    int hp = args1.tointeger()
    if(hp < 1){
        Fire_ChatServerPrivateMessage(player, "血量必须大于等于1")
        return
    }

    foreach(target in targets){
        string targetName = target.GetPlayerName()
        if( !IsValid(target) || !IsAlive(target)){
            Fire_ChatServerPrivateMessage(player, "玩家 " + targetName + " 无效或死亡")
            continue
        }
        target.SetMaxHealth(hp)
        Fire_ChatServerPrivateMessage( player, "已设置玩家 " + targetName + " 最大血量为" + hp )
    }
}