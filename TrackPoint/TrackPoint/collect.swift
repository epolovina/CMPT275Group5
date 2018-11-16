// File: collect.swift
// Authors: Joey Huang, Anysa Manhas
//
// Copyright © 2018 Pit Bulls. All rights reserved.
//
// Class DataRun
// Aquires sensor data at a fixed frequency
// Writes data to memory buffer
// 

import Foundation
import CoreMotion

class DataRun {
    
    fileprivate let motionManager : CMMotionManager
    fileprivate var rot_rate : ([Double], [Double], [Double]) = ([],[],[])// = ([-1,0,1,2,4],[-1,0,1,2,4],[-1,0,1,2,4])
    fileprivate var user_accel: ([Double], [Double], [Double]) = ([],[],[])// = ([-1,0,1,2,4],[-1,0,1,2,4],[-1,0,1,2,4])
    fileprivate var rot_curr: (Double, Double, Double) = (0,0,0)
    fileprivate var accel_curr: (Double, Double, Double) = (0,0,0)
    fileprivate var isSuspended : Bool = false
    fileprivate var isRunning : Bool = false
    fileprivate var dataTimer: Timer!
    fileprivate var data_timestamp : Date!
    fileprivate var lastSaveDir: URL?
    fileprivate let fileManager = FileManager.default
    fileprivate enum colError: Error {
        case SaveDataEmpty
        case ReadDataEmpty
        case InvalidURL
    }
    
    //MARK: Public
    init()
    {
        motionManager = CMMotionManager()
        initMotionEvents()
    }
    
    // TODO: set refresh rate, reinit timer
    func config() 
    {
    }
    
    // disable recording, but acquire keeps running
    func suspend()
    {
        isSuspended = true
    }
    
    // enable recording
    func resume()
    {
        isSuspended = false
    }
    
    // start acquire
    func start() //start the timer
    {

        isRunning = true
        data_timestamp = Date()
        dataTimer = Timer.scheduledTimer(timeInterval: 1.0/100.0, target: self, selector: #selector(DataRun.get_data), userInfo: nil, repeats: true)
    }
    
    // stop acquire
    func end() //stop timer, write to DB
    {
        isRunning = false
        dataTimer.invalidate()
        if verifyWritten(){
            print("Data saved successfully to \(lastSaveDir?.absoluteString ?? "nil")\n")
        }else{
            print("Save data is corrupt\n")
        }
    }
    
<<<<<<< HEAD
    func return_accel() -> ([Double], [Double], [Double])?//function so that accel data can be accessed after a run
=======
    // gets acceleration buffer for saving
    func return_accel() -> [(Double, Double, Double)]//function so that accel data can be accessed after a run
>>>>>>> master
    {
        let rtn_accel = user_accel;
        return rtn_accel
    }
    
<<<<<<< HEAD
    func return_rotation() -> ([Double], [Double], [Double])?//function so that rotation data can be accessed after a run
=======
    // gets gyro buffer for saving
    func return_rotation() -> [(Double, Double, Double)]//function so that rotation data can be accessed after a run
>>>>>>> master
    {
        let rtn_gyro = rot_rate;
        return rtn_gyro
    }
    
    // get latest data sample
    func get_last_entry() -> [(Double, Double, Double)]{
        var rtn_val:[(Double, Double, Double)] = [];
        rtn_val.append(accel_curr);
        rtn_val.append(rot_curr);
        
        return rtn_val
    }
    
    func saveData() throws {
        if (isRunning || user_accel.0.isEmpty || rot_rate.0.isEmpty) {throw colError.SaveDataEmpty};
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let _date = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: data_timestamp ?? _date)
        let month = calendar.component(.month, from: data_timestamp ?? _date)
        let day = calendar.component(.day, from: data_timestamp ?? _date)
        let hour = calendar.component(.hour, from: data_timestamp ?? _date)
        let min = calendar.component(.minute, from: data_timestamp ?? _date)
        let sec = calendar.component(.second, from: data_timestamp ?? _date)
        var filename = paths[0].appendingPathComponent("TrackPoint", isDirectory: true)
        try? fileManager.createDirectory(at: filename, withIntermediateDirectories: true, attributes: nil)
        let namestr = "TPGSession-"+String(year)+"-"+String(month)+"-"+String(day)+"-"+String(hour)+"-"+String(min)+"-"+String(sec)
        filename = filename.appendingPathComponent(namestr)
        let filename_d = filename.appendingPathExtension("bin") // array data
        
        //print("dataURL: \(filename_d.absoluteString)\n")
        fileManager.createFile(atPath: filename_d.absoluteString, contents: nil)
        
        let wArray:[Double] = user_accel.0 + user_accel.1 + user_accel.2 + rot_rate.0 + rot_rate.1 + rot_rate.2
        
        let wData = Data(bytes: wArray, count: wArray.count * MemoryLayout<Double>.stride)
        
        
        do {
            // TODO: append
            try wData.write(to: filename_d)
            lastSaveDir = filename
        } catch {
            // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
            print("failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding\n\(error)\n")
        }
    }
    
