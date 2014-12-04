//
//  GameScene.swift
//  Space Race
//
//  Created by Max Takano on 11/6/14.
//  Copyright (c) 2014 Max Takano. All rights reserved.
//

import SpriteKit
import CoreMotion

class MultiplayerStaging: SKScene, SKPhysicsContactDelegate, MultiplayerNetworkingProtocol {
    
    let motionManager: CMMotionManager = CMMotionManager()
    
    /****************/
    var networkingEngine:MultiplayerNetworking!
    
    
    let nameShipBullet = "ShipBullet"
    let nameShip = "NoobShip"
    
    var tapQueue: Array<Int> = []
    
    var ship:SpaceShip!
    /****************/
    var enemyShip:SpaceShip?
    /****************/
    var stars:NSMutableArray
    var energies:NSMutableArray
    var asteroids:NSMutableArray
    var contactQueue = Array<SKPhysicsContact>()
    
    var boosting = false
    var braking = false
    var centiseconds:Int
    var centisecondsPerStar:Int
    var spanTime:Double
    var starsOnScreen:Double
    var starsPerSecond:Double
    var starsPerCentisecond:Double
    
    var contentCreated = false
    
    // play state:
    // 0 equals staging, 1 equals playing, 2 = ???
    var playState = 0
    
    override init(size: CGSize) {
        stars = []
        energies = []
        asteroids = []
        centiseconds = 0
        centisecondsPerStar = 1
        spanTime = 0.0
        starsOnScreen = 23.0
        starsPerSecond = 0.0
        starsPerCentisecond = 0.0
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Scene Setup and Content Creation
    override func didMoveToView(view: SKView) {
        if(!self.contentCreated){
            viewSize = self.frame.size
        }
    }
    
    func beginRace() {
        var countdown = 4
        
        let countdownLabel = SKLabelNode()
        countdownLabel.position = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        countdownLabel.fontColor = UIColor.whiteColor()
        countdownLabel.fontSize = 30
        countdownLabel.fontName = "Optima-ExtraBlack"
        countdownLabel.text = "Get Ready..."
        countdownLabel.zPosition = -1
        addChild(countdownLabel)
        
        let countAction = SKAction.runBlock() {
            println("couting down")
            countdown = countdown - 1
            if countdown == 0 {
                countdownLabel.text = "GO!"
                countdownLabel.fontColor = UIColor.greenColor()
            } else {
                countdownLabel.text = String(countdown)
            }
        }
        
        let waitAction = SKAction.waitForDuration(0.8)
        
        let startAction = SKAction.runBlock() {
            countdownLabel.removeFromParent()
            self.physicsWorld.contactDelegate = self
            self.contentCreated = true
            self.motionManager.startAccelerometerUpdates()
            self.setupWorld()
            self.setupHUD()
            self.startGame()
        }
        
        // count down then start the race!
        self.runAction(SKAction.sequence([waitAction, countAction, waitAction, countAction, waitAction,countAction, waitAction, countAction, waitAction, startAction]))
    }

    
    
    func setupHUD() {
        self.addChild(self.boostButtonNode())
        self.addChild(self.brakeButtonNode())
    }
    
    func setupWorld() {
        // Edge Loop
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        self.physicsBody?.categoryBitMask = Contact.Frame
        self.physicsBody?.collisionBitMask = Contact.Frame
        self.physicsBody?.contactTestBitMask = Contact.Frame
        
        // Background
        self.backgroundColor = SKColor.blackColor()
        
        // Ship
        let texture = GameTexturesSharedInstance.textureAtlas.textureNamed("Ship")
        ship = SpaceShip(texture: texture, color: SKColor.whiteColor(), size: texture.size())
        self.addChild(ship)
        
        /************/
        enemyShip = SpaceShip(texture: texture, color: SKColor.blackColor(), size: texture.size())
        self.addChild(enemyShip!)
        /************/
        
        // Message
        //        startMessage.fontSize = 64.0
        //        startMessage.fontColor = SKColor.whiteColor()
        //        startMessage.text = "Tap to Start"
        //        startMessage.position = CGPoint(x: viewSize.width / 2, y: viewSize.height / 2)
        //        startMessage.zPosition = GameLayer.Background
        //        self.addChild(startMessage)
    }
    
    func startGame() {
        //        startClockUpdates()
        var timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: Selector("timerUpdate"), userInfo: nil, repeats: true)
        self.playState = 1
    }
    
    
    func timerUpdate() {
        if playState == 0 {
            
        } else if playState == 1 {
            centiseconds++
            
            if centiseconds % centisecondsPerStar == 0 {
                addStar()
                addAsteroid()
                addEnergy()
            }
        }
    }
    
