//
//  LaserBullet.swift
//  Space Race
//
//  Created by Tim K on 12/7/14.
//  Copyright (c) 2014 Max Takano. All rights reserved.
//

import Foundation
import SpriteKit

class LaserBullet:SKSpriteNode {
    let nameLaserBullet = "LaserBullet"
    //    let bulletSize = CGSizeMake(4, 8)
    
    override
    init(texture: SKTexture!, color: UIColor!, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
//        makeLaserBullet()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeLaserBullet(spaceShip: SpaceShip){
        // Texture Properties
        self.texture?.filteringMode = SKTextureFilteringMode.Nearest
        
        self.name = nameLaserBullet
        
        // Position
//        self.position = CGPointMake(self.position.x, spaceShip.position.y + spaceShip.frame.size.height + (self.size.height/4))
        self.position = CGPointMake(spaceShip.position.x, spaceShip.position.y + spaceShip.frame.size.height + (self.size.height/1.7))
        self.zPosition = GameLayer.Game
        
        // Other Properites
        
        // Physics
        self.physicsBody = SKPhysicsBody(rectangleOfSize: self.size)
        //        //self.physicsBody = SKPhysicsBody(texture: self.texture?, size: self.texture!.size())
//        self.physicsBody?.dynamic = true
//        self.physicsBody?.allowsRotation = false
//        self.physicsBody?.linearDamping = 1.0
//        self.physicsBody?.angularDamping = 1.0
//        self.physicsBody?.affectedByGravity = false
//        self.physicsBody?.mass = 0.01

        self.physicsBody?.mass = 0.0361267
        
        
        
        self.physicsBody?.dynamic = true
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.linearDamping = 1.0
        self.physicsBody?.angularDamping = 1.0
        self.physicsBody?.affectedByGravity = false

        
        
        
//        self.physicsBody?.pinned = true
        self.physicsBody?.categoryBitMask = Contact.Laser
        
        self.physicsBody?.collisionBitMask = Contact.Frame
        self.physicsBody?.contactTestBitMask = Contact.Asteroid
    }
    
    //func update
    
    

}