    // test saves
    func verifyWritten() -> Bool {
        //if (lastSaveDir == nil) {return false};
        var isCorrect: Bool = true;
        do {
            try saveData()
            let filename_d = lastSaveDir!.appendingPathExtension("bin")
            let readArray = try readData(url: filename_d)
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
    fileprivate func arrayCMP(src0:[Double],src1:[Double],index:Int = -1) -> Bool {
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
    
    func readData(url:URL) throws -> [[Double]] {
        var rArray: [[Double]]  = [[],[],[],[],[],[]]
        
        do{
            let rData = try Data(contentsOf: url)
            var aArray:[Double]!
            rData.withUnsafeBytes{(bytes: UnsafePointer<Double>) in aArray = Array(UnsafeBufferPointer(start: bytes, count: rData.count / MemoryLayout<Double>.size))}
            let rACount:Int = Int(aArray.count/6)
            for i in 0..<6{
                rArray[i] = Array(aArray[i*rACount..<(i+1)*rACount])
            }
        }catch {
            throw colError.InvalidURL
        }
        if (rArray[0].isEmpty){
            throw colError.ReadDataEmpty
        }
        return rArray
    }
    
    //MARK: Private
    
    // CoreMotion init
    fileprivate func initMotionEvents()
    {
        //make sure deviceMotion is available
        //initialize deviceMotion parameters
        if motionManager.isDeviceMotionAvailable
        {
            self.motionManager.deviceMotionUpdateInterval = 1.0 / 100.0 //frequency of 100 Hz
            self.motionManager.showsDeviceMovementDisplay = true //for now (testing purposes)
            //not sure if we need a reference frame???
            self.motionManager.startDeviceMotionUpdates(using: .xMagneticNorthZVertical)
        }
        
        else
        {
            print("deviceMotion not available")
        }
        
    }
    
    // aquire sample from CoreMotion
    @objc fileprivate func get_data() //gets sensor data when not suspended, push to array
    {
        if let data = self.motionManager.deviceMotion
        {
            //print("getTimer: %lf,%lf,%lf\n", data.userAcceleration.x, data.userAcceleration.y, data.userAcceleration.z)
            accel_curr = (data.userAcceleration.x, data.userAcceleration.y, data.userAcceleration.z)
            rot_curr = (data.rotationRate.x, data.rotationRate.y, data.rotationRate.z)
            //user_accel.append((data.userAcceleration.x, data.userAcceleration.y, data.userAcceleration.z))
            //rot_rate.append((data.rotationRate.x, data.rotationRate.y, data.rotationRate.z))
            user_accel.0.append(accel_curr.0);user_accel.1.append(accel_curr.1);user_accel.2.append(accel_curr.2);
            rot_rate.0.append(rot_curr.0);rot_rate.1.append(rot_curr.1);rot_rate.2.append(rot_curr.2);
        }
    }
    
    
    
    
}