    /*Update*/
    
    
    override func update(currentTime: CFTimeInterval) {
        if playState == 0 {
            
        } else if playState == 1 {
            // update ships position
            updatePosition(currentTime)
            
            
            // modify action speed to align with shipSpeed T = D / V
            spanTime = 520.0 / Double(ship.forwardSpeed)
            starsPerSecond = starsOnScreen / spanTime
            
            starsPerCentisecond = starsPerSecond/100
            centisecondsPerStar = Int(1.0/starsPerCentisecond)
            
            //        println(ship.forwardSpeed)
            
            
            // starsOnScreen = spawnRate * spanTime
            // spawnRate = starsOnScreen/spanTime
            //spawnRate = starsOnScreen / spanTime
            //speed = CGFloat(spawnRate)
            
            processUserTapsForUpdate(currentTime)
            updateGameObjects()
            processContactsForUpdate(currentTime)
            
            networkingEngine.sendMove(ship.position.x, y: ship.position.y)
        }
    }
    
    // !! speed is a variable already used
    //    var shipSpeed  = 100
    var accel = 0.0
    func updatePosition(currentTime: CFTimeInterval) {
        if (boosting) {
            println("boosting")
            ship.forwardSpeed += 1
        } else {
            if ship.forwardSpeed > 50 {
                ship.forwardSpeed -= 1
            }
        }
        
        if (braking) {
            println("braking")
            if ship.forwardSpeed > 50 {
                ship.forwardSpeed -= 1
            }
        }
        
        if let data = motionManager.accelerometerData {
            
            if (fabs(data.acceleration.x) > 0.01) {
                
                ship.physicsBody!.applyForce(CGVectorMake(0.0, 0.0))
                accel = data.acceleration.x * Double(ship.turnSpeed)
                ship.physicsBody!.applyForce(CGVectorMake(CGFloat(accel), 0))
                
            }
        }
        
    }
    
    /*Game Objects*/
    
    func updateGameObjects(){
        for star in stars {
            (star as Star).updateVelocity(ship.forwardSpeed)
            if star.position.y < viewSize.height * -0.1 {
                stars.removeObject(star)
                star.removeFromParent()
            }
        }
        
        for energy in energies {
            (energy as Energy).updateVelocity(ship.forwardSpeed)
            if energy.position.y < viewSize.height * -0.1 {
                energies.removeObject(energy)
                energy.removeFromParent()
            }
        }
        
        for asteroid in asteroids {
            (asteroid as Asteroid).updateVelocity(ship.forwardSpeed)
            if asteroid.position.y < viewSize.height * -0.1 {
                asteroids.removeObject(asteroid)
                asteroid.removeFromParent()
            }
        }
    }
    
    
    func addStar() {
        // Create sprite
        
        let texture = GameTexturesSharedInstance.textureAtlas.textureNamed("Ship")
        let star = Star(texture: texture, color: SKColor.redColor(), size: texture.size())
        
        // send up mini rock
        stars.addObject(star)
        self.addChild(star)
        
        
    }
    
    func addEnergy() {
        // Create sprite
        
        let texture = GameTexturesSharedInstance.textureAtlas.textureNamed("Ship")
        let energy = Energy(texture: texture, color: SKColor.redColor(), size: texture.size())
        
        
        // send up mini rock
        energies.addObject(energy)
        self.addChild(energy)
        
        
    }
    
    func addAsteroid() {
        // Create sprite
        
        let texture = GameTexturesSharedInstance.textureAtlas.textureNamed("basicRock")
        let asteroid = Asteroid(texture: texture, color: SKColor.redColor(), size: texture.size())
        
        
        // send up mini rock
        asteroids.addObject(asteroid)
        self.addChild(asteroid)
        
        
    }
    
    //Bullets Helpers
    
    func fireBullet(bullet: SKNode, toDestination destination:CGPoint, withDuration duration:CFTimeInterval, andSoundFileName soundName: String) {
        
        println("bullet")
        let bulletAction = SKAction.sequence([SKAction.moveTo(destination, duration: duration), SKAction.waitForDuration(3.0/60.0), SKAction.removeFromParent()])
        //        let bulletAction = SKAction.sequence([SKAction.moveTo(destination, duration: duration), SKAction.removeFromParent()])
        //        let soundAction = SKAction.playSoundFileNamed(soundName, waitForCompletion: true)
        //        bullet.runAction(SKAction.group([bulletAction, soundAction]))
        bullet.runAction(SKAction.group([bulletAction]))
        self.addChild(bullet)
    }
    
