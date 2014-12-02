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
    shipBulletAsteroidCollision(firstBody, secondBody)
    energyCollision(firstBody, secondBody)
    asteroidCollision(firstBody, secondBody)
    
}


func energyCollision(firstBody: SKPhysicsBody, secondBody: SKPhysicsBody){
    if ((firstBody.categoryBitMask & Contact.Ship != 0)
        && (secondBody.categoryBitMask & Contact.Energy != 0)) {
            //done to make sure removed from array too
            secondBody.node!.position.y = viewSize.height * -0.1
            println("energy")
    }
    
}

func asteroidCollision(firstBody: SKPhysicsBody, secondBody: SKPhysicsBody){
    if ((firstBody.categoryBitMask & Contact.Ship != 0)
        && (secondBody.categoryBitMask & Contact.Asteroid != 0)) {
            //done to make sure removed from array too
            secondBody.node!.position.y = viewSize.height * -0.1
            println("asteroid")
    }
    
}

func shipBulletAsteroidCollision(firstBody: SKPhysicsBody, secondBody: SKPhysicsBody){
    if ((firstBody.categoryBitMask & Contact.Asteroid != 0)
        && (secondBody.categoryBitMask & Contact.ShipBullet != 0)) {
            //done to make sure removed from array too
            firstBody.node!.position.y = viewSize.height * -0.1
            secondBody.node!.removeFromParent() //remove this and have continues bullet
            println("hit")
    }
    
}
