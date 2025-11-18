global function ServerChatCommand_Ring_Init
global function CreateRing

struct RingData
{
    entity ring
    entity owner
    float createTime
}

array<RingData> rings = []

void function ServerChatCommand_Ring_Init()
{
    PrecacheSprite( $"materials/vgui/hud/weapons/target_ring_mid_pilot.vmt" )
    PrecacheSprite( $"materials/vgui/hud/weapons/target_ring_front_pilot.vmt" )
    PrecacheSprite( $"materials/vgui/hud/weapons/target_ring_back.vmt" )

    AddChatCommandCallback( "/ring", ServerChatCommand_Ring )
}

void function ServerChatCommand_Ring(entity player, array<string> args)
{
    if(!Fire_IsPlayerAdmin(player))
    {
        Fire_ChatServerPrivateMessage(player, "你没有管理员权限")
        return
    }

    if(args.len() == 0)
    {
        Fire_ChatServerPrivateMessage(player, "用法: /ring <ring类型> <玩家名称/all> [持续时间]")
        Fire_ChatServerPrivateMessage(player, "类型: 1=中环, 2=前环, 3=后环, clear=清除所有环")
        return
    }

    string command0 = args[0].tolower()

    if(command0 == "clear" || command0 == "c")
    {
        int count = 0
        foreach(ringData in rings)
        {
            if(IsValid(ringData.ring))
            {
                ringData.ring.Destroy()
                count++
            }
        }
        rings.clear()
        Fire_ChatServerPrivateMessage(player, "已清除 " + count + " 个环")
        return
    }

    if(args.len() < 2)
    {
        Fire_ChatServerPrivateMessage(player, "用法：/ring <ring类型> <玩家名称/all> [持续时间]")
        Fire_ChatServerPrivateMessage(player, "类型: 1=中环, 2=前环, 3=后环, clear=清除所有环")
        return
    }

    asset ringAsset
    switch(command0)
    {
        case "1":
            ringAsset = $"materials/vgui/hud/weapons/target_ring_mid_pilot.vmt"
            break
        case "2":
            ringAsset = $"materials/vgui/hud/weapons/target_ring_front_pilot.vmt"
            break
        case "3":
            ringAsset = $"materials/vgui/hud/weapons/target_ring_back.vmt"
            break
        default:
            Fire_ChatServerPrivateMessage(player, "无效的环类型。可用: 1=中环, 2=前环, 3=后环")
            return
    }

    string targetName = args[1]
    array<entity> targets
    if(targetName.tolower() == "all")
    {
        targets = GetPlayerArray()
    }
    else
    {
        targets = GetPlayersByNamePrefix(targetName)
    }

    if(targets.len() == 0)
    {
        Fire_ChatServerPrivateMessage(player, "未找到玩家: " + targetName)
        return
    }

    float duration = 0
    if(args.len() > 2)
    {
        duration = args[2].tofloat()
        if(duration <= 0)
        {
            Fire_ChatServerPrivateMessage(player, "持续时间必须为正数")
            return
        }
    }

    foreach(target in targets)
    {
        if(!IsValid(target) || !IsAlive(target))
            continue

        vector targetOrigin = target.GetOrigin()
        vector targetAngles = target.EyeAngles()

        entity ring = CreateRing(targetOrigin, targetAngles, ringAsset, "0 255 0", 0.5, 5)
        SetTeam(ring, player.GetTeam())
        ring.SetOwner(player)
        
        ring.kv.fade_dist = 999999999
        ring.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE
        
        RingData ringData
        ringData.ring = ring
        ringData.owner = player
        ringData.createTime = Time()
        rings.append(ringData)

        if(duration > 0)
        {
            thread DestroyRingAfterDelay(ring, duration)
        }
        
        Fire_ChatServerPrivateMessage(player, "成功为玩家 " + target.GetPlayerName() + " 创建环" + (duration > 0 ? "，持续 " + duration + " 秒" : ""))
    }
    return
}

void function DestroyRingAfterDelay(entity ring, float delay)
{
    wait delay
    if(IsValid(ring))
    {
        ring.Destroy()
        
        for(int i = rings.len() - 1; i >= 0; i--)
        {
            if(rings[i].ring == ring)
            {
                rings.remove(i)
                break
            }
        }
    }
}

entity function CreateRing(vector origin, vector angles, asset sprite, string lightcolor = "255 0 0", float scale = 0.5, int rendermode = 10)
{
    entity env_sprite = CreateEntity("env_sprite")
    env_sprite.SetScriptName(UniqueString("ring_sprite"))
    env_sprite.kv.rendermode = rendermode
    env_sprite.kv.origin = origin
    env_sprite.kv.angles = angles
    env_sprite.kv.rendercolor = lightcolor
    env_sprite.kv.renderamt = 255
    env_sprite.kv.framerate = "30.0"
    env_sprite.SetValueForModelKey(sprite)
    env_sprite.kv.scale = string(scale)
    env_sprite.kv.spawnflags = 1
    env_sprite.kv.GlowProxySize = 64.0
    env_sprite.kv.HDRColorScale = 4.0
    DispatchSpawn(env_sprite)
    EntFireByHandle(env_sprite, "ShowSprite", "", 0, null, null)

    return env_sprite
}