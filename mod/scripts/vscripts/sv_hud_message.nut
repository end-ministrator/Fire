global function HudMessage_Init
global function SendHudMessageWithPriority

table< string, table<string, float> > playerMsgPriorities = {}

table< string, array<string> > playerPriorityOrder = {}

/**
 * 初始化HUD消息队列系统，注册玩家连接回调用于数据初始化。
 */
void function HudMessage_Init()
{
    AddCallback_OnClientConnected( OnClientConnected )
}

/**
 * 玩家连接时初始化玩家对应的优先级和队列表。
 * @param player 玩家实体（entity）
 */
void function OnClientConnected( entity player )
{
    string uid = player.GetUID()
    playerMsgPriorities[uid] <- {}
    playerPriorityOrder[uid] <- []
}

/**
 * 发送带优先级的HUD消息（支持淡入、显示、淡出）。
 * @param player 玩家实体
 * @param priority 当前消息优先级（float）
 * @param text HUD内容
 * @param yaw yaw值
 * @param pos pos值
 * @param rgb RGB颜色向量
 * @param time 时间向量 <淡入, 显示, 淡出>（float类型）
 * @param priorityOnFadeout 淡出阶段的优先级（默认90）
 */
void function SendHudMessageWithPriority( entity player, float priority, var text, float yaw, float pos, vector rgb, vector time, float priorityOnFadeout = 90 )
{
    thread _HudMsgQueue_SendThread( player, _HudMsgQueue_ReserveId( player, priority ), string(text), yaw, pos, rgb, time, priorityOnFadeout )
}

/**
 * 为玩家分配一个未用的消息ID，并记录优先级。
 * @param player 玩家实体
 * @param priority 消息优先级
 * @return 新分配的消息ID（string）
 */
string function _HudMsgQueue_ReserveId( entity player, float priority )
{
    string uid = player.GetUID()
    int i = 1
    while (true)
    {
        string id = string(i)
        if (!(id in playerMsgPriorities[uid]))
        {
            playerMsgPriorities[uid][id] <- priority
            return id
        }
        i++
    }
    unreachable
}

/**
 * 移除玩家某消息ID的优先级和队列中的引用。
 * @param player 玩家实体
 * @param id 消息ID
 */
void function _HudMsgQueue_ReleaseId( entity player, string id )
{
    string uid = player.GetUID()
    playerPriorityOrder[uid].removebyvalue(id)
    if (id in playerMsgPriorities[uid])
        delete playerMsgPriorities[uid][id]
}

/**
 * 判断某消息ID当前是否可以显示（优先级队列中的队首）。
 * @param player 玩家实体
 * @param id 消息ID
 * @return 是否允许发送（bool），true为最高优先级允许发送
 */
bool function _HudMsgQueue_CanSend( entity player, string id )
{
    string uid = player.GetUID()
    array<string> order = playerPriorityOrder[uid]
    return order.len() > 0 && order[0] == id
}

/**
 * 将消息ID按优先级插入玩家消息队列（高优先级靠前）。
 * @param player 玩家实体
 * @param id 消息ID。
 */
void function _HudMsgQueue_Queue( entity player, string id )
{
    string uid = player.GetUID()
    float priority = playerMsgPriorities[uid][id]

    array<string> order = playerPriorityOrder[uid]
    int insertPos = order.len()
    foreach (i, listedId in order)
    {
        if (priority >= playerMsgPriorities[uid][listedId])
        {
            insertPos = i
            break
        }
    }
    order.insert(insertPos, id)
    playerPriorityOrder[uid] = order
}

/**
 * 负责处理HUD消息的淡入、显示、淡出线程发送逻辑。
 * @param player 玩家实体
 * @param id 当前阶段的消息ID
 * @param text 消息内容
 * @param yaw yaw值
 * @param pos pos值
 * @param rgb 初始RGB颜色
 * @param time 时间向量 <淡入, 显示, 淡出>
 * @param priorityOnFadeout 淡出时优先级
 */
void function _HudMsgQueue_SendThread( entity player, string id, string text, float yaw, float pos, vector rgb, vector time, float priorityOnFadeout )
{
    player.EndSignal("OnDestroy")
    string uid = player.GetUID()

    // 淡入阶段
    if (time.x > 0)
    {
        int ticks = int(time.x * 10)
        vector fadeStart = <0, 0, 0>
        vector fadeStep = <rgb.x / ticks, rgb.y / ticks, rgb.z / ticks>
        _HudMsgQueue_Queue(player, id)
        _HudMsgQueue_WhileSend(player, id, text, yaw, pos, fadeStart, fadeStep, ticks)
    }
    // 正常显示阶段
    if (time.y > 0)
    {
        int ticks = int(time.y * 10)
        vector fadeStep = <0, 0, 0>
        _HudMsgQueue_Queue(player, id)
        _HudMsgQueue_WhileSend(player, id, text, yaw, pos, rgb, fadeStep, ticks)
    }
    _HudMsgQueue_ReleaseId(player, id)

    // 淡出阶段
    if (time.z <= 0) return
    string fadeOutId = _HudMsgQueue_ReserveId(player, priorityOnFadeout)
    int ticks = int(time.z * 10)
    vector fadeStep = <rgb.x / ticks, rgb.y / ticks, rgb.z / ticks> * -1
    _HudMsgQueue_Queue(player, fadeOutId)
    _HudMsgQueue_WhileSend(player, fadeOutId, text, yaw, pos, rgb, fadeStep, ticks)
    _HudMsgQueue_ReleaseId(player, fadeOutId)
}

/**
 * 循环发送HUD消息，并递增颜色淡化，只有当前为最高优先级时允许发送。
 * @param player 玩家实体
 * @param id 消息ID
 * @param text 消息内容
 * @param yaw yaw值
 * @param pos pos值
 * @param rgb 当前颜色
 * @param fadeStep 每tick颜色变化值
 * @param ticks 循环次数（持续tick数）
 */
void function _HudMsgQueue_WhileSend( entity player, string id, string text, float yaw, float pos, vector rgb, vector fadeStep, int ticks )
{
    for (int i = 0; i < ticks; i++)
    {
        rgb += fadeStep
        if (_HudMsgQueue_CanSend(player, id))
            SendHudMessage(player, text, yaw, pos, int(rgb.x), int(rgb.y), int(rgb.z), 255, 0, 0.2, 0.0)
        WaitFrame()
    }
}