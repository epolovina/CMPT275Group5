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
    fileprivate let fileMan = LocalDataManager()
    fileprivate let procFFT = FFT()
    
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
        
        do{
        try fileMan.saveData(accel: user_accel, rot: rot_rate, timestamp: data_timestamp)
        } catch{
            print("Saving Error (Non-fatal): \(error)\n")
            return
        }
        
        if fileMan.verifyWritten(){
            print("Data saved successfully to \(lastSaveDir?.absoluteString ?? "nil")\n")
        }else{
            print("Save data is corrupt\n")
        }
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


