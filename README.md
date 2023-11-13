# luatos-turnkey

## 介绍

存放LuatOS相关的解决方案

项目列表及搜索: TODO

## 存放规则

每个项目以独立目录存放在projects主目录下, 项目文件需要符合要求

实例:

```
projects
    - 00001.短信转发        # 项目编号及简短描述
        - README.md        # [必须存在]项目介绍
        - user             # [可选]脚本文件及资源文件
        - files            # [可选]其他辅助文件,例如固件文件,合成好的量产文件等
        - 其他目录          # [可选]项目可自行添加其他目录
        - .luatos          # [可选]LuatOS相关文件
            - project.json # [可选]LuatIDE项目文件   
```

编号规则, 默认从 00001 开始的 5位 整数

## 对README.md 要求

1. README.md应准确描述本项目的功能,适用场景,所需要的硬件模块
2. 提供相关资料的链接
3. 尽量提供测试固件

## 开源协议

[MIT License](LICENSE)

