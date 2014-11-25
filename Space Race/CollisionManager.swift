//
//  CollisionManager.swift
//  Space Race
//
//  Created by Tim K on 11/23/14.
//  Copyright (c) 2014 Max Takano. All rights reserved.
//

import Foundation
import CoreMotion
import SpriteKit


func collisionManager(firstBody: SKPhysicsBody, secondBody: SKPhysicsBody){
    energyCollision(firstBody, secondBody)
    
    
}


func energyCollision(firstBody: SKPhysicsBody, secondBody: SKPhysicsBody){
    if ((firstBody.categoryBitMask & Contact.Ship != 0)
        && (secondBody.categoryBitMask & Contact.Energy != 0)) {
            //done to make sure removed from array too
            secondBody.node!.position.y = viewSize.height * -0.1
            println("energy")
    }
    
}

