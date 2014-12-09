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
    var distTraveled:Double = 0.0
    
    var turnSpeed = 100
    var forwardSpeed = 50
    
    var canShield = true
    let shieldImage = SKTexture(imageNamed: "shield")
    
    var laserActive = false
    
    enum states {
        case NORMAL
        case SHIELDING
        case PELLETGUN
        case LASER
    }
    
    var shipState = states.NORMAL
    
    override init(texture: SKTexture!, color: UIColor!, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        
        self.shipSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func shield() {
        shipState = states.SHIELDING
        
        let active = SKSpriteNode(texture: shieldImage, color: SKColor.whiteColor(), size: shieldImage.size())
        active.name = "Shield"
        active.zPosition = GameLayer.Shield
        self.addChild(active)
    }
    
    func unShield() {
        shipState = states.NORMAL
        self.childNodeWithName("Shield")?.removeFromParent()
    }
    
    // pellet gun stuff
    func pelletGun() {
        shipState = states.PELLETGUN
    }
    
    func laser() {
        shipState = states.LASER
    }
    
    func getLaserActive() -> Bool {
        return laserActive
    }
    
    func activeLaser(laserBullet: LaserBullet) {
        //self.addChild(laserBullet)
        laserActive = true
    }
    
    func deactiveLaser(laserBullet: LaserBullet) {
        //laserBullet.removeFromParent()
        laserActive = false
    }
    
    func shipSetup() {
        // Texture Properties
        self.texture?.filteringMode = SKTextureFilteringMode.Nearest
        
        // Position
        self.position = startPosition
        self.zPosition = GameLayer.Game
        
        // Other Properites
        self.name = nameShip
        
        self.setScale(0.45)
        
        // Physics
        //self.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.size.width/2, self.size.height/1.2))
        self.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.size.width * 0.35, self.size.height * 0.7), center: CGPointMake(0, self.size.height*0.10))
        //self.physicsBody = SKPhysicsBody(circleOfRadius: self.size.height / 2.5)
        self.physicsBody?.dynamic = true
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.linearDamping = 1.0
        self.physicsBody?.angularDamping = 1.0
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.categoryBitMask = Contact.Ship
        
        self.physicsBody?.collisionBitMask = Contact.Frame
        self.physicsBody?.contactTestBitMask = Contact.Asteroid | Contact.PelletGunPowerup | Contact.Energy | Contact.LaserPowerup
    }
 
}
