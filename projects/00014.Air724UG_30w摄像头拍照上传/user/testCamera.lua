--- 模块功能：camera功能测试.
-- @author openLuat
-- @module fs.testFs
-- @license MIT
-- @copyright openLuat
-- @release 2018.03.27
module(..., package.seeall)

require "pm"
require "scanCode"
require "utils"
require "common"
require "testUartSentFile"
require "http"

--[[
功能定义：
通过USB虚拟AT口发数据到“摄像头预览”软件中，只通过电脑即可实现图片预览
详情见文：https://doc.openluat.com/wiki/21?wiki_page_id=5087
]]

local WIDTH, HEIGHT = disp.getlcdinfo()
local DEFAULT_WIDTH, DEFAULT_HEIGHT = 640, 480

local gc0310_ddr_big = {
    zbar_scan = 0,
    i2c_addr = 0x21,
    sensor_width = 640,
    sensor_height = 480,
    id_reg = 0xf1,
    id_value = 0x10,
    spi_mode = disp.CAMERA_SPI_MODE_LINE2,
    spi_speed = disp.CAMERA_SPEED_DDR,
    spi_yuv_out = disp.CAMERA_SPI_OUT_Y1_V0_Y0_U0,

    init_cmd = {

        0xfe, 0xf0, 0xfe, 0xf0, 0xfe, 0x00, 0xfc, 0x16, 0xfc, 0x16, 0xf2, 0x07,
        0xf3, 0x83, 0xf5, 0x07, 0xf7, 0x89, 0xf8, 0x01, 0xf9, 0x4f, 0xfa, 0x11,

        0xfc, 0xce, 0xfd, 0x00, 0x00, 0x2f, 0x01, 0x0f, 0x02, 0x04, 0x03, 0x02,
        0x04, 0x12, 0x09, 0x00, 0x0a, 0x00, 0x0b, 0x00, 0x0c, 0x04, 0x0d, 0x01,
        0x0e, 0xe8, 0x0f, 0x02, 0x10, 0x88, 0x16, 0x00, 0x17, 0x14, 0x18, 0x1a,
        0x19, 0x14, 0x1b, 0x48, 0x1c, 0x6c, 0x1e, 0x6b, 0x1f, 0x28, 0x20, 0x8b,

        0x21, 0x49, 0x22, 0xd0, 0x23, 0x04, 0x24, 0xff, 0x34, 0x20, 0x26, 0x23,
        0x28, 0xff, 0x29, 0x00, 0x32, 0x04, 0x33, 0x10, 0x37, 0x20, 0x38, 0x10,
        0x47, 0x80, 0x4e, 0x66, 0xa8, 0x02, 0xa9, 0x80, 0x40, 0xff, 0x41, 0x21,
        0x42, 0xcf, 0x44, 0x02, 0x45, 0xa8, 0x46, 0x02, 0x4a, 0x11, 0x4b, 0x01,
        0x4c, 0x20, 0x4d, 0x05, 0x4f, 0x01, 0x50, 0x01, 0x55, 0x01, 0x56, 0xe0,
        0x57, 0x02, 0x58, 0x80, 0x70, 0x70, 0x5a, 0x84, 0x5b, 0xc9, 0x5c, 0xed,
        0x77, 0x74, 0x78, 0x40, 0x79, 0x5f, 0x82, 0x08, 0x83, 0x0b, 0x89, 0xf0,

        0x8f, 0xaa, 0x90, 0x8c, 0x91, 0x90, 0x92, 0x03, 0x93, 0x03, 0x94, 0x05,
        0x95, 0x43, 0x96, 0xf0, 0xfe, 0x00, 0x9a, 0x20, 0x9b, 0x80, 0x9c, 0x40,
        0x9d, 0x80, 0xa1, 0x30, 0xa2, 0x32, 0xa4, 0x80, 0xa5, 0x28, 0xaa, 0x30,
        0xac, 0x22, 0xfe, 0x00, 0xbf, 0x08, 0xc0, 0x16, 0xc1, 0x28, 0xc2, 0x41,
        0xc3, 0x5a, 0xc4, 0x6c, 0xc5, 0x7a, 0xc6, 0x96, 0xc7, 0xac, 0xc8, 0xbc,
        0xc9, 0xc9, 0xca, 0xd3, 0xcb, 0xdd, 0xcc, 0xe5, 0xcd, 0xf1, 0xce, 0xfa,
        0xcf, 0xff, 0xd0, 0x40, 0xd1, 0x38, 0xd2, 0x38, 0xd3, 0x50, 0xd6, 0xf2,
        0xd7, 0x1b, 0xd8, 0x18, 0xdd, 0x03, 0xfe, 0x01, 0x05, 0x30, 0x06, 0x75,
        0x07, 0x40, 0x08, 0xb0, 0x0a, 0xc5, 0x0b, 0x11, 0x0c, 0x00, 0x12, 0x52,
        0x13, 0x38, 0x18, 0x95, 0x19, 0x96, 0x1f, 0x20, 0x20, 0xc0, 0x3e, 0x40,
        0x3f, 0x57, 0x40, 0x7d, 0x03, 0x60, 0x44, 0x02, 0xfe, 0x01, 0x1c, 0x91,
        0x21, 0x15, 0x50, 0x80, 0x56, 0x04, 0x59, 0x08, 0x5b, 0x02, 0x61, 0x8d,
        0x62, 0xa7, 0x63, 0xd0, 0x65, 0x06, 0x66, 0x06, 0x67, 0x84, 0x69, 0x08,
        0x6a, 0x25, 0x6b, 0x01, 0x6c, 0x00, 0x6d, 0x02, 0x6e, 0xf0, 0x6f, 0x80,
        0x76, 0x80, 0x78, 0xaf, 0x79, 0x75, 0x7a, 0x40, 0x7b, 0x50, 0x7c, 0x0c,

        0x90, 0xc9, 0x91, 0xbe, 0x92, 0xe2, 0x93, 0xc9, 0x95, 0x1b, 0x96, 0xe2,
        0x97, 0x49, 0x98, 0x1b, 0x9a, 0x49, 0x9b, 0x1b, 0x9c, 0xc3, 0x9d, 0x49,
        0x9f, 0xc7, 0xa0, 0xc8, 0xa1, 0x00, 0xa2, 0x00, 0x86, 0x00, 0x87, 0x00,
        0x88, 0x00, 0x89, 0x00, 0xa4, 0xb9, 0xa5, 0xa0, 0xa6, 0xba, 0xa7, 0x92,
        0xa9, 0xba, 0xaa, 0x80, 0xab, 0x9d, 0xac, 0x7f, 0xae, 0xbb, 0xaf, 0x9d,
        0xb0, 0xc8, 0xb1, 0x97, 0xb3, 0xb7, 0xb4, 0x7f, 0xb5, 0x00, 0xb6, 0x00,
        0x8b, 0x00, 0x8c, 0x00, 0x8d, 0x00, 0x8e, 0x00, 0x94, 0x55, 0x99, 0xa6,
        0x9e, 0xaa, 0xa3, 0x0a, 0x8a, 0x00, 0xa8, 0x55, 0xad, 0x55, 0xb2, 0x55,
        0xb7, 0x05, 0x8f, 0x00, 0xb8, 0xcb, 0xb9, 0x9b, 0xfe, 0x01, 0xd0, 0x38,
        0xd1, 0x00, 0xd2, 0x02, 0xd3, 0x04, 0xd4, 0x38, 0xd5, 0x12, 0xd6, 0x30,
        0xd7, 0x00, 0xd8, 0x0a, 0xd9, 0x16, 0xda, 0x39, 0xdb, 0xf8, 0xfe, 0x01,
        0xc1, 0x3c, 0xc2, 0x50, 0xc3, 0x00, 0xc4, 0x40, 0xc5, 0x30, 0xc6, 0x30,
        0xc7, 0x10, 0xc8, 0x00, 0xc9, 0x00, 0xdc, 0x20, 0xdd, 0x10, 0xdf, 0x00,
        0xde, 0x00, 0x01, 0x10, 0x0b, 0x31, 0x0e, 0x50, 0x0f, 0x0f, 0x10, 0x6e,
        0x12, 0xa0, 0x15, 0x60, 0x16, 0x60, 0x17, 0xe0, 0xcc, 0x0c, 0xcd, 0x10,
        0xce, 0xa0, 0xcf, 0xe6, 0x45, 0xf7, 0x46, 0xff, 0x47, 0x15, 0x48, 0x03,
        0x4f, 0x60, 0xfe, 0x00, 0x05, 0x01, 0x06, 0x89, 0x07, 0x00, 0x08, 0x2a,
        0xfe, 0x01, 0x25, 0x00, 0x26, 0x6d, 0x27, 0x01, 0x28, 0xb4, 0x29, 0x02,
        0x2a, 0x8e, 0x2b, 0x02, 0x2c, 0xfb, 0x2d, 0x07, 0x2e, 0x3d, 0x3c, 0x20,

        0x50, 0x01, 0x51, 0x00, 0x52, 0x00, 0x53, 0x00, 0x54, 0x00, 0x55, 0x01,
        0x56, 0xe0, 0x57, 0x02, 0x58, 0x80, 0xfe, 0x03, 0x01, 0x00, 0x02, 0x00,
        0x10, 0x00, 0x15, 0x00, 0x17, 0x00, 0x04, 0x10, 0x05, 0x00, 0x40, 0x00,

        0x52, 0xa0, 0x53, 0x24, 0x54, 0x20, 0x55, 0x20, 0x5a, 0x00, 0x5b, 0x80,
        0x5c, 0x02, 0x5d, 0xe0, 0x5e, 0x01, 0x51, 0x03, 0x64, 0x06, 0xfe, 0x00

    }
}

