global function ChatCommand_Script_Init

void function ChatCommand_Script_Init()
{
    AddChatCommandCallback( "/script", ChatCommand_Script )
}

void function ChatCommand_Script(entity player, array<string> args)
{
    if( !Fire_IsPlayerAdmin( player ) ){
        Fire_ChatServerPrivateMessage(player, "你没有管理员权限")
        return
    }
    if( args.len() == 0 ){
        Fire_ChatServerPrivateMessage(player, "用法: /script <code>")
        return
    }
    string code = ""
    for(int i; i < args.len(); i++)
    {
        code += args[i] + " "
    }
    ServerCommand(code)
}