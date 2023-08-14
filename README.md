# APMr
`App性能分析工作台`山寨版。

![APM-0](https://user-images.githubusercontent.com/17810210/224478734-e6fc7b99-6e29-47c3-b81b-bbe8b2938888.png)

![APM-1](https://user-images.githubusercontent.com/17810210/224478630-27057941-84be-40f9-9bb9-a8bdeb52006c.png)

![APM-2](https://user-images.githubusercontent.com/17810210/224478642-a9a1094e-c024-4907-ab9c-b96a2d9875e9.png)

![APM-3](https://user-images.githubusercontent.com/17810210/224478644-909dc46a-a57f-4582-a418-d2c356c360c3.png)

### Depends

- `Xcode` 
  - 主要依赖`../DeviceSupport`里面对应的`DeveloperDiskImage`，如果没有当前对应的版本[iOS-DeviceSupport](https://github.com/iGhibli/iOS-DeviceSupport) 找对应的镜像，否则会链接不成功，虽然目前的代码都是测试代码。

### Features

- 性能分析
  - CPU
  - GPU
  - FPS
  - Memory
  - Network
  - I/O
  - 电池分析

- 其他小功能 (doing)
  - 自定义 `DeveloperDiskImage`路径，以及自动下载。

- 启动分析 (doing)

- 卡顿分析 (todo)

- 崩溃分析 (todo)

### Chat

- 为什么想写这个项目：
  - 兴趣使然。

- 扩展
  - `instruments`提供的服务挺多，[参考文章](https://github.com/troybowman/dtxmsg/blob/master/slides.pdf)之后可以尝试一下获取其他`服务`的`selector`。

### 致谢/参考
- 感谢大佬代码[SYM](https://github.com/zqqf16/SYM)
- 感谢大佬代码[ios_instruments_client](https://github.com/troybowman/ios_instruments_client)
- 感谢大佬代码[py-ios-device](https://github.com/YueChen-C/py-ios-device)
- 感谢大佬代码[taobao-iphone-device](https://github.com/alibaba/taobao-iphone-device)
- 感谢大佬代码[pymobiledevice3](https://github.com/doronz88/pymobiledevice3)
- 感谢文章[APP性能分析工作台——你的最佳桌面端性能分析助手](https://juejin.cn/post/7052577178587758605).
  - `libimobiledevice`库调试之后，下一步就是打算接入`Instruments`的服务，幸好有这个文章的`技术说明`,否则花费时间肯定会更多。
