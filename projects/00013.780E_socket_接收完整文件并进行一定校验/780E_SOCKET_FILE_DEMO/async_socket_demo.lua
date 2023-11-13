-- netlab.luatos.com上打开TCP，然后修改IP和端口号，自动回复netlab下发的数据，自收自发测试
local server_ip = "112.125.89.8"
local server_port = 47504

local rxbuf = zbuff.create(8192)

local function netCB(netc, event, param)
    if param ~= 0 then
        sys.publish("socket_disconnect")
        return
    end
    if event == socket.LINK then
    elseif event == socket.ON_LINE then
        socket.tx(netc, "hello,luatos!")
    elseif event == socket.EVENT then
        socket.rx(netc, rxbuf)
        socket.wait(netc)
        if rxbuf:used() > 0 then
            -- log.info("收到1", rxbuf:read(4))
            log.info("收到2", rxbuf:toStr(0, rxbuf:used()):toHex())
            --给服务器回复0301
            socket.tx(netc,string.char("0x03","0x01"))

            OAT_data(rxbuf:toStr(0, rxbuf:used()))

        end
        rxbuf:del()
    elseif event == socket.TX_OK then
        socket.wait(netc)
        log.info("发送完成")
    elseif event == socket.CLOSE then
        sys.publish("socket_disconnect")
    end
end

-- 服务器下载升级包的逻辑
function OAT_data(data)
    log.info("解析前数据包内容", data,"长度",#data,"hex看",data:toHex())
    updata_hear = string.char(0x80,0x31)
    if data == updata_hear or data:sub(1,2) == updata_hear then
        log.info("进入传输升级包的逻辑")
        local OAT_data = data:sub(2, -1)
        log.info("实际升级包内容为", OAT_data:toHex())
        io_update(OAT_data)
    else
        log.info("不是升级逻辑，我看看实际数传内容", data,
                 "HEX显示为", data)
    end
end

-- 文件读写方式写完升级包的逻辑
function io_update(OAT_data)
    local A_single_packet = OAT_data
    local OAT_data_FILE_temp = io.open("/update.bin", "rb")
    OAT_data_FILE_temp:close()
    if OAT_data_FILE then
        if OAT_data_FILE_temp then
            -- 先关闭文件
            log.info("OTA文件存在且不为空，追加写入就行")
            local OAT_data_FILE_temp = io.open("/update.bin", "a")
            OAT_data_FILE_temp:write(A_single_packet)
            log.info("写完关文件", OAT_data_FILE_temp:close())
            local fsize = io.fileSize("/update.bin")
            if #A_single_packet < 128 and fsize and fsize> 128  then
                log.info("单包数据小于128字节且update文件大小超过了128字节，判断为最后一包数据,真正进入模块升级流程")
            end
        else
            log.info("OAT文件存在但是为空，从头写入")
            local OAT_data_FILE_temp = io.open("/xxx.txt", "wb")
            OAT_data_FILE:write(A_single_packet)
            log.info("写完关文件", OAT_data_FILE:close())

        end
    else
        log.info("OTA文件不存在，重新创建OTA文件")
        make_OAT_data_FILE()
        -- 创建完成后，重新进入写ota文件的步骤
        io_update()
    end

end

local function socketTask()
    local netc = socket.create(nil, netCB)
    socket.debug(netc, true)
    socket.config(netc, nil, nil, nil, 300, 5, 6) -- 开启TCP保活，防止长时间无数据交互被运营商断线
    while true do
        local succ, result = socket.connect(netc, server_ip, server_port)
        if not succ then
            log.info("未知错误，5秒后重连")
        else
            local result, msg = sys.waitUntil("socket_disconnect")
        end
        log.info("服务器断开了，5秒后重连")
        socket.close(netc)
        log.info(rtos.meminfo("sys"))
        sys.wait(5000)
    end
end

function socketDemo()
    mobile.rtime(1)
    sys.taskInit(socketTask)
end

OAT_data_FILE = nil

-- 开机就执行，创建一个空升级包的逻辑
function make_OAT_data_FILE()
    -- 先创建一个空的升级包写入文件
    OAT_data_FILE = io.open("/update.bin", "wb")

    if OAT_data_FILE then
        log.info("空的升级文件创建成功")
        OAT_data_FILE:close()
    end
end

make_OAT_data_FILE()

socketDemo()
