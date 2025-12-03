global function ServerChatCommand_Eject_Init

void function ServerChatCommand_Eject_Init()
{
    if( IsLobby() || IsMenuLevel() )
        return
    AddChatCommandCallback( "/eject", ServerChatCommand_Eject )
}

void function ServerChatCommand_Eject(entity player, array<string> args)
{
    if(!Fire_IsPlayerAdmin(player)){
        Fire_ChatServerPrivateMessage(player, "你没有管理员权限")
        return
    }

    if(args.len() != 1){
        Fire_ChatServerPrivateMessage(player, "用法: /eject < name/all/imc/militia >")
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
        Fire_ChatServerPrivateMessage(player, "未找到玩家: " + args0)
        return
    }

    foreach(target in targets){
        string targetName = target.GetPlayerName()
        if( !IsValid(target) || !IsAlive(target)){
            Fire_ChatServerPrivateMessage( player, "玩家 " + targetName + " 无效或死亡" )
            continue
        }
        if( !target.IsTitan() ){
            Fire_ChatServerPrivateMessage( player, "玩家 " + targetName + " 不是泰坦" )
            continue
        }
        thread TitanEjectPlayer( player, false )
        Fire_ChatServerPrivateMessage( player, "已弹射玩家 " + targetName )
    }
}