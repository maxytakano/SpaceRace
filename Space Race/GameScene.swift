//
//  GameScene.swift
//  Space Race
//
//  Created by Max Takano on 11/6/14.
//  Copyright (c) 2014 Max Takano. All rights reserved.
//

import SpriteKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let motionManager: CMMotionManager = CMMotionManager()
    
    let nameShipBullet = "ShipBullet"
    let nameShip = "NoobShip"
    
    var tapQueue: Array<Int> = []
    
    var ship:SpaceShip!
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
            physicsWorld.contactDelegate = self
            self.contentCreated = true
            motionManager.startAccelerometerUpdates()
            self.setupWorld()
            self.setupHUD()
            self.startGame()
        }
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
    }
    
    
    func timerUpdate() {
        centiseconds++
        
        if centiseconds % centisecondsPerStar == 0 {
            addStar()
            addAsteroid()
            addEnergy()
        }
    }
    
    /*Update*/
    
    
    override func update(currentTime: CFTimeInterval) {
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
    
}




//import AVFoundation
//import CoreMotion
//
//struct PhysicsCategory {
//    static let None      : UInt32 = 0
//    static let All       : UInt32 = UInt32.max
//    static let Player    : UInt32 = 0b1       // 1
//    static let Projectile: UInt32 = 0b10      // 2
//}
//
//import SpriteKit
//
//class GameScene: SKScene, SKPhysicsContactDelegate {
//
//    // 1
//    let player = SKSpriteNode(texture: SKTexture(imageNamed: "bouldini"))
//    let staminaBar = SKSpriteNode()
//    let staminaBarBoarder = SKSpriteNode()
//    let staminaChip = SKSpriteNode()
//    
//    // Initialize playerStamina and state
//    let maxPlayerStamina = 10000000.0
//    var maxStaminaBarHeight = CGFloat()       // init below
//    var playerStamina = Double()
//    var playerIsHard = false
//    
//    // Initialize time holders
//    var minutes = 0
//    var seconds = 0
//    
//    // instantiate counters
//    var rocksSmashed = 0
//    var currentLevel = 1
////    var recognizer = UILongPressGestureRecognizer()
//    
//    // instantiate labels
//    var scoreLabel = SKLabelNode()
//    var rockLabel = SKLabelNode()
//    var levelLabel = SKLabelNode()
//    var levelUpLabel = SKLabelNode()
//    
//    // instastiate rock speed and spawning
//    var minSpawnTime = 1.8
//    var spawnRange = 0.4
//    
//    var minSpeed = 2.2
//    var maxSpeed = 2.6
//    
//    // Health drain amount
//    var drainAmount = 0.85
//    var healthGained = 30
//    
//    // For music:
//    var backgroundMusicPlayer: AVAudioPlayer!
//    
//    var chipFlag = false
//    var fadingIn = true
//    var fadingOut = true
//    
//    let kPlayerSpeed = 1550
//    var starSpeed = 100
//    
//    let motionManager: CMMotionManager = CMMotionManager()
//    
//    func playBackgroundMusic(filename: String) {
//        let url = NSBundle.mainBundle().URLForResource(
//            filename, withExtension: nil)
//        if (url == nil) {
//            println("Could not find file: \(filename)")
//            return
//        }
//        
//        var error: NSError? = nil
//        backgroundMusicPlayer =
//            AVAudioPlayer(contentsOfURL: url, error: &error)
//        if backgroundMusicPlayer == nil {
//            println("Could not create audio player: \(error!)")
//            return
//        }
//        
//        backgroundMusicPlayer.numberOfLoops = -1
//        backgroundMusicPlayer.prepareToPlay()
//        backgroundMusicPlayer.volume = 0
//        backgroundMusicPlayer.play()
//    }
//    
//    
//    func doVolumeFadeIn () {
//        
//        if (!fadingIn) {
//            return
//        }
//        
//        if (backgroundMusicPlayer.volume < 1.0) {
//            backgroundMusicPlayer.volume += 0.2
//            var fadeAction = SKAction.runBlock(doVolumeFadeIn)
//            runAction(SKAction.sequence([SKAction.waitForDuration(0.001), fadeAction]))
//        }
//        
//    }
//    
//    func doVolumeFadeOut () {
//        
//        if (!fadingOut) {
//            return
//        }
//        
//        if(backgroundMusicPlayer.volume > 0) {
//            backgroundMusicPlayer.volume -= 0.1
//            var fadeAction = SKAction.runBlock(doVolumeFadeOut)
//            runAction(SKAction.sequence([SKAction.waitForDuration(0.001), fadeAction]))
//        }
//        
//    }
//    
//    override func didMoveToView(view: SKView) {
//      
//        // not working (loop part)
//        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
//
//        
//        // Initialize up long press gesture
////        recognizer = UILongPressGestureRecognizer(target: self, action: Selector("handleTap:"))
////        recognizer.minimumPressDuration = 0.0;
////        recognizer.cancelsTouchesInView = false;
////        recognizer.delaysTouchesEnded = false
////        
////        view.addGestureRecognizer(recognizer)
//
//        var backgroundImage = SKSpriteNode()
//        
//        // check if i6, 4 inch or 3.5 ( 6+ is 736, 414
//        if (size.height == 568) {
//            backgroundImage = SKSpriteNode(imageNamed: "gameOver1")
//            
//        } else if (size.height == 667) {
//            backgroundImage = SKSpriteNode(imageNamed: "gameOver1")
//            backgroundImage.xScale = 1.171
//            backgroundImage.yScale = 1.174
//        } else if (size.height == 736) {
//            backgroundImage = SKSpriteNode(imageNamed: "gameOver1")
//            backgroundImage.xScale = 1.296
//            backgroundImage.yScale = 1.294
//        } else {
//            backgroundImage = SKSpriteNode(imageNamed: "gameOver1")
//            
//        }
// 
//        
//        backgroundImage.position = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
//        backgroundImage.zPosition = -10
//        addChild(backgroundImage)
//        
//        
//        player.anchorPoint = CGPointMake(0, 0)
//        
//        // Set up player physics
//        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.height * 0.43, center: CGPointMake(player.size.width * 0.5, player.size.height * 0.5))
//        //player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.height/2) // 1
//        player.physicsBody?.dynamic = true // 2
//        player.physicsBody?.categoryBitMask = PhysicsCategory.Player // 3
//        player.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile // 4
//        player.physicsBody?.collisionBitMask = PhysicsCategory.None // 5
//        player.physicsBody?.affectedByGravity = false
//        player.physicsBody?.mass = 0.02
//        
////        physicsWorld.gravity = CGVectorMake(0, 0)
////        physicsWorld.contactDelegate = self
//        
//        // Debug to show physics boundries
//        view.showsPhysics = true
//        
//        
//        // Initialize Player //
//        
//        // Set Player position
//        player.position = CGPoint(x: size.width * 0.22, y: size.height * 0.19)
//        
//        // Initialize harden color
//        player.color = SKColor.redColor()
//        player.zPosition = -4
//        
//        addChild(player)
//        
//        
//        
//        
//        // initialize stamina bar boarder
//        staminaBarBoarder.color = UIColor.blackColor()
//        staminaBarBoarder.size = CGSize(width: size.width * 0.089, height: size.height * 0.752)
//        staminaBarBoarder.position = CGPoint(x: size.width * 0.05, y: size.height * 0.125)
//        staminaBarBoarder.anchorPoint = CGPointMake(0.0, 0.0)
//        
//        addChild(staminaBarBoarder)
//        
//        staminaBarBoarder.zPosition = -2
//        
//        // initialize stamina chip bar
//        staminaChip.color = UIColor.yellowColor()
//        staminaChip.size = CGSize(width: size.width * 0.07, height: size.height * 0.74)
//        staminaChip.position = CGPoint(x: size.width * 0.06, y: size.height * 0.13)
//        staminaChip.anchorPoint = CGPointMake(0.0, 0.0)
//        
//        addChild(staminaChip)
//        
//        staminaChip.zPosition = -1
//        
//        // initialize stamina bar
//        staminaBar.color = UIColor.greenColor()
//        staminaBar.size = CGSize(width: size.width * 0.07, height: size.height * 0.74)
//        staminaBar.position = CGPoint(x: size.width * 0.06, y: size.height * 0.13)
//        staminaBar.anchorPoint = CGPointMake(0.0, 0.0)
//        
//        addChild(staminaBar)
//        
//        staminaBar.zPosition = 0
//        
//        
//        // init player stamina
//        playerStamina = maxPlayerStamina
//        maxStaminaBarHeight = staminaBar.size.height
//        
////        runAction(SKAction.repeatActionForever(
////            SKAction.sequence([
////                SKAction.runBlock(addRock),
////                SKAction.waitForDuration(1.8, withRange: 0.0)
////                ])
////            ), withKey: "rockRain")
//        
//        runAction(SKAction.repeatActionForever(
//            SKAction.sequence([
//                SKAction.runBlock(addStar),
//                SKAction.waitForDuration(0.4, withRange: 0.0)
//                ])
//            ), withKey: "starGeneration")
//        
//        // challenge mode
//        /*minSpeed = 0.5
//        minSpawnTime = 0.4
//        spawnRange = 0.2
//        maxSpeed = 1.0
//        
//        
//        runAction(SKAction.repeatActionForever(
//        SKAction.sequence([
//        SKAction.runBlock(addRock),
//        SKAction.waitForDuration(minSpawnTime, withRange: spawnRange)
//        ])
//        ), withKey: "rockRain")*/
//        
//        
//        playBackgroundMusic("energyfields2.wav")
//    }
////    
////
////    
////    func handleTap(recognizer: UILongPressGestureRecognizer) {
////        
////        player.color = SKColor.redColor()
////        
////        // Pass in the press state to update the player
////        // 1 = pressed down, 3 = released
////        updatePlayerState(recognizer.state.rawValue)
////        
////    }
//    
//    
//    
//    func updatePlayerState(currentState: Int) {
//        if (currentState == 1) {
//            
//            
//            fadingIn = true
//            fadingOut = false
//            doVolumeFadeIn()
//            
//            // make stam bar yellow while draining
//            staminaBar.color = UIColor.yellowColor()
//            
//            playerIsHard = true
//            
//            player.texture = SKTexture(imageNamed: "bright_block3")
//            
//            // allow the red to show
//            //player.colorBlendFactor = 1.0
//            
//            var drainAction = SKAction.repeatActionForever(
//                SKAction.sequence([
//                    SKAction.runBlock(drainStamina),
//                    SKAction.waitForDuration(0.1)
//                    ])
//            )
//            runAction(drainAction, withKey: "drainAction1")
//        }
//        else if (currentState == 3) {
//            
//            fadingOut = true
//            fadingIn = false
//            doVolumeFadeOut()
//            
//            
//            /*var stopMusicAction = SKAction.runBlock() {
//            self.backgroundMusicPlayer.stop()
//            }
//            runAction(SKAction.sequence([SKAction.waitForDuration(0.9), stopMusicAction]))*/
//            
//            //backgroundMusicPlayer.stop()
//            //doVolumeFadeOut()
//            
//            staminaBar.color = UIColor.greenColor()
//            
//            playerIsHard = false
//            
//            player.texture = SKTexture(imageNamed: "bouldini")
//            
//            // return to normal color
//            player.colorBlendFactor = 0.0
//            removeActionForKey("drainAction1")
//            removeActionForKey("defenseSound")
//            
//        }
//    }
//    
//    func drainStamina() {
//        
//        playerStamina -= drainAmount
//        var ratio = CGFloat(playerStamina / maxPlayerStamina)
//        if (self.playerStamina < 0) {
//            ratio = CGFloat(0)
//        }
//        staminaBar.size.height = maxStaminaBarHeight * CGFloat(ratio)
//        
//        if (!chipFlag) {
//            staminaChip.size.height = maxStaminaBarHeight * CGFloat(ratio)
//        }
//        
//        
//        
//        // Todo: put below code in a func and call here and when hit by rock
//        if (playerStamina < 0) {
//            endGame()
//        }
//    }
//    
////    // attempting depth
////    func addRock() {
////        // play going Up sound
////        runAction(SKAction.playSoundFileNamed("goingUp2.wav", waitForCompletion: false))
////        
////        // Create sprite
////        let rock = SKSpriteNode(imageNamed: "basicRock")
////        rock.name = "rock"
////        
////        // Set up physics
////        rock.physicsBody = SKPhysicsBody(circleOfRadius: rock.size.height/2.3) // 1
////        rock.physicsBody?.dynamic = true // 2
////        rock.physicsBody?.categoryBitMask = PhysicsCategory.Projectile // 3
////        rock.physicsBody?.contactTestBitMask = PhysicsCategory.Player // 4
////        rock.physicsBody?.collisionBitMask = PhysicsCategory.None // 5
////        rock.physicsBody?.usesPreciseCollisionDetection = true
////        
////        
////        
////        // send up mini rock
////        rock.position = CGPoint(x: size.width * 0.8, y:size.height * 0.8)
////        rock.zRotation = getRandom(min: CGFloat(0.0), CGFloat(6.28))
////        
////        addChild(rock)
////        
////        var actualDuration = getRandom(min: CGFloat(minSpeed), CGFloat(maxSpeed))
////        
////        
////        rock.xScale = 0.4
////        rock.yScale = 0.4
////        
////        let actionMoveUp = SKAction.moveTo(CGPoint(x: size.width * 0.79, y: size.height + rock.size.height/2), duration: NSTimeInterval(0.7))
////        
////        let actionFly = SKAction.waitForDuration(NSTimeInterval(1.0))
////        
////        let repositonAction = SKAction.runBlock() {
////            rock.position = CGPoint(x: self.size.width * 0.43,
////                y:self.size.height + rock.self.size.height/2)
////            rock.xScale = 1.0
////            rock.yScale = 1.0
////        }
////        
////        var rockX = player.position.x + (player.size.width * 0.48)
////        var rockY = player.position.y + (player.size.height * 0.47)
////        
////        let actionMoveDown = SKAction.moveTo(CGPoint(x: rockX, y: rockY), duration: NSTimeInterval(actualDuration))
////        
////        let actionMoveDone = SKAction.removeFromParent()
////        
////        rock.runAction(SKAction.sequence([actionMoveUp, actionFly, repositonAction, actionMoveDown, actionMoveDone]))
////        
////    }
//    
//
//    // attempting depth
//
//    
//    func didBeginContact(contact: SKPhysicsContact) {
//        // Determine which order to collide the bodies in
//        var firstBody: SKPhysicsBody
//        var secondBody: SKPhysicsBody
//        
//        // Order the contact of the bodies
//        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
//            firstBody = contact.bodyA
//            secondBody = contact.bodyB
//        } else {
//            firstBody = contact.bodyB
//            secondBody = contact.bodyA
//        }
//        
//        // check if the bodies are a player and projecile,
//        // if yes trigger rockDidCollideWithPlayer
//        if ((firstBody.categoryBitMask & PhysicsCategory.Player != 0) &&
//            (secondBody.categoryBitMask & PhysicsCategory.Projectile != 0)) {
//                rockDidCollideWithPlayer(firstBody.node as SKSpriteNode, rock: secondBody.node as SKSpriteNode)
//        }
//    }
//    
//    
//    func rockDidCollideWithPlayer(player:SKSpriteNode, rock:SKSpriteNode) {
//        if (playerIsHard) {
//            
//            // test how hard the game can be
//            /*playerStamina -= 1.1
//            /*if (playerStamina > 100) {
//            playerStamina = 100
//            }*/
//            
//            // update health bar sprite
//            var ratio = playerStamina / maxPlayerStamina
//            staminaBar.size.height = maxStaminaBarHeight * CGFloat(ratio)*/
//            
//            
//            // play rock hit sound
//            runAction(SKAction.playSoundFileNamed("rockcrumb.wav", waitForCompletion: false))
//            
//            // blow the rock up with particle systems
//            let rockSplat = newRockSplat()
//            rockSplat.position = rock.position
//            rockSplat.position.y -= rock.size.height * 0.1
//            addChild(rockSplat)
//            
//            rocksSmashed++
//            rockLabel.text = ": \(rocksSmashed)"
//        } else {
//            
//            // play smush sound
//            runAction(SKAction.playSoundFileNamed("smush.wav", waitForCompletion: false))
//            
//            // Show that the player was damaged by blinking
//            let blinkAction = SKAction.sequence([SKAction.fadeOutWithDuration(0.1), SKAction.fadeInWithDuration(0.1)])
//            let blinkForTime = SKAction.repeatAction(blinkAction, count: 2)
//            player.runAction(SKAction.sequence([blinkForTime]))
//            
//            let squishAction = SKAction.sequence([SKAction.scaleYTo(0.0, duration: 0.1), SKAction.scaleYTo(1.0, duration: 0.3)])
//            player.runAction(SKAction.sequence([squishAction]))
//            
//            
//            
//            chipFlag = true
//            staminaChip.color = UIColor.redColor()
//            var chipReduce = SKAction.runBlock() {
//                //self.staminaChip.color = UIColor.redColor()
//                //self.playerStamina -= 34
//                var chipRatio = CGFloat(self.playerStamina / self.maxPlayerStamina)
//                if (self.playerStamina < 0) {
//                    chipRatio = CGFloat(0)
//                }
//                
//                self.staminaChip.size.height = (self.maxStaminaBarHeight * chipRatio)
//                self.chipFlag = false
//            }
//            
//            var chipReduceAction = SKAction.sequence([ SKAction.waitForDuration(0.4), chipReduce])
//            
//            // lower player health
//            playerStamina -= 26
//            var ratio = playerStamina / maxPlayerStamina
//            staminaBar.size.height = maxStaminaBarHeight * CGFloat(ratio)
//            if (self.playerStamina < 0) {
//                var ratio = CGFloat(0)
//            }
//            self.staminaBar.size.height = self.maxStaminaBarHeight * CGFloat(ratio)
//            
//            runAction(chipReduceAction)
//            
//            
//            if (playerStamina < 0) {
//                endGame()
//            }
//            
//            // maybe set player to invuln while blinking
//            
//        }
//        
//        // Remove rock from view
//        rock.removeFromParent()
//    
//    }
//    
//    
//    func endGame() {
//        print("you lose\n\n")
//    }
//    
//    override func update(currentTime: CFTimeInterval) {
//        /* Called before each frame is rendered */
//    }
//
//}
//
//
//    
////    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
////        /* Called when a touch begins */
////        
////        for touch: AnyObject in touches {
////            let location = touch.locationInNode(self)
////            
////            let sprite = SKSpriteNode(imageNamed:"Spaceship")
////            
////            sprite.xScale = 0.5
////            sprite.yScale = 0.5
////            sprite.position = location
////            
////            let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
////            
////            sprite.runAction(SKAction.repeatActionForever(action))
////            
////            self.addChild(sprite)
////        }
////    }
//
//
