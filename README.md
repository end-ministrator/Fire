# Fire

[BiliBili](https://space.bilibili.com/3493268113328579) | [GitHub](https://github.com/MiyamaeNonoa/Fire/tree/main) | [提交问题](https://github.com/MiyamaeNonoa/Fire/issues)

## 概述
Fire 是一个提供多项游戏管理功能的插件(到底该叫做插件还是模组qwq)

### 添加管理员
修改mod.json文件中的 `Fire_AdminUIDs` 项，支持多个管理员 UID，请使用英文逗号分隔。

**示例：**

```
Fire_AdminUIDs "1013199872353,1234567890123,9876543210987"
```

## 配置项

| 配置项 | 用途 | 默认值 | 取值说明 |
| :--- | :--- | :--- | :--- |
| **Fire_AntiAFKEnabled** | 启用或禁用反挂机系统 | `"0"` | `"0"`：禁用<br>`"1"`：启用 |
| **Fire_ChatEnabled** | 启用或禁用游戏内聊天功能 | `"1"` | `"0"`：禁用<br>`"1"`：启用 |
| **Fire_AimAssisEnabled** | 启用或禁用辅助瞄准功能 | `"1"` | `"0"`：禁用<br>`"1"`：启用 |
| **Fire_AdminJoinBroadcastEnabled** | 管理员加入时是否全服广播 | `"0"` | `"0"`：不广播<br>`"1"`：向所有玩家广播 |

# 聊天命令
- `/aa <on/off>`
- `/afk <on/off>`
- `/ajb <on/off>`
- `/bal < 1/2/3 >`
- `/tp <name/all> <name>`
- `/ban <name>`
- `/kick <name> [reason]`
- `/cb <ash/viper/richter/slone/kane/blisk/all>`
- `/kab`
- `/cheats <on/off>`
- `/core <name/all/imc/militia> <core>`
- `/csb msg`
- `/danmaku msg`
- `/tf <name/all/imc/militia>`
- `/eject <name/all/imc/militia>`
- `/fly <name/all/imc/militia> <height>`
- `/fold <start/stop>`
- `/give <weaponId> <name/all>`
- `/god <name/all/imc/militia>`
- `/hack <name>`
- `/man <name/all>`
- `/map <map>`
- `/skip`
- `/kill <name/all/imc/militia>`
- `/hide <name/all/imc/militia>`
- `/show <name/all/imc/militia>`
- `/hp <name/all/imc/militia> <health>`
- `/mhp <name/all/imc/militia> <maxHealth>`
- `/noclip <name/all/imc/militia>`
- `/ogre <name/all>`
- `/uid <name>`
- `/pl`
- `/rf <team> <quantity>`
- `/ring <ring类型> <name/all> [持续时间]`
- `/stop [reason]`
- `/chat <on/off>`
- `/mute <name> [时间(秒)]`
- `/unmute <name>`
- `/sbc <name>`
- `/team <name/all/imc/militia> <team>`
- `/checkver`
- `/swit <name/all/imc/militia>`

# 回调
### **聊天命令函数（ChatCommands.gnut）**

| 函数                        | 作用                             | 返回值 | 说明                              |
| :-------------------------- | :------------------------------- | :----- | :-------------------------------- |
| `AddChatCommandCallback`    | 注册一个新的聊天命令及其回调函数 | `bool` | 成功返回 `true`，失败返回 `false` |
| `SetChatCommandCallback`    | 修改已注册聊天命令的回调函数     | `bool` | 只能修改已存在的命令              |
| `IsChatCommandRegistered`   | 检查聊天命令是否已注册           | `bool` | 存在返回 `true`，否则 `false`     |
| `RemoveChatCommandCallback` | 移除已注册的聊天命令             | `bool` | 移除成功返回 `true`               |

------

### **控制台命令函数（ConsoleCommands.gnut）**

| 函数                           | 作用                               | 返回值 | 说明                              |
| :----------------------------- | :--------------------------------- | :----- | :-------------------------------- |
| `AddConsoleCommandCallback`    | 注册一个新的控制台命令及其回调函数 | `bool` | 成功返回 `true`，失败返回 `false` |
| `SetConsoleCommandCallback`    | 修改已注册控制台命令的回调函数     | `bool` | 只能修改已存在的命令              |
| `IsConsoleCommandRegistered`   | 检查控制台命令是否已注册           | `bool` | 存在返回 `true`，否则 `false`     |
| `RemoveConsoleCommandCallback` | 移除已注册的控制台命令             | `bool` | 移除成功返回 `true`               |

## **示例代码（聊天命令）**

```squirrel
AddChatCommandCallback("/hello", OnChatCommand)

void function OnChatCommand(entity player, array<string> args)
{
    Fire_ChatServerPrivateMessage( player, "hello " + player.GetPlayerName() )
}
```

## **示例代码（控制台命令）**

```squirrel
AddConsoleCommandCallback("hello", OnConsoleCommand)

bool function OnConsoleCommand(entity player, array<string> args)
{
    Fire_ChatServerPrivateMessage( player, "hello " + player.GetPlayerName() )
    return true
}
```

## Fire v1.2.0 更新日志

### 新功能

- 添加版本检测功能，管理员会自动收到新版本通知
- 新增 [/checkver](javascript:void(0)) 命令，允许管理员手动检查版本更新

### 改进与重构

- 所有聊天命令脚本文件重命名为 `sv_` 前缀。
- 提取通用工具函数到 [sh_util.gnut](javascript:void(0))。
- 重构HUD消息优先级队列系统。

### 文档更新

- 在 [README.md](javascript:void(0)) 中添加了 [/checkver](javascript:void(0)) 命令说明
