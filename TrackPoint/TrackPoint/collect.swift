//
//  collect.swift
//  TestProject
//
//  Created by Anysa Manhas on 2018-10-24.
//  Copyright © 2018 Anysa Manhas. All rights reserved.

import Foundation
import CoreMotion

class DataRun {
    
    fileprivate let motionManager : CMMotionManager
    fileprivate var rot_rate : ([Double], [Double], [Double]) = ([],[],[])
    fileprivate var user_accel: ([Double], [Double], [Double]) = ([],[],[])
    fileprivate var rot_curr: (Double, Double, Double) = (0,0,0)
    fileprivate var accel_curr: (Double, Double, Double) = (0,0,0)
    fileprivate var isSuspended : Bool = false
    fileprivate var isRunning : Bool = false
    fileprivate var dataTimer: Timer!
    fileprivate var data_timestamp : Date!
    fileprivate var lastSaveDir: URL?
    fileprivate let fileManager = FileManager.default
    
    //MARK: Public
    init()
    {
        motionManager = CMMotionManager()
        initMotionEvents()
    }
    
    func config() //refresh rate, reinit timer
    {
        // not sure if this is needed?
    }
    
    func suspend()
    {
        isSuspended = true
    }
    
    func resume()
    {
        isSuspended = false
    }
    
    func start() //start the timer
    {
        isRunning = true
        data_timestamp = Date()
        dataTimer = Timer.scheduledTimer(timeInterval: 1.0/100.0, target: self, selector: #selector(DataRun.get_data), userInfo: nil, repeats: true)
    }
    
    func end() //stop timer, write to DB
    {
        isRunning = false
        dataTimer.invalidate()
        saveData()
    }
    
    func return_accel() -> ([Double], [Double], [Double])?//function so that accel data can be accessed after a run
    {
        let rtn_accel = user_accel;
        return rtn_accel
    }
    
    func return_rotation() -> ([Double], [Double], [Double])?//function so that rotation data can be accessed after a run
    {
        let rtn_gyro = rot_rate;
        return rtn_gyro
    }
    
    func get_last_entry() -> [(Double, Double, Double)]{
        var rtn_val:[(Double, Double, Double)] = [];
        rtn_val.append(accel_curr);
        rtn_val.append(rot_curr);
        
        return rtn_val
    }
    
    func saveData(){
        if (isRunning || user_accel.0.isEmpty || rot_rate.0.isEmpty) {return};
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let _date = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: data_timestamp ?? _date)
        let month = calendar.component(.month, from: data_timestamp ?? _date)
        let day = calendar.component(.day, from: data_timestamp ?? _date)
        let hour = calendar.component(.hour, from: data_timestamp ?? _date)
        let min = calendar.component(.minute, from: data_timestamp ?? _date)
        let sec = calendar.component(.second, from: data_timestamp ?? _date)
        var filename = paths[0].appendingPathComponent("TrackPoint/TPGSession-")
        filename = filename.appendingPathComponent(String(year))
        filename = filename.appendingPathComponent("-")
        filename = filename.appendingPathComponent(String(month))
        filename = filename.appendingPathComponent("-")
        filename = filename.appendingPathComponent(String(day))
        filename = filename.appendingPathComponent("-")
        filename = filename.appendingPathComponent(String(hour))
        filename = filename.appendingPathComponent("-")
        filename = filename.appendingPathComponent(String(min))
        filename = filename.appendingPathComponent("-")
        filename = filename.appendingPathComponent(String(sec))
        filename = filename.appendingPathComponent(".bin")
        
        let wData_accel = (Data(bytes: &user_accel.0, count: user_accel.0.count * MemoryLayout<Double>.stride),Data(bytes: &user_accel.1, count: user_accel.1.count * MemoryLayout<Double>.stride),Data(bytes: &user_accel.2, count: user_accel.2.count * MemoryLayout<Double>.stride))
        let wData_rot = (Data(bytes: &rot_rate.0, count: rot_rate.0.count * MemoryLayout<Double>.stride),Data(bytes: &rot_rate.1, count: rot_rate.1.count * MemoryLayout<Double>.stride),Data(bytes: &rot_rate.2, count: rot_rate.2.count * MemoryLayout<Double>.stride))
        
        do {
            try wData_accel.0.write(to: filename)
            try wData_rot.0.write(to: filename)
            lastSaveDir = filename
        } catch {
            // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
        }
    }
    
    func readData(url:URL) -> [[Double]] {
        var rArray: [[Double]]  = [[],[],[],[],[],[]]
        
        do{
            let rData = try! Data(contentsOf: url)
            var aArray:[Double]!
            rData.withUnsafeBytes{(bytes: UnsafePointer<Double>) in aArray = Array(UnsafeBufferPointer(start: bytes, count: rData.count / MemoryLayout<Double>.size))}
            let rACount:Int = Int(rData.count/6)
            for i in 0..<6{
                rArray[i] = Array(aArray[i*rACount..<(i+1)*rACount])
            }
        }catch {
        }

        return rArray
    }
    
    //MARK: Private
    
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


