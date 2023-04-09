--[[
    Author: RainChain-Zero rainchain@foxmail.com
    Date: 2022-09-06 08:12:18
    LastEditors: RainChain-Zero rainchain@foxmail.com
    LastEditTime: 2022-09-06 08:12:31
    Description: 使用于群范围内的跑团笔记
--]]
msg_order = {
    ["/记录"] = "write_note",
    ["/查看记录"] = "read_note",
    ["/删除记录"] = "del_note",
    ["/清空记录"] = "clear_note"
}
--[[
    Data structure:
    groupID: {
        {
            qq: 123456789,
            note: "note"
        }
    }
]]
-- 写记录
function write_note(msg)
    local note = string.match(msg.fromMsg, "[%s]*(.+)", #"/记录" + 1)
    if note == nil then
        return "记录内容不能为空"
    end
    local note_table = getGroupConf(msg.gid, "note", {})
    table.insert(note_table, {qq = msg.fromQQ, note = note})
    setGroupConf(msg.gid, "note", note_table)
    return "{self}已经为记录成功了哦~"
end

-- 读记录
function read_note(msg)
    local note_table = getGroupConf(msg.gid, "note", {})
    local note = "当前笔记——\n"
    for i = 1, #note_table do
        note =
            note ..
            tostring(i) ..
                ". " ..
                    note_table[i].note .. "（" .. getUserConf(note_table[i].qq, "nick#" .. msg.gid, "获取群名片失败") .. "）\n"
    end
    return note
end

-- 删记录
function del_note(msg)
    local note_table = getGroupConf(msg.gid, "note", {})
    local index = string.match(msg.fromMsg, "[%s]*(%d+)", #"/删除记录")
    if index == nil then
        return "请输入要删除的记录的序号"
    end
    index = tonumber(index)
    if index < 1 or index > #note_table then
        return "序号超出范围"
    end
    table.remove(note_table, index)
    setGroupConf(msg.gid, "note", note_table)
    return "{self}已经将该条删除记录成功了哦~"
end

-- 清空记录
function clear_note(msg)
    setGroupConf(msg.gid, "note", nil)
    return "{self}已经将所有记录清空成功了哦~"
end
