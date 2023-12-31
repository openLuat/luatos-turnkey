--循环发送快捷发送区数据

---例子一
--发送数据中间间隔时间（单位ms）
local sendDelay = 100

--待发送数据的顺序
local sendList = "AT+CGNSAZIMUTH?"
--你也可以用下面的代码批量生成
--从2号发到15号数据

---for i=2,99 do
 --   table.insert(sendList, i)
--end

sys.taskInit(function ()
    while true do
        for _,i in pairs(sendList) do
            local data = apiQuickSendList(i)
            if data then
                log.info("send data",apiSendUartData(data),data)
            end
            sys.wait(sendDelay)
        end
    end
end)


--[[
sys.taskInit(function()
	while 1 do 
		local sendResult = apiSend("mqtt",nil,
		{
		  topic   = "/HH/PUB",
		  payload = "config,readconfig",
		  qos     = 0
		})
		
		sys.wait(200)
	end
end)
]]

--[[
---例子二
--待发送数据的顺序和延时时间
local sendList = {
    {1,1000},
    {3,500},
    {2,2000},
    {4,300},
    {5,6000},
    {6,1500},
}

sys.taskInit(function ()
    while true do
        for _,i in pairs(sendList) do
            local data = apiQuickSendList[i[1] ]
            if data then
                log.info("send data",apiSendUartData(data),data)
            end
            sys.wait(i[2])
        end
    end
end)
]]
