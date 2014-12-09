//
//  Queue.swift
//  Space Race
//
//  Created by Jason Wong on 12/6/14.
//  Copyright (c) 2014 Max Takano. All rights reserved.
//

import Foundation
import GameKit

public class Queue<T> {
    private var top: QNode<T>!
    private var bottom: QNode<T>!
    var size = 0

    
    init() {
        
    }
    
    func enqueue(var key: T) {
        if(top == nil) {
            top = QNode(key: key)
            bottom = top
            size++
            return
        }
        var toAdd : QNode<T> = QNode<T>(key: key)
        bottom.next = toAdd
        size++
        bottom = bottom.next
    }
    
    func dequeue() -> T? {
        if(top == nil) {
            return nil
        }
        
        let toRet : T = top.key
        
        top = top.next
        size--
        return toRet
    }
    
    func peek() -> T? {
        return top.key
    }
}

class QNode<T> {
    var key: T! = nil
    var next: QNode? = nil
    
    init(key : T) {
        self.key = key
    }
}

class SKCoordinates : NSObject, NSCoding {
    var starX : Int?
    var energyX : Int?
    var asteroidX : Int?
    var starRot : Int?
    var energyRot : Int?
    var asteroidRot : Int?
    
    init(starX: Int, energyX: Int, asteroidX: Int, starRot : Int, energyRot : Int, asteroidRot : Int) {
        self.starX = starX
        self.energyX = energyX
        self.asteroidX = asteroidX
        self.starRot = starRot
        self.energyRot = energyRot
        self.asteroidRot = asteroidRot
    }
    
    required init(coder aDecoder: NSCoder) {
        self.starX = aDecoder.decodeObjectForKey("starX") as Int?
        self.energyX = aDecoder.decodeObjectForKey("energyX") as Int?
        self.asteroidX = aDecoder.decodeObjectForKey("asteroidX") as Int?
        self.starRot = aDecoder.decodeObjectForKey("starRot") as Int?
        self.energyRot = aDecoder.decodeObjectForKey("energyRot") as Int?
        self.asteroidRot = aDecoder.decodeObjectForKey("asteroidRot") as Int?

    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.starX, forKey: "starX")
        aCoder.encodeObject(self.energyX, forKey: "energyX")
        aCoder.encodeObject(self.asteroidX, forKey: "asteroidX")
        aCoder.encodeObject(self.starRot, forKey: "starRot")
        aCoder.encodeObject(self.energyRot, forKey: "energyRot")
        aCoder.encodeObject(self.asteroidRot, forKey: "asteroidRot")

    }
}
