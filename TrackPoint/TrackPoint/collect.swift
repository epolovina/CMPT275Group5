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
    private static let inst = DataRun()
    fileprivate let motionManager : CMMotionManager
    fileprivate var rot_rate : ([Double], [Double], [Double]) = ([],[],[])
    fileprivate var user_accel: ([Double], [Double], [Double]) = ([],[],[])
    fileprivate var rot_curr: (Double, Double, Double) = (0,0,0)
    fileprivate var accel_curr: (Double, Double, Double) = (0,0,0)
    fileprivate var isSuspended : Bool = false
    fileprivate var isRunning : Bool = false
    fileprivate var dataTimer: Timer?
    fileprivate var data_timestamp : Date?
    fileprivate var lastSaveDir: URL?
    fileprivate let fileMan = LocalDataManager.shared()
    fileprivate let procFFT = FFT()
    fileprivate var fps:Double = 100
    internal var isDebug = false
    
    class func shared()->DataRun{
        return inst
    }
    
    public func getDate()->Date?{
        return data_timestamp
    }
    
    private init()
    {
        motionManager = CMMotionManager()
        initMotionEvents()
        
        if isDebug{
            // generate test data
            let n:Int = Int(pow(Double(2),Double(16)))
            
            let frequency1:Double = 4; // Freq of test data
            let phase1:Double = 0.0; // not used
            let amplitude1:Double = 10; // amplitude of test data
            let sineWave1:[Double] = (0..<n).map {
                amplitude1 * sin(2.0 * .pi / fps * Double($0) * frequency1 + phase1)
            }
            
            let frequency2:Double = 7; // Freq of test data
            let phase2:Double = 0.0; // not used
            let amplitude2:Double = 10; // amplitude of test data
            let sineWave2:[Double] = (0..<n).map {
                amplitude2 * sin(2.0 * .pi / fps * Double($0) * frequency2 + phase2)
            }
            
            //let zeros:[Double] = (0..<n).map {Double($0) - Double($0)}
            
            user_accel = (sineWave1,sineWave1,sineWave1)
            rot_rate = (sineWave2,sineWave2,sineWave2)
            // test data end
        }
    }
    
    // set sample rate, and possible others in future
    func config(_fps:Double = 100)
    {
        if (fps == _fps) {return};
        fps = _fps;
        if isRunning{
            end()
            rot_rate = ([],[],[])
            user_accel = ([],[],[])
            rot_curr = (0,0,0)
            accel_curr = (0,0,0)
            start()
        }
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
        dataTimer = Timer.scheduledTimer(timeInterval: 1.0/fps, target: self, selector: #selector(DataRun.get_data), userInfo: nil, repeats: true)
    }
    
    // stop acquire
    func end() //stop timer, write to DB
    {
        isRunning = false
        dataTimer?.invalidate()
    }
    
    //saves current session to disk
    func save(_ verify:Bool = true){
        do{
            try fileMan.saveData(accel: user_accel, rot: rot_rate, timestamp: data_timestamp)
        } catch{
            print("Saving Error (Non-fatal): \(error)\n")
            return
        }
        
        if !verify{return;}
        if fileMan.verifyWritten(){
            print("Data saved successfully to \(fileMan.getLastDir()?.absoluteString ?? "nil")\n")
        }else{
            print("Save data failed\n")
        }
    }
    
    // process current session
    // returns accel, gyro power spectrum and etc. refer to gdocs for format
    func processAll()->[(([Double],[Double]),Double,Double)]{
        let gaccel:[[Double]] = [rot_rate.0, rot_rate.1, rot_rate.2]
        let daccel:[[Double]] = [user_accel.0, user_accel.1, user_accel.2]
        return [procFFT.process(daccel, _fps: fps), procFFT.process(gaccel, _fps: fps)]
    }
    
    // gets acceleration buffer for saving
    func return_accel() -> ([Double], [Double], [Double])?//function so that accel data can be accessed after a run
    {
        let rtn_accel = user_accel;
        return rtn_accel
    }
    
    // gets gyro buffer for saving
    func return_rotation() -> ([Double], [Double], [Double])?//function so that rotation data can be accessed after a run
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
        if let data = self.motionManager.deviceMotion {
            //print("getTimer: %lf,%lf,%lf\n", data.userAcceleration.x, data.userAcceleration.y, data.userAcceleration.z)
            accel_curr = (data.userAcceleration.x, data.userAcceleration.y, data.userAcceleration.z)
            rot_curr = (data.rotationRate.x, data.rotationRate.y, data.rotationRate.z)
            if !isDebug {
                user_accel.0.append(accel_curr.0);user_accel.1.append(accel_curr.1);user_accel.2.append(accel_curr.2);
                rot_rate.0.append(rot_curr.0);rot_rate.1.append(rot_curr.1);rot_rate.2.append(rot_curr.2);
            }
        }
    }
    
    
    
    
}


