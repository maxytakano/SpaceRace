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
    
    // play state:
    // 0 equals staging, 1 equals playing, 2 = ???
    var playState = 0
    
    /////// Shield Stuff ///////
    
//    var recognizer = UILongPressGestureRecognizer()
    let staminaBar = SKSpriteNode()
    let staminaBarBoarder = SKSpriteNode()
    let staminaChip = SKSpriteNode()
    
    // Initialize shield energy
    let maxEnergy = 100.0
    var maxStaminaBarHeight = CGFloat()       // init below
    var shipEnergy = Double()
    
    // Energy drain amount
    var drainAmount = 0.85
    var chipFlag = false
    
    /* -------- Initialization --------  */
    
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
            self.userInteractionEnabled = false
            self.beginRace()
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
        
        // temporary count skip
        runAction(startAction)
        
        // count down then start the race!
        //self.runAction(SKAction.sequence([waitAction, countAction, waitAction, countAction, waitAction,countAction, waitAction, countAction, waitAction, startAction]))
    }
    
    /* ------ Game Setup ------ */
    
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
    
    func setupHUD() {
        self.addChild(boostButtonNode())
        self.addChild(brakeButtonNode())
        
        // Initialize up long press gesture
        //recognizer = UILongPressGestureRecognizer(target: self, action: Selector("handleTap:"))
        //recognizer.minimumPressDuration = 0.0
        //recognizer.cancelsTouchesInView = false
        //recognizer.delaysTouchesEnded = false
        
        //self.view?.addGestureRecognizer(recognizer)
        
        // initialize stamina bar boarder
        staminaBarBoarder.color = UIColor.blackColor()
        staminaBarBoarder.size = CGSize(width: size.width * 0.089, height: size.height * 0.752)
        staminaBarBoarder.position = CGPoint(x: size.width * 0.05, y: size.height * 0.125)
        staminaBarBoarder.anchorPoint = CGPointMake(0.0, 0.0)
        
        addChild(staminaBarBoarder)
        
        // initialize stamina chip bar
        staminaChip.color = UIColor.yellowColor()
        staminaChip.size = CGSize(width: size.width * 0.07, height: size.height * 0.74)
        staminaChip.position = CGPoint(x: size.width * 0.06, y: size.height * 0.13)
        staminaChip.anchorPoint = CGPointMake(0.0, 0.0)
        
        addChild(staminaChip)
        
        // initialize stamina bar
        staminaBar.color = UIColor.greenColor()
        staminaBar.size = CGSize(width: size.width * 0.07, height: size.height * 0.74)
        staminaBar.position = CGPoint(x: size.width * 0.06, y: size.height * 0.13)
        staminaBar.anchorPoint = CGPointMake(0.0, 0.0)
        
        addChild(staminaBar)
        
        // init player stamina
        shipEnergy = maxEnergy
        maxStaminaBarHeight = staminaBar.size.height
    }
    
    func startGame() {
        //        startClockUpdates()
        var timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: Selector("timerUpdate"), userInfo: nil, repeats: true)
        self.playState = 1
        self.userInteractionEnabled = true
    }
    
    /* ------Touch Input------ */
    
