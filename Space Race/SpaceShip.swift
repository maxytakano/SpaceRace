//
//  SpaceShip.swift
//  Space Race
//
//  Created by Max Takano on 11/13/14.
//  Copyright (c) 2014 Max Takano. All rights reserved.
//

import SpriteKit

class SpaceShip:SKSpriteNode {
    let startPosition = CGPoint(x: viewSize.width * 0.5, y: viewSize.height * 0.2)
    let nameShip = "NoobShip"
    
    var turnSpeed = 100
    var forwardSpeed = 50
    
    override init(texture: SKTexture!, color: UIColor!, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        
        self.shipSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func shipSetup() {
        // Texture Properties
        self.texture?.filteringMode = SKTextureFilteringMode.Nearest
        
        // Position
        self.position = startPosition
        self.zPosition = GameLayer.Game
        
        // Other Properites
        self.name = nameShip
        
        // Physics
        self.physicsBody = SKPhysicsBody(circleOfRadius: self.size.height / 2)
        self.physicsBody?.dynamic = true
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.linearDamping = 1.0
        self.physicsBody?.angularDamping = 1.0
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.categoryBitMask = Contact.Ship
        self.physicsBody?.collisionBitMask = Contact.Asteroid
        self.physicsBody?.contactTestBitMask = Contact.Asteroid | Contact.Energy
//        self.physicsBody?.collisionBitMask = Contact.Alien | Contact.AlienMissile | Contact.AlienTorpedo
//        self.physicsBody?.contactTestBitMask = Contact.Alien | Contact.AlienMissile | Contact.AlienTorpedo
    }
}