--创建文件副本
function copy_file()
    local EX = io.exists("/test.jpg")
    if EX then
        log.info("副本文件存在，删除副本文件",os.remove("/test.jpg"))
    end
        local original_document_len = tostring(io.fileSize("/testCamera.jpg"))
        local prefix = "Air105 USB JPG "..original_document_len.."\r\n"
        log.info("前缀为",prefix,"前缀大小为",#prefix,"前缀的类型为",type(prefix))
        log.info("副本文件不存在新建一个，并在开头写一个前缀",io.writeFile("/test.jpg",prefix))
        log.info("写完前缀以后test.jpg的大小",io.fileSize("/test.jpg"))
        local primeval_file = io.readFile("/testCamera.jpg")
        log.info("将真实拍照的图片内容以追加的方式写个test.jpg",io.writeFile("/test.jpg",primeval_file,"a+b"))
        log.info("写完真实拍照的图片内容以后test.jpg的大小",io.fileSize("/test.jpg"))
end


function opencamera()
    --唤醒系统
    pm.wake("testopencamera")
    local ret = 0
    --打开摄像头
    --ret = disp.cameraopen(1,1) -- 内部配置的gc0310 camera
    --ret = disp.cameraopen_ext(gc6153) -- 外部配置gc6153 camera SDR
    --ret = disp.cameraopen_ext(gc0310_sdr) -- 外部配置gc0310 camera SDR
	ret = disp.cameraopen_ext(gc0310_ddr_big) -- 外部配置gc0310 camera DDR 640*480
    --ret = disp.cameraopen_ext(gc0310_ddr) -- 外部配置gc0310 camera DDR
    --ret = disp.cameraopen_ext(bf302A_sdr) -- 外部配置bf302A camera SDR
    --ret = disp.cameraopen_ext(gc032a_ddr_big) -- 外部配置gc032a camera DDR 640*480
    log.info("LUA外部配置camera功能并且打开摄像头的结果", ret)

    --打开摄像头预览
    --zoom： 放缩设置, 目前仅支持0xff尺寸自适应，0不放缩
    --disp.camerapreviewxzoom(zoom)
    -- disp.camerapreviewzoom(0xff)--缩小2倍
    -- ret = disp.camerapreview(0, 0, 0, 0, WIDTH or DEFAULT_WIDTH, HEIGHT or DEFAULT_HEIGHT)
	-- log.info("打开摄像头预览的结果",ret)
    --rotation：反转角度设置 暂时只支持0和90度
    --disp.camerapreviewrotation(90)
    --10秒后进行拍照
    sys.timerStart(takePhotoAndSendToUart,1000)
end

-- 表单上传
function postMultipartFormData(url,cert,params,timeout,cbFnc,rcvFileName)
    local boundary,body,k,v,kk,vv = "--------------------------"..os.time()..rtos.tick(),{}

    for k,v in pairs(params) do
        if k=="texts" then
            local bodyText = ""
            for kk,vv in pairs(v) do
                bodyText = bodyText.."--"..boundary.."\r\nContent-Disposition: form-data; name=\""..kk.."\"\r\n\r\n"..vv.."\r\n"
            end
            body[#body+1] = bodyText
        elseif k=="files" then
            local contentType =
            {
                jpg = "image/jpeg",
                jpeg = "image/jpeg",
                png = "image/png",
            }
            for kk,vv in pairs(v) do
                print(kk,vv)
                body[#body+1] = "--"..boundary.."\r\nContent-Disposition: form-data; name=\""..kk.."\"; filename=\""..kk.."\"\r\nContent-Type: "..contentType[vv:match("%.(%w+)$")].."\r\n\r\n"
                body[#body+1] = {file = vv}
                body[#body+1] = "\r\n"
            end
        end
    end
    body[#body+1] = "--"..boundary.."--\r\n"

    http.request(
        "POST",
        url,
        cert,
        {
            ["Content-Type"] = "multipart/form-data; boundary="..boundary,
            ["Connection"] = "keep-alive"
        },
        body,
        timeout,
        cbFnc,
        rcvFileName
        )
end

-- 表单方式上传, body是mulitpart/form
function upload_form()
    postMultipartFormData("upload.air32.cn/api/upload/form", nil, 
    {files={filename="/testCamera.jpg"}}
    , 15000, function(result,prompt,head,body)
        log.info("http上报结果", result,prompt,head)
    end)
end

-- 流式直接上传, body就是文件
function upload_stream()
    http.request("POST","upload.air32.cn/api/upload/jpg",nil,
    {['Content-Type']="application/octet-stream",['Connection']="keep-alive"},
    {[1]={['file']="/testCamera.jpg"}},
    15000,function(result,prompt,head,body)
       log.info("http上报结果", result,prompt,head)
    end)
end

-- 拍照并通过usb发送出去
function takePhotoAndSendToUart()
    --允许系统休眠
    pm.sleep("testopencamera")
    local EX = io.exists("/test.jpg")

	log.info("拍照的结果", disp.cameracapture(DEFAULT_WIDTH, DEFAULT_HEIGHT, 100))
    log.info("设置照片保存路径的结果",disp.camerasavephoto("/testCamera.jpg"))
    log.info("照片文件大小", io.fileSize("/testCamera.jpg"))
    -- copy_file()
    -- testUartSentFile.sendFile()
    -- 关闭摄像头预览
    -- log.info("关闭摄像头预览的结果", disp.camerapreviewclose())
    -- 关闭摄像头
    -- log.info("关闭摄像头的结果", disp.cameraclose())

    -- 流式直接上传, body就是文件
    -- upload_stream()

    -- 表单方式上传, body是mulitpart/form
    upload_form()

    sys.timerStart(opencamera, 30000)
end

sys.timerStart(opencamera, 1000)