//    func handleTap(recognizer: UILongPressGestureRecognizer) {
//        
//        ship.color = SKColor.redColor()
//        
//        // Pass in the press state to update the player
//        // 1 = pressed down, 3 = released
//        updatePlayerState(recognizer.state.rawValue)
//    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        let touch:UITouch = touches.anyObject() as UITouch
        let touchLocation = touch.locationInNode(self)
        
        var theNode = self.nodeAtPoint(touchLocation)
        
        //println(event)
        
        // check if boost button touched
        if theNode.name == "boostButtonNode" {
            boosting = true
        }
        
        // check if brake button touched
        if theNode.name == "brakeButtonNode" {
            braking = true
        }
        
        // check the ships state
        if (ship.shipState == SpaceShip.states.NORMAL) {
            if (theNode.name != "boostButtonNode" && theNode.name != "brakeButtonNode"){
               updatePlayerState(1)
            }
        } else if (ship.shipState == SpaceShip.states.PELLETGUN) {
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
        
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        // get a set of everything currently touched
        var thingsTouched = NSMutableSet()
        for theTouch in event.allTouches() as NSSet! {
            let touch = theTouch as UITouch
            let touchLocation = touch.locationInNode(self)
            var theNode = self.nodeAtPoint(touchLocation)
            if theNode.name == nil || theNode.name == "Asteroid" || theNode.name == "Energy" {
                thingsTouched.addObject("shield")
            } else {
                thingsTouched.addObject(theNode.name!)
            }
        }
        
        // Turn off stuff not touched and turn stuff touched on
        if thingsTouched.containsObject("boostButtonNode") == false {
            boosting = false
        } else {
            boosting = true
        }
        
        if thingsTouched.containsObject("brakeButtonNode") == false {
            braking = false
        } else {
            braking = true
        }
        
        if thingsTouched.containsObject("shield") == false {
            updatePlayerState(3)
        } else {
            if ship.shipState != SpaceShip.states.SHIELDING {
                updatePlayerState(1)
            }
            
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
    
        // get a set of everything that is still being touched
        var thingsTouched = NSMutableSet()
        for theTouch in event.allTouches() as NSSet! {
            if theTouch.phase? != UITouchPhase.Ended {
                let touch = theTouch as UITouch
                let touchLocation = touch.locationInNode(self)
                var theNode = self.nodeAtPoint(touchLocation)
                
                if theNode.name == nil {
                    thingsTouched.addObject("shield")
                } else {
                    thingsTouched.addObject(theNode.name!)
                }
            }
        }
        
        // if anything was untouched, turn it off
        if thingsTouched.containsObject("boostButtonNode") == false {
            boosting = false
        }
        
        if thingsTouched.containsObject("brakeButtonNode") == false {
            braking = false
        }
        
        if thingsTouched.containsObject("shield") == false {
            updatePlayerState(3)
        }
        
    }
    
    func processUserTapsForUpdate(currentTime: CFTimeInterval) {
        for tapCount in self.tapQueue {
            if tapCount == 1 {
                self.fireShipBullets()
            }
            self.tapQueue.removeAtIndex(0)
        }
    }
    
    /* -------- Updates -------- */
    
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
            
        }
    }
    
    // !! CAREFUL !! speed is a variable already used
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
    
    /* ------Energy Bar------ */
    
    func updatePlayerState(currentState: Int) {
        if (currentState == 1) {
            
            if shipEnergy > 0 {
                // sound stuff
                //            fadingIn = true
                //            fadingOut = false
                //            doVolumeFadeIn()
                
                // make stam bar yellow while draining
                staminaBar.color = UIColor.yellowColor()
                
                ship.shield()
                //            playerIsHard = true
                
                ship.texture = SKTexture(imageNamed: "bright_block3")
                //player.texture = SKTexture(imageNamed: "bright_block3")
                
                var drainAction = SKAction.repeatActionForever(
                    SKAction.sequence([
                        SKAction.runBlock(drainStamina),
                        SKAction.waitForDuration(0.1)
                        ])
                )
                runAction(drainAction, withKey: "drainAction1")
            }

        }
        else if (currentState == 3) {
            // sound stuff
            //            fadingOut = true
            //            fadingIn = false
            //            doVolumeFadeOut()
            
            staminaBar.color = UIColor.greenColor()
            
            ship.unShield()
            ship.texture = SKTexture(imageNamed: "Ship")

            //player.texture = SKTexture(imageNamed: "bouldini")
            
            // return to normal color
            //player.colorBlendFactor = 0.0
            removeActionForKey("drainAction1")
            removeActionForKey("defenseSound")
            
        }
    }
    
    func drainStamina() {
        
        shipEnergy -= drainAmount
        var ratio = CGFloat(shipEnergy / maxEnergy)
        if (self.shipEnergy < 0) {
            ratio = CGFloat(0)
        }
        staminaBar.size.height = maxStaminaBarHeight * CGFloat(ratio)
        
        if (!chipFlag) {
            staminaChip.size.height = maxStaminaBarHeight * CGFloat(ratio)
        }
        
        if shipEnergy < 0 {
            updatePlayerState(3)
        }
        
        // TODO: do something when theres no more stamina left
        /*if (shipEnergy < 0) {
        endGame()
        }*/
    }
    
    /*  -------- Game Objects  -------- */
    
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
        collisionManager(firstBody, secondBody: secondBody)
    }
    
    func processContactsForUpdate(currentTime: CFTimeInterval) {
        for contact in self.contactQueue {
            self.handleContact(contact)
            
            if let index = (self.contactQueue as NSArray).indexOfObject(contact) as Int? {
                self.contactQueue.removeAtIndex(index)
            }
        }
    }
    
    /* contact management */
    
    func collisionManager(firstBody: SKPhysicsBody, secondBody: SKPhysicsBody){
        shipBulletAsteroidCollision(firstBody, secondBody: secondBody)
        energyCollision(firstBody, secondBody: secondBody)
        asteroidCollision(firstBody, secondBody: secondBody)
    }
    
    func energyCollision(firstBody: SKPhysicsBody, secondBody: SKPhysicsBody){
        if ((firstBody.categoryBitMask & Contact.Ship != 0)
            && (secondBody.categoryBitMask & Contact.Energy != 0)) {
             
                //done to make sure removed from array too
//                energies.removeObject(secondBody.node!)
//                secondBody.node?.removeFromParent()
                
                secondBody.node!.position.y = viewSize.height * -0.1
//                println("energy")
        }
    }
    
    func asteroidCollision(firstBody: SKPhysicsBody, secondBody: SKPhysicsBody){
        if ((firstBody.categoryBitMask & Contact.Ship != 0)
            && (secondBody.categoryBitMask & Contact.Asteroid != 0)) {
                //done to make sure removed from array too
                
                rockDidCollideWithPlayer(firstBody.node as SKSpriteNode, rock: secondBody.node as SKSpriteNode)
                
//                secondBody.node!.position.y = viewSize.height * -0.1
//                println("asteroid")
        }
    }
    
    
    func shipBulletAsteroidCollision(firstBody: SKPhysicsBody, secondBody: SKPhysicsBody){
        if ((firstBody.categoryBitMask & Contact.Asteroid != 0)
            && (secondBody.categoryBitMask & Contact.ShipBullet != 0)) {
                //done to make sure removed from array too
                firstBody.node!.position.y = viewSize.height * -0.1
                secondBody.node!.removeFromParent() //remove this and have continues bullet
//                println("hit")
        }
        
    }
    
    func rockDidCollideWithPlayer(player:SKSpriteNode, rock:SKSpriteNode) {
        if (ship.shipState == SpaceShip.states.SHIELDING) {
            // play rock hit sound
            runAction(SKAction.playSoundFileNamed("rockcrumb.wav", waitForCompletion: false))
            
            // blow the rock up with particle systems
            let rockSplat = newRockSplat()
            rockSplat.position = rock.position
            rockSplat.position.y -= rock.size.height * 0.1
            addChild(rockSplat)
        } else {
            // play smush sound
            runAction(SKAction.playSoundFileNamed("smush.wav", waitForCompletion: false))
            
            // Show that the player was damaged by blinking
            //            let blinkAction = SKAction.sequence([SKAction.fadeOutWithDuration(0.1), SKAction.fadeInWithDuration(0.1)])
            //            let blinkForTime = SKAction.repeatAction(blinkAction, count: 2)
            //            player.runAction(SKAction.sequence([blinkForTime]))
            //
            //            let squishAction = SKAction.sequence([SKAction.scaleYTo(0.0, duration: 0.1), SKAction.scaleYTo(1.0, duration: 0.3)])
            //            player.runAction(SKAction.sequence([squishAction]))
            
            
            chipFlag = true
            staminaChip.color = UIColor.redColor()
            var chipReduce = SKAction.runBlock() {
                //self.staminaChip.color = UIColor.redColor()
                //self.shipEnergy -= 34
                var chipRatio = CGFloat(self.shipEnergy / self.maxEnergy)
                if (self.shipEnergy < 0) {
                    chipRatio = CGFloat(0)
                }
                
                self.staminaChip.size.height = (self.maxStaminaBarHeight * chipRatio)
                self.chipFlag = false
            }
            
            var chipReduceAction = SKAction.sequence([ SKAction.waitForDuration(0.4), chipReduce])
            
            // lower player health
            if shipEnergy < 26 && shipEnergy > 0 {
                shipEnergy = 0
            } else if shipEnergy > 0 {
                shipEnergy -= 26
            }
            
            var ratio = shipEnergy / maxEnergy
            staminaBar.size.height = maxStaminaBarHeight * CGFloat(ratio)
            if (self.shipEnergy < 0) {
                var ratio = CGFloat(0)
            }
            self.staminaBar.size.height = self.maxStaminaBarHeight * CGFloat(ratio)
            
            runAction(chipReduceAction)
            
        }
        
        // send rock down low to remove it
        rock.position.y = viewSize.height * -0.1
       
        // Remove rock from view
//        rock.removeFromParent()
    }
    

}



