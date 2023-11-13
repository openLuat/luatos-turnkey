apiSetCb("netlab",function (data)
  log.info(
    "netlab received",
    data.client,
    data.data)
    
apiSend("netlab",nil,
{
  client = data.client,
  data   = data.data.."received!"
})
end)