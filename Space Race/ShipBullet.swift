//
//  Bullet.swift
//  Space Race
//
//  Created by Tim K on 11/30/14.
//  Copyright (c) 2014 Max Takano. All rights reserved.
//

import Foundation
import SpriteKit

class ShipBullet:SKSpriteNode {
    let nameShipBullet = "ShipBullet"
//    let bulletSize = CGSizeMake(4, 8)
    
    override
    init(texture: SKTexture!, color: UIColor!, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        self.makeShipBullet()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func makeShipBullet(){
        self.setScale(CGFloat(0.2))
        
        // Texture Properties
        self.texture?.filteringMode = SKTextureFilteringMode.Nearest
        
        // Position
        self.zPosition = GameLayer.Game
        
        // Other Properites
        self.name = nameShipBullet
        
        var bulletSize = 10
        
        // Physics
        self.physicsBody = SKPhysicsBody(circleOfRadius: self.size.height / 2)
        //self.physicsBody = SKPhysicsBody(texture: self.texture?, size: self.texture!.size())
        self.physicsBody?.dynamic = true
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.linearDamping = 1.0
        self.physicsBody?.angularDamping = 1.0
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.categoryBitMask = Contact.ShipBullet
        
        self.physicsBody?.collisionBitMask = Contact.Asteroid
        self.physicsBody?.contactTestBitMask = Contact.Asteroid
        
    }
    
//    func updateVelocity(newVelocity: Int) {
//        self.physicsBody?.velocity = CGVectorMake(0.0, CGFloat(newVelocity) )
//    }
    
}