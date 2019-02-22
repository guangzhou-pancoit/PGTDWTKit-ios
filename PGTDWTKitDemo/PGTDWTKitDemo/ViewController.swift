//
//  ViewController.swift
//  PGTDWTKitDemo
//
//  Created by iMac on 2019/2/19.
//  Copyright © 2019 广州磐钴智能科技有限公司. All rights reserved.
//

import UIKit
import PGTDWTKit

class ViewController: UIViewController {
    
    @IBOutlet weak var signalStrength: UILabel!// 信号强度 北斗一代盒子 0~24   北斗二代盒子 0~40
    // 信号状态 信号良好才能发送北斗消息-信号弱时发送成功率低 -- 这个信号是否良好由工具包默认定义，如需自定义则可以通过信号强度或 box.signal1~10 10个波速信号程度判断。
    @IBOutlet weak var signalStatus: UILabel!
    // 电量
    @IBOutlet weak var electricity: UILabel!
    // 北斗卡号
    @IBOutlet weak var bdCarNumber: UILabel!
    // 服务频度
    @IBOutlet weak var frequency: UILabel!
    // 发现消息频度倒计时
    @IBOutlet weak var countdown: UILabel!
    
    
    // 是否自定义UI
    @IBOutlet weak var isCustomUI: UISwitch!
    // 发送到什么平台
    @IBOutlet weak var toPlatform: UISegmentedControl!
    
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var log: UITextView!
    
    lazy var datas:[BDPeripheral] = [BDPeripheral]()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var boxConnectView: UIView! // 自定义连接北斗盒子视图
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // 使用前先设置平台接收北斗k卡号（RD通道/指挥机/其他北斗数传设备）
        // AppDelegate application(_ application: , didFinishLaunchingWithOptions launchOptions: ) -> Bool
        boxtools.delegate = self
    }
    
    // 连接设备 或 断开
    @IBAction func connect(_ sender: UIButton) {
        if !sender.isSelected {
            boxtools.connect()
            // 如果是自定义UI，则显示自定义UI
            if self.isCustomUI.isOn {
                // 需要隐藏视图
                self.boxConnectView.isHidden = false
            }
        }else {
            boxtools.disConnect() // 断开连接
        }
        
    }
    
    // 发送消息
    @IBAction func sendMessage() {
        // 发送消息前，最好判断一下频度是否到达
        
        // 发送前，最好判断一下信号状态
//        if !boxtools.box.getSignalStatus() {
//            print("北斗信号，请将设备朝向南方")
//            return;
//        }
        switch toPlatform.selectedSegmentIndex {
        case 0:
            /// 发送北斗到北斗消息
            /// contact 接收者北斗卡号； boxtools.box.carNumber 当前设备的北斗卡号
            boxtools.boxMsg.sendB2BMessage(contact: boxtools.box.carNumber, content: "自发自收信息", location: PGLocation(longitude: 113.848324, latitude: 23.332045))
            // 不带位置可以省略location
        case 1:
            let phone = ""
            if phone == "" {
                self.addLog("请设置接收短信的手机号码")
                return;
            }
            boxtools.boxMsg.sendSMSContent(contact: phone, content: "短信：Hello World", location: PGLocation(longitude: 113.848324, latitude: 23.332045))
        case 2:
            let phone = ""
            if phone == "" {
                self.addLog("请设置联系人手机号码或北斗卡号")
                return;
            }
            boxtools.boxMsg.sendSMSContent(contact: phone, content: "H5聊天：Hello World", location: PGLocation(longitude: 113.848324, latitude: 23.332045))
        case 3:
            break
        case 4:
            boxtools.boxMsg.sendRescuePlatformsContent(content: "我们需要帮助，请求支援！", status: "00", location: PGLocation(longitude: 113.848324, latitude: 23.332045))
            break
        default:
            break
        }
    }
    
    // 发送自定义消息
    @IBAction func sendCustomMessage() {
        /// 发送北斗到北斗 自定义消息
        /// contact 接收者北斗卡号； boxtools.box.carNumber 当前设备的北斗卡号
        boxtools.boxMsg.sendMessage(boxId: boxtools.box.carNumber , hexString: getCustomMessage())
    }
    
    // 获取离线消息
    @IBAction func getOfflineMessage() {
        let strTiem = Int(Date().timeIntervalSince1970) - 604800 //当前时间 - 7天
        // 获取7天内的离线消息，一次最多获取3条通讯信息，如果7天内超过3条离线消息，则使用最后一个消息的时间 再次获取。一直获取到没有
        // sender 发送者号码 0代表所有给当前北斗卡发的消息
        boxtools.boxMsg.sendGetOfflineMessage(sender: "0", strTiem: strTiem)
    }
    
    // 上传位置
    @IBAction func updateLocation() {
        
    }
}

