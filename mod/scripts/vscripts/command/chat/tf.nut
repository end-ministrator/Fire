global function ServerChatCommand_Tf_Init
global function Fire_Titanfall

void function ServerChatCommand_Tf_Init()
{
    AddChatCommandCallback( "/tf", ServerChatCommand_Tf )
}

void function ServerChatCommand_Tf(entity player, array<string> args)
{
    if(!Fire_IsPlayerAdmin(player)){
        Fire_ChatServerPrivateMessage(player, "你没有管理员权限")
        return
    }
    if(args.len() != 1){
        Fire_ChatServerPrivateMessage(player, "用法: /tf < name/all/imc/militia >")
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

        if( !IsValid(target) || !IsAlive(target) ){
            Fire_ChatServerPrivateMessage(player, "玩家 " + targetName + " 无效或死亡")
            continue
        }
        if( player.IsTitan() || IsValid(player.GetPetTitan()) ){
            Fire_ChatServerPrivateMessage(player, "玩家 " + targetName + " 已有泰坦")
            continue
        }
        thread Fire_Titanfall(target)
        Fire_ChatServerPrivateMessage(player, "已为玩家 " + targetName + " 降落泰坦")
    }
}

void function Fire_Titanfall(entity player)
{
    if( SpawnPoints_GetTitan().len() > 0 )
    {
        CreateTitanForPlayerAndHotdrop(player, GetTitanReplacementPoint(player, false))
    }
}