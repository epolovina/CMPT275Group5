//
//  collect.swift
//  TestProject
//
//  Created by Anysa Manhas on 2018-10-24.
//  Copyright © 2018 Anysa Manhas. All rights reserved.

import Foundation
import CoreMotion

class DataRun {
    
    let motionManager : CMMotionManager
    fileprivate var rot_rate : [(Double, Double, Double)] = []
    fileprivate var user_accel: [(Double, Double, Double)] = []
    fileprivate var isSuspended : Bool = false
    fileprivate var dataTimer: Timer!
    fileprivate var data_timestamp : Date?
    
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
        data_timestamp = Date()
        dataTimer = Timer.scheduledTimer(timeInterval: 1.0/100.0, target: self, selector: #selector(DataRun.get_data), userInfo: nil, repeats: true)
    }
    
    func end() //stop timer, write to DB
    {
        dataTimer.invalidate()
    }
    
    func return_accel() -> [(Double, Double, Double)]//function so that accel data can be accessed after a run
    {
        let rtn_accel = user_accel;
        return rtn_accel
    }
    
    func return_rotation() -> [(Double, Double, Double)]//function so that rotation data can be accessed after a run
    {
        let rtn_gyro = rot_rate;
        return rtn_gyro
    }
    
    func get_last_entry() -> [(Double, Double, Double)]{
        //
        let accel:(Double, Double, Double) = user_accel[user_accel.count-1];
        let gyro:(Double, Double, Double) = rot_rate[rot_rate.count-1];
        var rtn_val:[(Double, Double, Double)] = [];
        rtn_val.append(accel);
        rtn_val.append(gyro);
        
        return rtn_val
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
            //self.motionManager.startDeviceMotionUpdates(using: .xMagneticNorthZVertical)
        }
        
        else
        {
            print("deviceMotion not available")
        }
        
    }
    
    @objc fileprivate func get_data() //gets sensor data when not suspended, push to array
    {
        if isSuspended{
            return;
        }
        if let data = self.motionManager.deviceMotion
        {
            user_accel.append((data.userAcceleration.x, data.userAcceleration.y, data.userAcceleration.z))
            rot_rate.append((data.rotationRate.x, data.rotationRate.y, data.rotationRate.z))
        }
    }
    
    
    
    
}


