//
//  Star.swift
//  Space Race
//
//  Created by Max Takano on 11/13/14.
//  Copyright (c) 2014 Max Takano. All rights reserved.
//

import SpriteKit

class Star:SKSpriteNode {
//    let startPosition = CGPoint(x: viewSize.width * 0.5, y: viewSize.height * 0.2)
    let nameStar = "Pretty Star"
    
    override init(texture: SKTexture!, color: UIColor!, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        
        self.starSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func starSetup() {
        self.setScale(CGFloat(0.1))
        
        // Texture Properties
        self.texture?.filteringMode = SKTextureFilteringMode.Nearest
        
        // Position
//        self.position = startPosition
        let randomX = getRandom(min: CGFloat(0.0), CGFloat(1.0))
        self.position = CGPoint(x: viewSize.width * randomX, y:viewSize.height * 1.1)
        self.zRotation = getRandom(min: CGFloat(0.0), CGFloat(6.28))
        self.zPosition = GameLayer.Stars
        
        // Other Properites
        self.name = nameStar
        
        // Physics
        self.physicsBody = SKPhysicsBody(circleOfRadius: self.size.height / 2)
        self.physicsBody?.dynamic = true
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.linearDamping = 1.0
        self.physicsBody?.angularDamping = 1.0
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.categoryBitMask = Contact.Star
        self.physicsBody?.collisionBitMask = Contact.Star
        //self.physicsBody?.contactTestBitMask =
        //        self.physicsBody?.collisionBitMask = Contact.Alien | Contact.AlienMissile | Contact.AlienTorpedo
        //        self.physicsBody?.contactTestBitMask = Contact.Alien | Contact.AlienMissile | Contact.AlienTorpedo
        
//        self.physicsBody?.velocity = CGVectorMake(0.0, -100.0)
        
        
        
//        let actionMoveDown = SKAction.moveTo(CGPoint(x: size.width * randomX, y: size.height * 0.0), duration: NSTimeInterval(6.0))
//        
//        let actionMoveDone = SKAction.removeFromParent()
//        
//        star.runAction(SKAction.sequence([actionMoveDown, actionMoveDone]))
    }
    
    func updateVelocity(newVelocity: Int) {
        self.physicsBody?.velocity = CGVectorMake(0.0, -1.0 * CGFloat(newVelocity) )
    }

}