extension ViewController:BDBoxDelegate {
    /// 是否自己自定义连接北斗盒子界面 - 默认false
    /// 如果自己实现连接北斗盒子界面，则不再弹出设备选择连接北斗盒子视图，而会调用boxtoolsTools(_ boxtoolsTools: BDboxtoolsTools, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber)代理
    func boxToolsCustomConnectView(_ boxTools: BDBluetoothTools) -> Bool {
        return self.isCustomUI.isOn
    }
    //    发现外围设备 ，如果boxToolsCustomConnectView(_ boxTools: ) 为false，则不会调用。自定义连接北斗盒子视图时才会调用
    func boxTools(_ boxTools: BDBluetoothTools, didDiscover peripheral: BDPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("发现外围设备:\(peripheral)")
        
        if !datas.contains(peripheral) {
            datas.append(peripheral)
            self.tableView.reloadData()
        }
    }
    /// 已经连接 同时发送通知 BDBoxConnectSuccess
    func boxTools(_ boxTools: BDBluetoothTools, didConnect peripheral: BDPeripheral) {
        addLog("连接成功")
        self.connectButton.isSelected = true
    }
    /// 连接失败
    func boxTools(_ boxTools: BDBluetoothTools, didFailToConnect peripheral: BDPeripheral) {
        addLog("连接失败")
    }
    
    /// 断开连接 同时发送通知 BDBoxDisconnect
    func boxTools(_ boxTools: BDBluetoothTools, didDisconnectPeripheral peripheral: BDPeripheral) {
        addLog("断开连接")
        self.connectButton.isSelected = false
        
        self.signalStrength.text = "0"
        self.signalStrength.text = "无"
        self.electricity.text = "0%"
        self.bdCarNumber.text = "------"
        self.frequency.text = "0秒"
    }
    /// 平台回执 -收到回执代表对方北斗设备收到消息了
    /// received  消息接收者的手机号/北斗卡号
    /// time 平台接收到消息的时间戳 （由于卫星接收到消息-中转-到平台有时间差（<=10秒）,所以这个时间应该做一个范围性参考）
    func boxTools(_ boxTools: BDBluetoothTools, returnReceipt received: String, time: Int) {
        addLog("收到平台回执 received：\(received) time:\(time)")
    }
    
    /// 接收到数据 - 天地卫通协议消息
    func boxTools(_ boxTools: BDBluetoothTools, didUpdateValueForObject object: PGMessage) {
        addLog("天地卫通协议消息:\(object.content)")
    }
    
    /// 接收到数据 - 自定义协议：十六进制
    func boxTools(_ boxTools: BDBluetoothTools, didUpdateValueForHexString hexString: String) {
        addLog("收到自定义消息：\(hexString)")
        // 解析自定义协议消息
        self.parsingProtocol(value: hexString)
    }
    
    /// 接收到数据 - 终端信息更新 同时发送通知 BDUpdateZDXX
    func boxTools(_ boxTools: BDBluetoothTools, updateZDXX box: BDBoxInfo) {
        print("终端信息：\(box)")
        
        self.signalStrength.text = "\(box.getSignalStatusTotal())"
        self.signalStatus.text = box.getSignalStatus() ? "良好" : "差"
        self.electricity.text = box.electric + "%"
        self.bdCarNumber.text = box.carNumber
        self.frequency.text = box.frequent
    }
    
    /// 发送消息结果
    /// message 是发送成功或者失败的消息提示。如:"报文已发出"
    /// 发送错误有相关错误提示词 "发射命令失败" "信号未锁定" "电量不足" "发射频度未到" "加解密错误" "定位/通信查询/定时结果的CRC错误" "北斗系统繁忙，请稍后再试" "无线静默" "未取到分帧号未发射" "DSP复位" "终端被遥毙" "通信存入缓存" "发射抑制解除" "接收到系统的抑制指令，发射被抑制" "电量不足，发射被抑制" "当前设置为无线电静默状态，发射被抑制"
    func boxTools(_ boxTools: BDBluetoothTools, sendMessageReslut status: Bool, message: String) {
        addLog("自发送消息结果：\(status) message:\(message)")
        
    }
    
    /// 发送频度倒计时 同时发送通知 BDSendFrequenyCountdown
    /// 每发送一次数据都会执行倒计时 一般是60s 具体和北斗盒子的频度有关
    /// 特别注意，由于北斗信号问题有可能这个频度计算有差异（2s左右）。建议自已添加定时器来控制发送频度  盒子频度为 boxtools.box.frequent
    /// 一般使用这个接口就可以知道正确的剩余频度，如果需要自己添加定时器监控频度请注意定时器的RunLoopMode 请使用 Swift:.commonModes OC:NSRunLoopCommonModes
    func boxTools(_ boxTools: BDBluetoothTools, frequency countdown: Int) {
        print("通讯频度倒计时:\(countdown)")
        self.countdown.text = countdown > 0 ? "\(countdown)秒" : "空闲"
    }
    
