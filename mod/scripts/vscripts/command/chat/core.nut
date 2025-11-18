global function ServerChatCommand_Core_Init

void function ServerChatCommand_Core_Init()
{
    AddChatCommandCallback( "/core", ServerChatCommand_Core )
}

void function ServerChatCommand_Core(entity player, array<string> args)
{
    if(!Fire_IsPlayerAdmin(player)){
        Fire_ChatServerPrivateMessage(player, "你没有管理员权限")
        return
    }
    if(args.len() != 2){
        Fire_ChatServerPrivateMessage(player, "用法: /core < name/all/imc/militia > < core >")
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
    if( targets.len() == 0 ){
        Fire_ChatServerPrivateMessage( player, "未找到玩家: " + args0 )
        return
    }

    string args1 = args[1]

    if( hasNonDigit(args1) ){
        Fire_ChatServerPrivateMessage( player, "核心值必须为数字" )
        return
    }
    int core = args1.tointeger()
    if( core < 1 || core > 100 ){
        Fire_ChatServerPrivateMessage( player, "核心值必须在1到100之间" )
        return
    }

    foreach(target in targets){
        string targetName = target.GetPlayerName()
        if( !IsValid(target) || !IsAlive(target)){
            Fire_ChatServerPrivateMessage( player, "玩家 " + targetName + " 无效或死亡" )
            continue
        }
        PlayerEarnMeter_AddOwnedFrac( target, core.tofloat() / 100.0 )
        Fire_ChatServerPrivateMessage( player, "已增加玩家 " + targetName + " 核心值 " + core + "%" )
    }
}