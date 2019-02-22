//
//  String-Extension.swift
//  BDRenFang
//
//  Created by QZBD on 2017/9/15.
//  Copyright © 2017年 QZBD. All rights reserved.
//

import Foundation
extension String {
    /*
     *去掉首尾空格
     */
    var removeHeadAndTailSpace:String {
        let whitespace = NSCharacterSet.whitespaces
        return self.trimmingCharacters(in: whitespace)
    }
    /*
     *去掉首尾空格 包括后面的换行 \n
     */
    var removeHeadAndTailSpacePro:String {
        let whitespace = NSCharacterSet.whitespacesAndNewlines
        return self.trimmingCharacters(in: whitespace)
    }
    /*
     *去掉所有空格
     */
    var removeAllSapce: String {
        return self.replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
    }
    /*
     *去掉首尾空格 后 指定开头空格数
     */
    func beginSpaceNum(num: Int) -> String {
        var beginSpace = ""
        for _ in 0..<num {
            beginSpace += " "
        }
        return beginSpace + self.removeHeadAndTailSpacePro
    }
}
// MARK: - 字符串截取
extension String {
    /// String使用下标截取字符串
    /// string[index] 例如："abcdefg"[3] // c
    subscript (i:Int)->String{
        let startIndex = self.index(self.startIndex, offsetBy: i)
        let endIndex = self.index(startIndex, offsetBy: 1)
        return String(self[startIndex..<endIndex])
    }
    /// String使用下标截取字符串
    /// string[index..<index] 例如："abcdefg"[3..<4] // d
    subscript (r: Range<Int>) -> String {
        get {
            let startIndex = self.index(self.startIndex, offsetBy: r.lowerBound)
            let endIndex = self.index(self.startIndex, offsetBy: r.upperBound)
            return String(self[startIndex..<endIndex])
        }
    }
    /// String使用下标截取字符串
    /// string[index,length] 例如："abcdefg"[3,2] // de
    subscript (index:Int , length:Int) -> String {
        get {
            let startIndex = self.index(self.startIndex, offsetBy: index)
            let endIndex = self.index(startIndex, offsetBy: length)
            return String(self[startIndex..<endIndex])
        }
    }
    // 截取 从头到i位置
    func substring(to:Int) -> String{
        return self[0..<to]
    }
    // 截取 从i到尾部
    func substring(from:Int) -> String{
        return self[from..<self.count]
    }
    
}

// MARK: - 进制转换
extension String {
    // 保留长度，不足补0,超出裁剪
    func toLength(_ length:Int)->String {
        if self.count < length {
            return String(format: "%0\(length-self.count)d",0) + self
        }
        return self[0..<length]
    }
    // 十进制字符串转16进制
    func decimalToHexadecimal() -> String{
        return String(format: "%lX", (self as NSString).integerValue)
    }
    
    /// 十进制字符串转16进制
    /// 数字
    /// - Parameter length: 保留长度，不足补0,超出裁剪
    func decimalToHexadecimal(length:Int) -> String {
        return decimalToHexadecimal().toLength(length)
    }
    
    /// 十六进制转十进制字符串
    func hexToDecimalismString()->String{
        return "\(self.hexToDecimalism())"
    }
    /// 十六进制转十进制 整形
    func hexToDecimalism()->Int {
        let str = self.uppercased()
        var sum = 0
        for i in str.utf8 {
            sum = sum * 16 + Int(i) - 48 // 0-9 从48开始
            if i >= 65 {                 // A-Z 从65开始
                sum -= 7
            }
        }
        return sum
    }
    // 十六进制 转 中文汉字
    func hexToChinese()->String {
        var strResult: String
        if self.count % 2 == 0 {
            //第二次转换
            let aData = Data(bytes: self.bytes(from: self))
            let encode = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
            strResult = String(data: aData, encoding: String.Encoding(rawValue: encode)) ?? ""
            //        NSLog(@"strResult:%@",strResult);
        } else {
            strResult = "已假定是汉字的转换，所传字符串的长度必须是4的倍数!"
            print("strResult:\(strResult)")
            return "nil"
        }
        return strResult
    }
    
    // 中文汉字 转 十六进制
    func chineseToHex()-> String {
        let encodingGB18030 = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
        let responseData: Data = self.data(using: String.Encoding(rawValue: encodingGB18030))!
        let string = self.nsData(toByteTohex: responseData)
        return string
    }
    func chineseToHex(length:Int)-> String{
        return chineseToHex().toLength(length)
    }
    // 将16进制字符串转化为 [UInt8]
    // 使用的时候直接初始化出 Data
    // Data(bytes: Array<UInt8>)
    func bytes(from hexStr: String)-> [UInt8] {
        assert(hexStr.count % 2 == 0, "输入字符串格式不对，8位代表一个字符")
        var bytes = [UInt8]()
        var sum = 0
        // 整形的 utf8 编码范围
        let intRange = 48...57
        // 小写 a~f 的 utf8 的编码范围
        let lowercaseRange = 97...102
        // 大写 A~F 的 utf8 的编码范围
        let uppercasedRange = 65...70
        for (index, c) in hexStr.utf8CString.enumerated() {
            var intC = Int(c.byteSwapped)
            if intC == 0 {
                break
            } else if intRange.contains(intC) {
                intC -= 48
            } else if lowercaseRange.contains(intC) {
                intC -= 87
            } else if uppercasedRange.contains(intC) {
                intC -= 55
            } else {
                assertionFailure("输入字符串格式不对，每个字符都需要在0~9，a~f，A~F内")
            }
            sum = sum * 16 + intC
            // 每两个十六进制字母代表8位，即一个字节
            if index % 2 != 0 {
                bytes.append(UInt8(sum))
                sum = 0
            }
        }
        return bytes
    }
    func nsData(toByteTohex data: Data) -> String {
        let bytes = [UInt8](data)
        var hexStr = ""
        for i in 0..<data.count {
            let newHexStr = String(format: "%X", Int(bytes[i]) & 0xff) ///16进制数
            if newHexStr.count == 1 {
                hexStr = "\(hexStr)0\(newHexStr)"
            } else {
                hexStr = "\(hexStr)\(newHexStr)"
            }
        }
        return hexStr
    }
}
