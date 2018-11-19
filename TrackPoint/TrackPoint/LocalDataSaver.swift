//
//  LocalDataSaver.swift
//  TrackPoint
//
//  Created by CMPT275 on 2018-11-09.
//  Copyright © 2018 Pit Bulls. All rights reserved.
//

import Foundation

class LocalDataManager {
    private static let inst = LocalDataManager()
    internal var lastSaveDir: URL?
    internal let fileManager = FileManager.default
    internal var rot_rate: ([Double], [Double], [Double]) = ([],[],[])// = ([-1,0,1,2,4],[-1,0,1,2,4],[-1,0,1,2,4])
    internal var user_accel: ([Double], [Double], [Double]) = ([],[],[])// = ([-1,0,1,2,4],[-1,0,1,2,4],[-1,0,1,2,4])
    internal var dataDir:URL!
    internal enum colError: Error {
        case SaveDataEmpty
        case ReadDataEmpty
        case InvalidURL
        case FileSizeMismatch
        case NoFilesFound
    }
    
    // get shared instance
    class func shared()->LocalDataManager{
        return inst
    }
    
    private init(){
        let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        dataDir = paths[0].appendingPathComponent("TrackPoint", isDirectory: true)
        
    }
    
    public func getLastDir()->URL?{
        return lastSaveDir
    }
    
    public func saveData(accel:([Double], [Double], [Double])!,rot:([Double], [Double], [Double])!,timestamp:Date? = nil) throws {
        user_accel = accel
        rot_rate = rot
        if (user_accel.0.isEmpty || rot_rate.0.isEmpty) {throw colError.SaveDataEmpty};
        assert(user_accel.0.count*5 == (user_accel.1.count + user_accel.2.count
            + rot_rate.0.count + rot_rate.1.count + rot_rate.2.count));
        
        //let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let _timestamp = timestamp ?? Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: _timestamp)
        let month = calendar.component(.month, from: _timestamp)
        let day = calendar.component(.day, from: _timestamp)
        let hour = calendar.component(.hour, from: _timestamp)
        let min = calendar.component(.minute, from: _timestamp)
        let sec = calendar.component(.second, from: _timestamp)
        //var filename = paths[0].appendingPathComponent("TrackPoint", isDirectory: true)
        var filename = dataDir!
        try? fileManager.createDirectory(at: filename, withIntermediateDirectories: true, attributes: nil)
        let namestr = String(year)+"-"+String(month)+"-"+String(day)+"-"+String(hour)+"-"+String(min)+"-"+String(sec)
        filename = filename.appendingPathComponent(namestr)
        
        //print("dataURL: \(filename_d.absoluteString)\n")
        fileManager.createFile(atPath: filename.absoluteString, contents: nil)
        
        let wArray:[Double] = user_accel.0 + user_accel.1 + user_accel.2 + rot_rate.0 + rot_rate.1 + rot_rate.2
        
        let wData = Data(bytes: wArray, count: wArray.count * MemoryLayout<Double>.stride)
        
        
        do {
            // TODO: append
            try wData.write(to: filename)
            lastSaveDir = filename
        } catch {
            print("failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding\n\(error)\n")
        }
    }
    
    // test saves
    public func verifyWritten() -> Bool {
        if (lastSaveDir == nil) {return false};
        var isCorrect: Bool = true;
        do {
            //try saveData()
            let filename = lastSaveDir!
            let readArray = try readData(url: filename)
            isCorrect = isCorrect && arrayCMP(src0: user_accel.0, src1: readArray[0], index: 0)
            isCorrect = isCorrect && arrayCMP(src0: user_accel.1, src1: readArray[1], index: 1)
            isCorrect = isCorrect && arrayCMP(src0: user_accel.2, src1: readArray[2], index: 2)
            isCorrect = isCorrect && arrayCMP(src0: rot_rate.0, src1: readArray[3], index: 3)
            isCorrect = isCorrect && arrayCMP(src0: rot_rate.1, src1: readArray[4], index: 4)
            isCorrect = isCorrect && arrayCMP(src0: rot_rate.2, src1: readArray[5], index: 5)
        } catch {
            print("verify fail")
            isCorrect = false
        }
        return isCorrect;
    }
    
    // compares arrays, true if same
    internal func arrayCMP(src0:[Double],src1:[Double],index:Int = -1) -> Bool {
        assert(src0.count == src1.count)
        for i in 0..<src0.count{
            if (src0[i] != src1[i]){
                if(index > -1) {
                    print("arrayCMP fail index = %d\n",index)
                }
                return false;
            }
        }
        return true;
    }
    
    public func readData(time: [Int]) throws -> [[Double]] {
        if (time.count != 6) {throw colError.InvalidURL}
        let year = time[0]
        let month = time[0]
        let day = time[0]
        let hour = time[0]
        let min = time[0]
        let sec = time[0]
        var filename = dataDir!
        let namestr = String(year)+"-"+String(month)+"-"+String(day)+"-"+String(hour)+"-"+String(min)+"-"+String(sec)
        filename = filename.appendingPathComponent(namestr)
        do {
        return try readData(url: filename)
        }catch{
            throw error
        }
    }
    
    public func readData(url:URL) throws -> [[Double]] {
        var rArray: [[Double]]  = [[],[],[],[],[],[]]
        
        do{
            let rData = try Data(contentsOf: url)
            var aArray:[Double]!
            rData.withUnsafeBytes{(bytes: UnsafePointer<Double>) in aArray = Array(UnsafeBufferPointer(start: bytes, count: rData.count / MemoryLayout<Double>.size))}
            if aArray.count % 6 != 0 {
                throw colError.FileSizeMismatch
            }
            let rACount:Int = Int(aArray.count/6)
            for i in 0..<6{
                rArray[i] = Array(aArray[i*rACount..<(i+1)*rACount])
            }
        }catch {
            throw error
        }
        if (rArray[0].isEmpty){
            throw colError.ReadDataEmpty
        }
        return rArray
    }
    
    public func readAll() throws -> ([[[Double]]], [[Int]]) {
        let dataURLs = listFiles(dir: dataDir)
        if dataURLs.isEmpty {throw colError.NoFilesFound}
        var rtnArray:[[[Double]]] = [[[]]]
        var rtnTimeStamp:[[Int]] = [[]]
        for i in 0..<dataURLs.count{
            let cdir = dataURLs[i]
            let cdata = try? readData(url: cdir)
            let cdata_ = cdata ?? [[]];
            if !cdata_.isEmpty{continue;}
            
            var tdata:[Int] = []
            let tokens = cdir.lastPathComponent.components(separatedBy: "-")
            var isBadTime:Bool = false
            if tokens.count<6{continue;}
            for _ in 0..<6{ //tokens.count
                if (Int(tokens[0]) == nil) {
                    isBadTime = true
                    break
                }
                tdata.append(Int(tokens[0])!)
            }
            if isBadTime {continue;}
            
            rtnArray.append(cdata_)
            rtnTimeStamp.append(tdata)
        }
        return (rtnArray, rtnTimeStamp)
    }
    
    internal func listFiles(dir:URL)->[URL]{
        var rtnURLs:[URL]!
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil)
            let dataURLs = fileURLs.filter{ $0.pathExtension == "bin" }
            //let metaURLs = fileURLs.filter{ $0.pathExtension == "tps" }
            rtnURLs = dataURLs
        }catch{
            print("get file list error: \(error)")
        }
        
        return rtnURLs
    }
}
