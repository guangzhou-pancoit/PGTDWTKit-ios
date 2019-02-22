# PGTDWTKit-ios
天地卫通SDK开发指南

## 开发者注意事项
1、天地卫通SDK使用Swift语法开发，如果需要在Objective-C工程中使用，请自行了解Objective-C与Swift混合开发知识。
2、支持iOS 8.0及以上系统
3、使用SDK服务中部分功能需要与平台通讯，请先设置平台北斗卡号。
4、天地卫通SDK主要提供蓝牙操作及相关功能，提交App Store审核需要在工程中Info文件设置Privacy - Bluetooth Peripheral Usage Description 是否许允许使用蓝牙？
5、意见反馈请联系我们<http://www.pancoit.com>

## 获取平台北斗卡号
天地卫通开发工具包含部分与平台通讯接口，需先获取RD通道或指挥机或其他北斗数传设备接收卡号，才能正常使用者部分功能。如没有接收通讯数据的北斗卡号，[请点击联系我们](www.pancoit.com) 

## 手动部署
下载[PGTDWTKit.framework](https://github.com/guangzhou-pancoit/PGTDWTKit-ios)

## 自动部署
待续。。

## SDK 介绍
在部署中您可以看到我们提供了一个新的SDK，这个SDK包含了蓝牙连接、发送北斗消息两部分基础核心。连接蓝牙部分包括蓝牙从搜索到连接成功到断开连接的所有操作，开发者不需要再关心蓝牙开发知识，发送消息部分已为开发者提供多种通讯协议接口，已为开发者封装相关通讯协议，解析相关通讯协议，开发者不再需要关心北斗通讯协议以及蓝牙通讯协议。

使用请引入SDK并设置平台北斗卡号
提交App Store 请设置Privacy - Bluetooth Peripheral Usage Description

## 连接蓝牙
导入头文件import PGTDWTKit，并设置代理BDBoxDelegate
~~~
boxtools.delegate = self
~~~

在需要连接蓝牙的时候调用如下示例代码，即可搜索蓝牙并连接蓝牙。
~~~
boxtools.connect()
~~~

监听连接蓝牙操作，请实现代理
~~~
/// 已经连接 同时发送通知 BDBoxConnectSuccess
func boxTools(_ boxTools: BDBluetoothTools, didConnect peripheral: BDPeripheral) {
    print("连接成功")
}
/// 连接失败
func boxTools(_ boxTools: BDBluetoothTools, didFailToConnect peripheral: BDPeripheral) {
    print("连接失败")
}
/// 断开连接 同时发送通知 BDBoxDisconnect
func boxTools(_ boxTools: BDBluetoothTools, didDisconnectPeripheral peripheral: BDPeripheral) {
    print("断开连接")
}
~~~

以上操作已经可以完整的连接蓝牙设备了，boxtools.connect()方法提供搜索蓝牙，并提供搜索到蓝牙的展示界面，并包含连接蓝牙等操作交互界面。

连接成功后，北斗设备会每5秒更新一次信息，开发者可以每5秒获取一次boxtools.box来查看设备信息，也可以实现以下代理来监听设备信息变化。
~~~
/// 接收到数据 - 终端信息更新 同时发送通知 BDUpdateZDXX
/// BDBoxInfo 北斗设备信息
func boxTools(_ boxTools: BDBluetoothTools, updateZDXXbox: box BDBoxInfo) {
    print("终端信息：\(box)")
}
~~~

如果SDK提供的交互界面不符合开发者的工程的UI设计，可自定义连接蓝牙的交互界面，如需自定义连接蓝牙操作，请实现以下代理。
~~~
/// 是否自己自定义连接北斗盒子界面 - 默认false
/// 如果自己实现连接北斗盒子界面，则不再弹出设备选择连接蓝牙设备界面，而会调用boxtoolsTools(_ boxtoolsTools: , didDiscover peripheral: , advertisementData:, rssi RSSI: )代理
func boxToolsCustomConnectView(_ boxTools: BDBluetoothTools) -> Bool {
    return true
}
//  发现外围设备 ，如果boxToolsCustomConnectView(_ boxTools: ) 为false，则不会调用。自定义连接蓝牙设备时才会调用
func boxTools(_ boxTools: BDBluetoothTools, didDiscover peripheral: BDPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
    print("发现外围设备:\(peripheral)")
}
~~~

自定义连接蓝牙设备，由开发者自行管理搜索到的蓝牙设备，连接蓝牙设备请调用如下代码进行连接设备。
~~~
/// 连接蓝牙
/// boxtools.connect(peripheral: BDPeripheral, options: [String : Any]? = default)
boxtools.connect(peripheral: peripheral, options: nil)
~~~

## 发送消息
#### 1、发送 北斗 到 北斗的通讯信息。
由北斗设备发送到另外一部北斗设备，两个北斗设备相互通讯（直发）。使用如下接口发送北斗短板文，平台会监听短报文回执，并把回执结果回传给发送者卡号。
~~~
/// 北斗到北斗 短报文消息
/// 如报文需要携带位置，则消息内容最多发送33个汉字（包括标点符号）
boxtools.boxMsg.sendB2BMessage(contact: "联系人北斗卡号", content: "消息内容", location: PGLocation())
/// 如报文没有位置，则消息内容最多发送38个汉字（包括标点符号）
boxtools.boxMsg.sendB2BMessage(contact: "联系人北斗卡号", content: "消息内容")
~~~

#### 2、北斗到公网
北斗到公网的原理是 北斗网到平台接收北斗卡号，然后再转发到服务器，通过公网接收。同理，平台也会监听短报文回执，并把回执结果回传到发送者卡号。
~~~
/// 北斗到公网
/// 如报文需要携带位置，则消息内容最多发送33个汉字（包括标点符号）
boxtools.boxMsg.sendB2GMessage(contact: "联系人北斗卡号或手机号码", content: "消息内容", location: PGLocation())
/// 如报文没有位置，则消息内容最多发送38个汉字（包括标点符号）
boxtools.boxMsg.sendB2GMessage(contact: "联系人北斗卡号或手机号码", content: "消息内容")
~~~

#### 3、北斗到手机短信
北斗到手机短信短报文，每发送一次则会发送一条短信到目标手机号码，所以不建议频繁调用，频繁调用会屏蔽改手机号码。如果对方接受到短信后回复内容，可通过北斗到公网报文类型回复。
~~~
/// 北斗到手机短信
/// 如报文需要携带位置，则消息内容最多发送33个汉字（包括标点符号）
boxtools.boxMsg.sendSMSContent(contact: "手机号码", content: "消息内容", location: PGLocation())
/// 如报文没有位置，则消息内容最多发送38个汉字（包括标点符号）
boxtools.boxMsg.sendSMSContent(contact: "手机号码", content: "消息内容")
~~~

#### 4、北斗发送SOS救援通讯
发送SOS救援通讯短报文，该报文会直接发送到救援平台，要求必须携带求助者的位置信息。
~~~
/// 北斗发送SOS救援通讯
/// 必须发送求救者的位置信息，消息内容最多发送30个汉字（包括标点符号）
/// status: 00-求助(默认状态)、01-断水断粮、02-基础设备受损、03-受伤、04-迷路、05-生命安全受到威胁
boxtools.boxMsg.sendRescuePlatformsContent(content: "消息内容", status: "00", location: PGLocation())
~~~

#### 5、北斗上报位置轨迹
~~~
/// 北斗上报位置轨迹
/// 一次最多上报5个位置，请自行控制。
boxtools.boxMsg.sendUpdataLoactionContent(locations: [PGLocation()] )
~~~

#### 6、北斗获取离线消息
北斗获取离线消息，一次最多获取3条离线消息，如果开始时间到当前时间有N>3条信息，那么请根据获取到最后一条消息的时间再次获取离线消息，直到获取完所有的离线消息
~~~
/// 北斗获取离线消息
/// sender 获取联系人发送到当前北斗卡号的离线消息 输入0代表所有人
/// strTiem 从strTiem时间戳到当前时间段内的消息
boxtools.boxMsg.sendGetOfflineMessage(sender: "联系人北斗卡号或手机号码", strTiem:  timeStamp)
/// 不传目标，代表获取所有人从strTiem到当前时间戳内的离线消息
boxtools.boxMsg.sendGetOfflineMessage( strTiem:  timeStamp)
~~~

#### 7、自定义北斗短报文
自定义短报文要求报文内容长度不能超过78个字节，请按照格式如下。

协议头  | 内容
------------- | -------------
1个字节  | 77个字节

请严格按照系统格式来自定义，否则会出现不可预知的错误。其中协议头部分系统已经使用了以下类型，请不要和系统的协议头一致，否则会导致系统解析协议错误。
01、EE、A4、10、11、21、12、22、13、23、14、15、16、F1、F2、F3、1A、1B、0~FC、1D

~~~
/// hexString 自定义报文内容 格式：自定义协议头+内容
boxtools.boxMsg.sendMessage(boxId: "北斗卡号", hexString: "十六进制字符串")
~~~

八、发送消息结果监听
~~~
/// 发送消息结果
/// message 是发送成功或者失败的消息提示。如:"报文已发出"
/// 发送错误有相关错误提示词 "发射命令失败" "信号未锁定" "电量不足" "发射频度未到" "加解密错误" "定位/通信查询/定时结果的CRC错误" "北斗系统繁忙，请稍后再试" "无线静默" "未取到分帧号未发射" "DSP复位" "终端被遥毙" "通信存入缓存" "发射抑制解除" "接收到系统的抑制指令，发射被抑制" "电量不足，发射被抑制" "当前设置为无线电静默状态，发射被抑制"
func boxTools(_ boxTools: BDBluetoothTools, sendMessageReslut status: Bool, message: String) {
        print("发送消息结果status：\(status) message:\(message)")
}
/// 平台回执 -收到回执代表对方北斗设备收到消息了
/// received  消息接收者的手机号/北斗卡号
/// time 平台接收到消息的时间戳 （由于卫星接收到消息-中转-到平台有时间差（<=10秒）,所以这个时间应该做一个范围性参考）
func boxTools(_ boxTools: BDBluetoothTools, returnReceipt received: String, time: Int) {
        print("回执结果received：\(received) time:\(time)")
}
~~~

北斗短板文每60秒才能发送一次，所以需要控制好发送频度，否则会发送失败。请实现以下代理来监听北斗短报文的发送频度
~~~
/// 发送频度倒计时 同时发送通知 BDSendFrequenyCountdown
/// 每发送一次数据都会执行倒计时 一般是60s 具体和北斗盒子的频度有关
/// 特别注意，由于北斗信号问题有可能这个频度计算有差异（2s左右）。建议自已添加定时器来控制发送频度  盒子频度为 boxtools.box.frequent
/// 一般使用这个接口就可以知道正确的剩余频度，如果需要自己添加定时器监控频度请注意定时器的RunLoopMode 请使用 Swift:.commonModes OC:NSRunLoopCommonModes
func boxTools(_ boxTools: BDBluetoothTools, frequency countdown: Int) {
    print("通讯频度倒计时:\(countdown)")
}
~~~

以上北斗短报文频度由SDK监听和控制。如果开发者需要自行控制发送频度，请实现以下代理
~~~
/// 是否自定义定频度发送定时器管理. 默认是 false ，由SDK控制定时器 -- 这个方法会在连接盒子后调用一次，和每次发送消息调用一次
/// 如果自定义控制频度发送计时器，那么将不会调用boxtoolsTools(_ boxtoolsTools:BDboxtoolsTools, frequency countdown:Int) 也不会发送BDSendFrequenyCountdown通知
/// frequency: 当前北斗设备的发送频度
func boxTools(_ boxTools: BDBluetoothTools, customTimer frequency: Int) -> Bool {
    return true
}
~~~

## 接收消息

接收消息请实现以下代理
~~~
/// 接收到数据 - 天地卫通协议消息 
func boxTools(_ boxTools: BDBluetoothTools, didUpdateValueForObject object: PGMessage) {
    print("收到天地卫通协议消息:\(object)")
}
/// 接收到数据 - 自定义协议：十六进制
func boxTools(_ boxTools: BDBluetoothTools, didUpdateValueForHexString hexString: String) {
    print("收到自定义消息：\(hexString)")
}
~~~

## 其他
无


