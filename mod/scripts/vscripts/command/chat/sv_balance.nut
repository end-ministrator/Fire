global function ChatCommand_Bal_Init
global function Fire_IsValidBalanceMode
global function Fire_Balance
global function Fire_BalanceByNumber
global function Fire_BalanceByKD
global function Fire_BalanceByKMinusD

struct PlayerScoreData
{
    entity player
    int score
}

void function ChatCommand_Bal_Init()
{
    AddChatCommandCallback("/bal", ChatCommand_Balance)
}

void function ChatCommand_Balance(entity player, array<string> args) 
{
    if( !Fire_IsPlayerAdmin(player) ) {
        Fire_ChatServerPrivateMessage(player, "你没有管理员权限")
        return
    }
    if( args.len() != 1 ) {
        SendUsageHint(player)
        return
    }
    if( hasNonDigit(args[0]) ) {
        Fire_ChatServerPrivateMessage(player, "错误：请输入纯数字参数")
        SendUsageHint(player)
        return
    }

    int mode = -1
    try {
        mode = args[0].tointeger()
    } catch( ex ) {
        Fire_ChatServerPrivateMessage(player, "错误：无效数字格式")
        SendUsageHint(player)
        return
    }
    if( !Fire_IsValidBalanceMode(mode) ) {
        SendUsageHint(player)
        return
    }
    
    Fire_Balance(mode)
}

void function SendUsageHint(entity player) 
{
    Fire_ChatServerPrivateMessage(player, "用法: /bal <1/2/3>")
    Fire_ChatServerPrivateMessage(player, "1=人数平衡 2=K/D平衡 3=K-D平衡")
}


bool function Fire_IsValidBalanceMode(int mode)
{
    return mode == 1 || mode == 2 || mode == 3
}

void function Fire_Balance(int mode = 3)
{
    switch(mode)
    {
        case 1:
            Fire_BalanceByNumber()
            Fire_ChatServerBroadcast( "人数平衡" )
            break
        case 2:
            Fire_BalanceByKD()
            Fire_ChatServerBroadcast( "K/D平衡" )
            break
        case 3:
            Fire_BalanceByKMinusD()
            Fire_ChatServerBroadcast( "K-D平衡" )
            break
    }
}

// 人数平衡
void function Fire_BalanceByNumber()
{
    array<entity> players = GetPlayerArray()
    for(int i = 0; i < players.len(); i++)
    {
        SetTeam(players[i], i % 2 ? TEAM_MILITIA : TEAM_IMC)
    }
}

// K/D平衡
void function Fire_BalanceByKD()
{
    array<PlayerScoreData> playerData

    foreach(player in GetPlayerArray())
    {
        PlayerScoreData data
        data.player = player
        
        int deaths = player.GetPlayerGameStat(PGS_DEATHS)
        if(deaths == 0)
            data.score = 999999
        else
            data.score = player.GetPlayerGameStat(PGS_KILLS) * 1000 / deaths
        
        playerData.append(data)
    }

    playerData.sort(PlayerScoreDataSortDesc)

    for(int i = 0; i < playerData.len(); i++)
    {
        SetTeam(playerData[i].player, i % 2 ? TEAM_MILITIA : TEAM_IMC)
    }
}

// K-D平衡
void function Fire_BalanceByKMinusD()
{
    array<PlayerScoreData> playerData

    foreach(player in GetPlayerArray())
    {
        PlayerScoreData data
        data.player = player
        data.score = player.GetPlayerGameStat(PGS_KILLS) - player.GetPlayerGameStat(PGS_DEATHS)
        playerData.append(data)
    }

    playerData.sort(PlayerScoreDataSortDesc)

    for(int i = 0; i < playerData.len(); i++)
    {
        SetTeam(playerData[i].player, i % 2 ? TEAM_MILITIA : TEAM_IMC)
    }
}

int function PlayerScoreDataSortDesc(PlayerScoreData a, PlayerScoreData b)
{
    if( a.score < b.score )
        return 1
    else if ( a.score > b.score )
        return -1
    
    return 0
}