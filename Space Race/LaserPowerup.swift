//
//  LaserPowerup.swift
//  Space Race
//
//  Created by Tim K on 12/7/14.
//  Copyright (c) 2014 Max Takano. All rights reserved.
//

import Foundation
import SpriteKit

class LaserPowerup:SKSpriteNode {
    //    let startPosition = CGPoint(x: viewSize.width * 0.5, y: viewSize.height * 0.2)
    let namePowerup = "LaserPowerup"
    
    override init(texture: SKTexture!, color: UIColor!, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        
        self.laserGunPowerupSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func laserGunPowerupSetup() {
        // Texture Properties
        self.texture?.filteringMode = SKTextureFilteringMode.Nearest
        
        // Position
        let randomX = getRandom(min: CGFloat(0.0), CGFloat(1.0))
        self.position = CGPoint(x: viewSize.width * randomX, y:viewSize.height)
        self.zRotation = getRandom(min: CGFloat(0.0), CGFloat(6.28))
        self.zPosition = GameLayer.Game
        
        // Other Properites
        self.name = namePowerup
        
        // Physics
        self.physicsBody = SKPhysicsBody(circleOfRadius: self.size.height / 2)
        self.physicsBody?.dynamic = true
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.linearDamping = 1.0
        self.physicsBody?.angularDamping = 1.0
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.categoryBitMask = Contact.LaserPowerup
        
        self.physicsBody?.collisionBitMask = Contact.Ship
        self.physicsBody?.contactTestBitMask = Contact.Ship
        
    }
    
    
    func updateVelocity(newVelocity: Int) {
        self.physicsBody?.velocity = CGVectorMake(0.0, -1.0 * CGFloat(newVelocity) )
    }
}
