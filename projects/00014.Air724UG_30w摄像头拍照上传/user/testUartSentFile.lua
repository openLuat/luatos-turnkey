--- 模块功能：串口功能测试(非TASK版，串口帧有自定义的结构)
-- @author openLuat
-- @module uart.testUartTask
-- @license MIT
-- @copyright openLuat
-- @release 2018.05.24
module(..., package.seeall)

require "utils"
require "pm"

local uartID = uart.USB
--local uartID = 1

function sendFile()
    sys.taskInit(function()
        local fileHandle = io.open("/test.jpg", "rb")
        if not fileHandle then
            log.error("testALiYun.otaCb1 open file error")
            return
        else
            log.info("要发给虚拟AT口的文件存在")
            -- 先给对应的串口工具发送标识符
            -- local original_document_len = tostring(io.fileSize("/test.jpg"))
            -- local prefix = "Air105 USB JPG " .. original_document_len .. "\r\n"
            -- log.info("前缀为", prefix, "前缀大小为", #prefix,"前缀的类型为", type(prefix))
            -- log.info("从虚拟AT口发出的前缀字节数为",uart.send(uartID, prefix))
        end

        pm.wake("UART_SENT2MCU")
        uart.on(uartID, "sent", function() sys.publish("UART_SENT2MCU_OK") end)
        --因为用的是虚拟AT口，所以可以提高波特率
        uart.setup(uartID, 921600, 8, uart.PAR_NONE, uart.STOP_1, nil, 1, 0, 1)

        while true do
            local data = fileHandle:read(1460)
            if not data then
                log.info("发送数据完成")
                break
            end
            log.info("虚拟AT口发送数据", uart.write(uartID, data))
            sys.wait(10)
        end

        uart.close(uartID)
        pm.sleep("UART_SENT2MCU")
        fileHandle:close()
    end)
end


