global function ServerChatCommand_Give_Init
global function Fire_Give
global function Fire_GiveWeapon
global function Fire_GiveMelee

void function ServerChatCommand_Give_Init()
{
    AddChatCommandCallback( "/give", ServerChatCommand_Give )
}

void function ServerChatCommand_Give( entity player, array<string> args )
{
    if ( !Fire_IsPlayerAdmin( player ) ){
        Fire_ChatServerPrivateMessage( player, "你没有管理员权限" )
        return
    }
    if ( args.len() != 2 ){
        Fire_ChatServerPrivateMessage( player, "用法：/give <武器ID> <玩家名称/all>" )
        return
    }

    string args0 = args[0]
    string args1 = args[1]

    string weaponType = Fire_GetWeaponType( args0 )
    if( weaponType == "unknown" )
    {
        Fire_ChatServerPrivateMessage( player, "未知武器ID: " + args0 )
        return
    }

    array<entity> targets
    switch(args1){
        case "all":
            targets = GetPlayerArray()
            break
        default:
            targets = GetPlayersByNamePrefix(args1)
            break
    }

    if(targets.len() == 0)
    {
        Fire_ChatServerPrivateMessage( player, "未找到玩家: " + args1 )
        return
    }

    foreach( target in targets )
    {
        if( !IsValid( target ) || !IsAlive( target ) ){
            Fire_ChatServerPrivateMessage(player, "玩家 " + target.GetPlayerName() + " 无效或死亡")
            continue
        }
        Fire_Give( target, args0 )
        Fire_ChatServerPrivateMessage( player, "已给予玩家 " + target.GetPlayerName() + " 武器 " + args0 )
    }
}

void function Fire_Give( entity player, string weaponId )
{
    string weaponType = Fire_GetWeaponType( weaponId )

    switch ( weaponType )
    {
        case "melee":
            Fire_GiveMelee( player, weaponId )
            break
        case "ability":
        case "titan_ability":
            ReplacePlayerOffhand( player, weaponId )
            break
        case "titan_core":
            player.TakeOffhandWeapon( OFFHAND_EQUIPMENT )
            player.GiveOffhandWeapon( weaponId, OFFHAND_EQUIPMENT )
            break
        case "titan_weapon":
        case "turret_weapon":
        case "weapon":
            Fire_GiveWeapon( player, weaponId )
            break
    }
}

void function Fire_GiveWeapon( entity ent, string weaponId, array<string> mods = [] )
{
    try{
        entity activeWeapon = ent.GetActiveWeapon()
        if( IsValid( activeWeapon ) )
        {
            ent.TakeWeaponNow( activeWeapon.GetWeaponClassName() )
        }
    
        ent.GiveWeapon( weaponId, mods )
        ent.SetActiveWeaponByName( weaponId )
    }catch(error){
    }
}

void function Fire_GiveMelee( entity ent, string meleeId )
{
    ent.TakeOffhandWeapon( OFFHAND_MELEE )
    ent.GiveOffhandWeapon( meleeId, OFFHAND_MELEE )
}

string function Fire_GetWeaponType( string weaponId )
{
    table<string, string> weaponPrefixes = {
        melee_ = "melee",
        mp_ability_ = "ability",
        mp_titanability_ = "titan_ability",
        mp_titancore_ = "titan_core",
        mp_titanweapon_ = "titan_weapon",
        mp_turretweapon_ = "turret_weapon",
        mp_weapon_ = "weapon"
    }
    
    foreach( string prefix, string type in weaponPrefixes )
    {
        if ( weaponId.find( prefix ) == 0 )
            return type
    }
    
    return "unknown"
}

string function ConcatArray( array<string> strings, string separator = " " )
{
    if ( strings.len() == 0 )
        return ""
    
    string result = strings[0]
    for ( int i = 1; i < strings.len(); i++ )
    {
        result += separator + strings[i]
    }
    
    return result
}