//
//  MotionManager.swift
//  Space Race
//
//  Created by Max Takano on 11/13/14.
//  Copyright (c) 2014 Max Takano. All rights reserved.
//

//import SpriteKit

//func updatePosition(node: SKNode) {
//        //println("hi", self.newData.acceleration.x)
////        if (self.newData.acceleration.x < -0.2) { // tilting the device to the right
////            //                node.physicsBody?.applyForce(CGVectorMake(0.0, 0.0))
////            accel = self.newData.acceleration.x * Double(speed)
////            println(accel)
////            node.physicsBody?.applyForce(CGVectorMake(CGFloat(accel), 0.0))
////            //                self.motionManager.accelerometerActive == true;
////
////        } else if (self.newData.acceleration.x > 0.2) { // tilting the device to the left
////            accel = self.newData.acceleration.x * Double(speed)
////            println(accel)
////            node.physicsBody?.applyForce(CGVectorMake(CGFloat(accel), 0.0))
////            //                node.physicsBody?.applyForce(CGVectorMake(40*data.acceleration.x, 0.0))
////            //                self.motionManager.accelerometerActive == true;
////        }
//
//    if let data = motionManager.accelerometerData {
//
//        // 3
//        if (fabs(data.acceleration.x) > 0.2) {
//
//            // 4 How do you move the ship?
//            ship.physicsBody!.applyForce(CGVectorMake(40.0 * CGFloat(data.acceleration.x), 0))
//
//        }
//    }
//
//}

//
//let MotionManagerSharedInstance = MotionManager()
//
//class MotionManager:CMMotionManager {
//    
//    var isUpdating = false
//    var newData:CMAccelerometerData!
//    
//    class var sharedInstance:MotionManager {
//        return MotionManagerSharedInstance
//    }
//    
//    func startMotionManager() {
//        println("hey")
//        if !self.deviceMotionActive {
//            self.deviceMotionUpdateInterval = 0.1
//           
////            self.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue()) {
////                (data, error) in
////                self.isUpdating = true
////                data.ac
////            }
//            
//            self.startAccelerometerUpdates()
//            
//            self.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue(), withHandler: {
//                (daData, error) in
//                //println(daData)
//                self.isUpdating = true
//                self.newData = daData
//            })
//            
//            
////            self.startDeviceMotionUpdatesUsingReferenceFrame(CMAttitudeReferenceFrameXArbitraryCorrectedZVertical, toQueue: NSOperationQueue.currentQueue(), withHandler: {
////                    deviceManager, error in
////                self.isUpdating = true
////            })
//        }
//    }
//    
//    //        if (motionManager.accelerometerAvailable) {
//    //            motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue()) {
//    //                (data, error) in
//    ////                let currentX = self.player.position.x
//    ////                let currentY = self.player.position.y
//    ////                if(data.acceleration.x < -0.01) { // tilting the device to the right
//    ////                    var destX = (CGFloat(data.acceleration.x) * CGFloat(self.kPlayerSpeed) + CGFloat(currentX))
//    ////                    var destY = CGFloat(currentY)
//    ////                    self.motionManager.accelerometerActive == true;
//    ////                    let action = SKAction.moveTo(CGPointMake(destX, destY), duration: 1)
//    ////                    self.player.runAction(action)
//    ////                } else if (data.acceleration.x > 0.01) { // tilting the device to the left
//    ////                    var destX = (CGFloat(data.acceleration.x) * CGFloat(self.kPlayerSpeed) + CGFloat(currentX))
//    ////                    var destY = CGFloat(currentY)
//    ////                    self.motionManager.accelerometerActive == true;
//    ////                    let action = SKAction.moveTo(CGPointMake(destX, destY), duration: 1)
//    ////                    self.player.runAction(action)
//    ////                }
//    //                if(data.acceleration.x < -0.01) { // tilting the device to the right
//    ////                    self.player.physicsBody?.applyForce(CGVectorMake(0.0, 0.0))
//    //
//    //                    var accel = data.acceleration.x * 40
//    //                    self.player.physicsBody?.applyForce(CGVectorMake(CGFloat(accel), 0.0))
//    //                    self.motionManager.accelerometerActive == true;
//    //
//    //                } else if (data.acceleration.x > 0.01) { // tilting the device to the left
//    //                    var accel = data.acceleration.x * 40
//    //                    self.player.physicsBody?.applyForce(CGVectorMake(CGFloat(accel), 0.0))
//    ////                    self.player.physicsBody?.applyForce(CGVectorMake(40*data.acceleration.x, 0.0))
//    //                    self.motionManager.accelerometerActive == true;
//    //                }
//    //            }
//    //        }
//    
//    
//    func stopMotionManager() {
//        println("yo")
//        if self.deviceMotionActive {
//            self.stopDeviceMotionUpdates()
//            self.isUpdating = false
//        }
//    }
//    
//    func radiansToDegrees(radians:Double) -> CGFloat {
//        return CGFloat(radians * 180 / M_PI)
//    }
//    
//    var speed = 100
//    var accel = 0.0
//    func updatePosition(node: SKNode) {
//        //println("hi", self.newData.acceleration.x)
////        if (self.newData.acceleration.x < -0.2) { // tilting the device to the right
////            //                node.physicsBody?.applyForce(CGVectorMake(0.0, 0.0))
////            accel = self.newData.acceleration.x * Double(speed)
////            println(accel)
////            node.physicsBody?.applyForce(CGVectorMake(CGFloat(accel), 0.0))
////            //                self.motionManager.accelerometerActive == true;
////            
////        } else if (self.newData.acceleration.x > 0.2) { // tilting the device to the left
////            accel = self.newData.acceleration.x * Double(speed)
////            println(accel)
////            node.physicsBody?.applyForce(CGVectorMake(CGFloat(accel), 0.0))
////            //                node.physicsBody?.applyForce(CGVectorMake(40*data.acceleration.x, 0.0))
////            //                self.motionManager.accelerometerActive == true;
////        }
//        
//        if let data = motionManager.accelerometerData {
//            
//            // 3
//            if (fabs(data.acceleration.x) > 0.2) {
//                
//                // 4 How do you move the ship?
//                ship.physicsBody!.applyForce(CGVectorMake(40.0 * CGFloat(data.acceleration.x), 0))
//                
//            }
//        }
//        
//    }
//}