    let bulletSize = CGSizeMake(4, 8)
    func fireShipBullets() {
        
        let existingBullet = self.childNodeWithName(nameShipBullet)
        
        if existingBullet == nil {
            
            if let ship = self.childNodeWithName(nameShip) {
                let texture = GameTexturesSharedInstance.textureAtlas.textureNamed("basicRock")
                let bullet = ShipBullet(texture: texture, color: SKColor.redColor(),
                    size: texture.size())
                bullet.position =
                    CGPointMake(ship.position.x, ship.position.y + ship.frame.size.height - bullet.frame.size.height / 2)
                let bulletDestination = CGPointMake(ship.position.x, self.frame.size.height + bullet.frame.size.height / 2)
                self.fireBullet(bullet, toDestination: bulletDestination, withDuration: 1.0, andSoundFileName: "ShipBullet.wav")
                
            }
        }
    }
    
    /*Contact Handler*/
    
    func didBeginContact(contact: SKPhysicsContact!) {
        if contact != nil {
            self.contactQueue.append(contact)
        }
        
    }
    
    func handleContact(contact: SKPhysicsContact){
        // Ensure you haven't already handled this contact and removed its nodes
        if (contact.bodyA.node?.parent == nil || contact.bodyB.node?.parent == nil) {
            return
        }
        
        // Determine which order to collide the bodies in
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        // Order the contact of the bodies
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        collisionManager(firstBody, secondBody)
    }
    
    func processContactsForUpdate(currentTime: CFTimeInterval) {
        for contact in self.contactQueue {
            self.handleContact(contact)
            
            if let index = (self.contactQueue as NSArray).indexOfObject(contact) as Int? {
                self.contactQueue.removeAtIndex(index)
            }
        }
    }
    
    /*TouchScreen*/
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        let touch:UITouch = touches.anyObject() as UITouch
        let touchLocation = touch.locationInNode(self)
        
        var theNode = self.nodeAtPoint(touchLocation)
        
        // check if boost button touched
        if theNode.name == "boostButtonNode" {
            boosting = true
        }
        
        // check if brake button touched
        if theNode.name == "brakeButtonNode" {
            braking = true
        }
        
        // bullet
        if (theNode.name != "boostButtonNode" && theNode.name != "brakeButtonNode"){
            if let touch : AnyObject = touches.anyObject() {
                
                if (touch.tapCount == 1) {
                    
                    // add a tap to the queue
                    self.tapQueue.append(1)
                }
            }
        }
        
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        boosting = false
        braking = false
    }
    
    
    // Boost button
    func boostButtonNode() -> SKSpriteNode {
        let texture = GameTexturesSharedInstance.textureAtlas.textureNamed("basicRock")
        let boostNode = SKSpriteNode(texture: texture,
            color: UIColor.whiteColor(),
            size: texture.size())
        boostNode.position = CGPoint(x: viewSize.width * 0.8, y: viewSize.height * 0.1)
        boostNode.name = "boostButtonNode"
        boostNode.zPosition = GameLayer.Interface
        return boostNode
    }
    
    // Brake button
    func brakeButtonNode() -> SKSpriteNode {
        let texture = GameTexturesSharedInstance.textureAtlas.textureNamed("basicRock")
        let brakeNode = SKSpriteNode(texture: texture,
            color: UIColor.whiteColor(),
            size: texture.size())
        brakeNode.position = CGPoint(x: viewSize.width * 0.2, y: viewSize.height * 0.1)
        brakeNode.name = "brakeButtonNode"
        brakeNode.zPosition = GameLayer.Interface
        return brakeNode
    }
    
    
    func processUserTapsForUpdate(currentTime: CFTimeInterval) {
        for tapCount in self.tapQueue {
            if tapCount == 1 {
                self.fireShipBullets()
            }
            self.tapQueue.removeAtIndex(0)
        }
    }
    
    func matchEnded() {}
    func setCurrentPlayerIndex(index : Int) {
        println("huehue")
        self.beginRace()
    }
    func movePlayerAtIndex(index : Int) {}
    func gameOver(player1Won : Bool) {}
    func movePlayerTo(x: CGFloat, y: CGFloat) {
        enemyShip?.position.x = x
        enemyShip?.position.y = y
    }
    
}



