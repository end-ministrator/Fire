global function ServerChatCommand_Team_Init

void function ServerChatCommand_Team_Init()
{
    AddChatCommandCallback( "/team", ServerChatCommand_Team )
}

void function ServerChatCommand_Team(entity player, array<string> args)
{
    if(!Fire_IsPlayerAdmin(player)){
        Fire_ChatServerPrivateMessage(player, "你没有管理员权限")
        return
    }
    if(args.len() != 2){
        Fire_ChatServerPrivateMessage(player, "用法: /team < name/all/imc/militia > < team >")
        return
    }

    string args0 = args[0]
    array<entity> targets = []

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

    string args1 = args[1]

    if(hasNonDigit(args1)){
        Fire_ChatServerPrivateMessage(player, "队伍必须是数字")
        return
    }
    int team = args1.tointeger()
    if(team < 2){
        Fire_ChatServerPrivateMessage(player, "队伍必须大于等于2")
        return
    }

    foreach(target in targets)
    {
        if( !IsValid(target) || !IsValid(target) ){
            Fire_ChatServerPrivateMessage(player, "玩家 " + target.GetPlayerName() + " 无效或死亡")
            continue
        }
        try{
            SetTeam(target, team)
            Fire_ChatServerPrivateMessage(player, "已设置玩家 " + target.GetPlayerName() + " 的队伍为 " + team)
        }catch (error){
            Fire_ChatServerPrivateMessage(player, "错误: " + string(error))
        }
    }
}