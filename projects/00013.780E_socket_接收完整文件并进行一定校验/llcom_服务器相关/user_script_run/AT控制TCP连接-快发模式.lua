--适用于合宙Air202/Air720 AT TCP连接测试
local server,ip = "180.97.80.55","12415"

--每次发送的数据内容
local data = string.rep("123",20)
--服务器信息
local server,ip = "112.125.89.8","34720"

local torev = "OK"
--注册串口接收函数
uartReceive = function (data)
    log.info("uart receive")
    if data:find(torev) then
        sys.publish("UART",data)--发布消息
    end
end

--循环跑某命令，直到成功
function rollRun(cmd,receive,timeout)
    if not timeout then timeout = 1000 end
    while true do
        torev = receive
        if cmd=="+++" then
        log.info("uart send",apiSendUartData(cmd))
        end
        log.info("uart send",apiSendUartData(cmd.."\r\n"))
        local r,d = sys.waitUntil("UART",timeout)
        if r then break end
    end
end

sys.taskInit(function ()
    --检查是否可收发at
    log.info("check start")
    rollRun("AT","OK")

    --关闭回显
    log.info("close back")
    rollRun("ATE0","OK")

    --查看at版本
    log.info("check version")
    rollRun("ATI","OK")

    --检查卡是否识别
    log.info("check sim card")
    rollRun("AT+CPIN?","+CPIN: READY")

	--透传
    log.info("set cipmode")
    rollRun("AT+CIPMODE=1","OK",5000)

    --检查是否附着上网络
    log.info("check network")
    rollRun("AT+CGATT?","+CGATT: 1")

 
    --快发模式
    log.info("set cipmode")
    rollRun("AT+CIPQSEND=1","OK",5000)

   

    --设置vpn
    log.info("set apn")
    rollRun('AT+CSTT="CMIOT"',"OK",5000)

    --激活移动场景
    log.info("AT+CIICR")
    rollRun("AT+CIICR","OK",5000)

    --检查ip
    log.info("check ip")
    rollRun("AT+CIFSR","%.",1000)

    --连接服务器
    log.info("connect server")
    rollRun([[AT+CIPSTART="TCP","]]..server..[[",]]..ip,"CONNECT",5000)

    while true do
        --发送数据请求
        --log.info("start send data")
        --rollRun("AT+CIPSEND="..tostring(data:len()),">",1000)
        

log.info("退出透传")
rollRun("+++","OK")
        --数据内容
        log.info("退出本次连接")
        rollRun("AT+CIPSHUT","OK",5000)

        sys.wait(5000)
    end
end)