    /// 是否自定义定频度发送定时器管理. 默认是 false ，由SDK控制定时器 -- 这个方法会在连接盒子后调用一次，和每次发送消息调用一次
    /// 如果自定义控制频度发送计时器，那么将不会调用boxtoolsTools(_ boxtoolsTools:BDboxtoolsTools, frequency countdown:Int) 也不会发送BDSendFrequenyCountdown通知
    /// frequency:盒子频度
    func boxTools(_ boxTools: BDBluetoothTools, customTimer frequency: Int) -> Bool {
        // frequency 当前SDK 默认频度
        return false
    }
}

// 自定义连接北斗盒子UI---设备列表
extension ViewController:UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.datas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "string")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "string")
        }
        let peripheral = self.datas[indexPath.row]
        cell?.textLabel?.text = peripheral.name
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let peripheral = self.datas[indexPath.row]
        boxtools.connect(peripheral: peripheral, options: nil)
        self.addLog("正在连接:\(peripheral.name!)北斗盒子..")
        // 需要隐藏视图
        self.boxConnectView.isHidden = true
    }
}



/// 其他 内部方法
extension ViewController {
    // 添加文本到日志
    func addLog(_ text:String) {
        print(text)
        var log = self.log.text!
        log = log + "\n - "  + text
        self.log.text = log;
    }
    
    // 生成一个自定义 报文
    // 自定义报文格式为 ：协议头(1字节) + 内容（77字节）
    // 请不要使用系统使用的协议头，否则会导致系统误解析，导致异常。当前系统已使用以下协议头01、EE、A4、10、11、21、12、22、13、23、14、15、16、F1、F2、F3、1A、1B、0~FC、1D
    // 建议自定义开发者使用 ： 80~F 90~F  ，使用8或9开头
    func getCustomMessage() -> String {
        // 以水坝数据采集为例  -- 本人不懂水坝相关业务，乱写的。
        
        // 协议头1个字节 --类型
        let type = "8F" // 使用8F 代表水坝采集数据
        
        // 水位(米) 1个字节
        let waterLevel = "5".decimalToHexadecimal(length: 2)
        
        // 水温（度）1字节
        let waterTemperature = "20".decimalToHexadecimal(length: 2)
        
        // 排量（吨）1字节 1字节能代表 整形 0~255
        let displacement = "130".decimalToHexadecimal(length: 2)
        
        // 时间（时间戳）4个字节
        let tiem = "\(Date().timeIntervalSince1970)".decimalToHexadecimal(length: 8)
        
        // 备注 <= 70 字节  因为上面占用了8字节，所以报文消息还剩下70字节，一个汉字占用2个字节(报扩标点符号)。
        let remark = "南度河水坝排量数据".chineseToHex()
        
        return type + waterLevel + waterTemperature  + displacement  + tiem  + remark
    }
    
    // 解析 协议数据
    func parsingProtocol(value:String){
        
        let type = value.substring(to: 2) // 获取协议类型。 在上面生成协议的时候，我们一开头1个字节作为协议头
        
        // 如果是自己定义的协议类型，则区分 解析
        if type == "8F" {
            // 如果协议为 8F 则代表是8F 代表水坝采集数据
            self.damMessage(value: value)
        }
        // else if ....  or switch
    }
    
    // 解析水坝数据
    func damMessage(value:String){
        if value.count < 16 {
            return; //最好判断一下数据完整性，以免其他数据类型冲突，导致解析出错
        }
        
//        let type = value.substring(to: 2) // 协议头
        
        // 水位(米) 1个字节
        let waterLevel = value[2,2].hexToDecimalism()
        
        // 水温（度）1字节
        let waterTemperature = value[4,2].hexToDecimalism()
        
        // 排量（吨）1字节
        let displacement = value[6,2].hexToDecimalism()
        
        // 时间（时间戳）4个字节
        let tiem = value[8,8].hexToDecimalism()
        
        // 备注 <= 70 字节
        let remark = value.substring(from: 16).hexToChinese()
        
        addLog("接收到水坝数据-- 水位：\(waterLevel)米 水温：\(waterTemperature)度 排量：\(displacement)吨 时间：\(conversionTiemStamp(tiem)) 备注信息：\(remark)")
    }
    
    func conversionTiemStamp(_ timeStamp:Int)-> String {
        let dfmatter = DateFormatter()
        dfmatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = Date(timeIntervalSince1970: Double(timeStamp))
        return dfmatter.string(from: date)
    }
    
}
