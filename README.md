# APMr
`App性能分析工作台`山寨版。

### Depends

- `Xcode` 
  - 主要依赖`../DeviceSupport`里面对应的`DeveloperDiskImage`，如果没有当前对应的版本[iOS-DeviceSupport](https://github.com/iGhibli/iOS-DeviceSupport) 找对应的镜像，否则会链接不成功，虽然目前的代码都是测试代码。

### Features

- Client
  - UI
    - [x] homepage
    - [ ] homepage2.0 rebuild (Doing) 

  - Service
    - [x] deviceList
    - [x] appList
    - [x] launchApp
    - [x] cpu
    - [x] gpu 
    - [x] 内存
    - [x] network
    - [x] 耗电
    - [x] I/O
  
- Learn
  - [x] swiftUI 关键字(@state @ObservedObject 等)底层、对于更新UI的性能影响
  - [x] 类与结构体对于UI更新的影响

- Optimize
  - [ ] 渲染时机优化 (Doing)
  - [ ] 展示效果优化 (Doing)

### Chat

- 为什么想写这个项目：
  - 兴趣使然。
- 扩展
  - `instruments`提供的服务挺多，[参考文章](https://github.com/troybowman/dtxmsg/blob/master/slides.pdf)之后可以尝试一下获取其他`服务`的`selector`。

### 致谢/参考

- 感谢`字节跳动`的文章[APP性能分析工作台——你的最佳桌面端性能分析助手](https://juejin.cn/post/7052577178587758605).
  - `libimobiledevice`库调试之后，下一步就是打算接入`Instruments`的服务，幸好有这个文章的`技术说明`,否则花费时间肯定会更多。

