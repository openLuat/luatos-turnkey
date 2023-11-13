-- bin文件路径
local binPath = [[C:\Users\user\Desktop\test111\testNvm.lua]]
-- bin固件分包大小
local packSize = 128
-- 服务器->模块发的数据/数据头
local s2c = string.char(0x80, 0x31)
-- 模块->服务器回复的数据
local c2s = string.char(0x03, 0x01)

local binf = io.open(binPath, "rb")
bin = binf:read("*all")
binf:close()

local clientInfo = {}
apiSetCb("netlab", function(data)
    if data.client == "connected" then
        log.info("连上了新设备", data.data)
        apiSend("netlab", nil, {client = data.data, data = s2c})
        clientInfo[data.data] = 0
    elseif data.client == "disconnected" then
        log.info("断开", data.data)
        clientInfo[data.data] = nil
    elseif data.data == c2s and clientInfo[data.client] then
        local pack = bin:sub(clientInfo[data.client] + 1,
                             clientInfo[data.client] + packSize)
        clientInfo[data.client] = clientInfo[data.client] + packSize
        apiSend("netlab", nil, {client = data.client, data = s2c .. pack})
        if clientInfo[data.client] >= #bin then
            log.info("固件发完了", data.client)
            clientInfo[data.client] = nil
        end
    end
end)