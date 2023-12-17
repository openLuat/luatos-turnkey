# 环境监测(4G/wifi版本)

核心功能:

* 合宙Air700E 4G模块读取传感器（温湿度、气压等）数据并通过MQTT协议上传阿里云物联网平台，数据也会同时显示在0.96寸的OLED屏幕上，使用了U8g2图形库。
* ESP32C3 WiFi模块通过MQTT协议订阅4G节点上传的数据并显示在LCD屏上，使用了LVGL图形库。

公众号资料链接: [基于合宙Air700E的4G环境监测节点（温湿度、气压等数据），通过MQTT上传阿里云物联网平台](https://mp.weixin.qq.com/s/JRLhgIlWECuNrFN0171noA)
