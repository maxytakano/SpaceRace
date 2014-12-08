//
//  Asteroid.swift
//  Space Race
//
//  Created by Max Takano on 11/13/14.
//  Copyright (c) 2014 Max Takano. All rights reserved.
//

import Foundation
import SpriteKit

class Asteroid:SKSpriteNode {
    //    let startPosition = CGPoint(x: viewSize.width * 0.5, y: viewSize.height * 0.2)
    let nameAsteroid = "Asteroid"
    
    override init(texture: SKTexture!, color: UIColor!, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        
        self.asteroidSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func asteroidSetup() {
        self.setScale(CGFloat(1.4))
        
        // Texture Properties
        self.texture?.filteringMode = SKTextureFilteringMode.Nearest
        
        // Position
        let randomX = getRandom(min: CGFloat(0.0), CGFloat(1.0))
        self.position = CGPoint(x: viewSize.width * randomX, y:viewSize.height * 1.1)
        self.zRotation = getRandom(min: CGFloat(0.0), CGFloat(6.28))
        self.zPosition = GameLayer.Game
        
        // Other Properites
        self.name = nameAsteroid
        
        // Physics
        self.physicsBody = SKPhysicsBody(circleOfRadius: self.size.height/2)
        self.physicsBody?.dynamic = true
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.linearDamping = 1.0
        self.physicsBody?.angularDamping = 1.0
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.categoryBitMask = Contact.Asteroid
        
        self.physicsBody?.collisionBitMask = Contact.Ship
        self.physicsBody?.contactTestBitMask = Contact.Ship
        
    }
    
    func updateVelocity(newVelocity: Int) {
        self.physicsBody?.velocity = CGVectorMake(0.0, -1.0 * CGFloat(newVelocity) )
    }
    
//    func rotateAsteroid() {
//        self.zRotation = 0.1
//    }
}