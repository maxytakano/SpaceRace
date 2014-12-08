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
    var shipTexture:String
    var stars:NSMutableArray
    var energies:NSMutableArray
    var asteroids:NSMutableArray
    var contactQueue = Array<SKPhysicsContact>()
    
    var boosting = false
    var braking = false
    var centiseconds:Int
    // star generation
    var centisecondsPerStar:Int
    var starSpanTime:Double
    var starsOnScreen:Double
    var starsPerSecond:Double
    var starsPerCentisecond:Double
    // aseteroid generation
    var centisecondsPerAsteroid:Int
    var asteroidSpanTime:Double
    var asteroidsOnScreen:Double
    var asteroidsPerSecond:Double
    var asteroidsPerCentisecond:Double
    
    
    var contentCreated = false
    
    ////// time keeping //////
    var minutes = 0
    var seconds = 0
    // should be 30
    var timeLeft = 10
    var scoreLabel = SKLabelNode()
    var countdownLabel = SKLabelNode()
    
    ////// check point stuff ///////
    var nextCheckpointLabel = SKLabelNode()
    var checkpointDistance:Double = 400.0
    let checkpointBase = 400.0
    var checkpointIncrement = 100.0
    
    /////// play state //////
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
    var drainAmount = 2.0
    var chipFlag = false
    
    ////// Texture Stuff //////
    var currentTexture = SKTexture()
    
    /* -------- Initialization --------  */
    
    func setShipTexture(name:String) {
        shipTexture = name
        currentTexture = SKTexture(imageNamed: name)
    }
    
    override init(size: CGSize) {
        stars = []
        energies = []
        asteroids = []
        centiseconds = 0
        centisecondsPerStar = 999999
        starSpanTime = 0.0
        starsOnScreen = 120.0
        starsPerSecond = 0.0
        starsPerCentisecond = 0.0
        
        centisecondsPerAsteroid = 999999
        asteroidSpanTime = 0.0
        asteroidsOnScreen = 4.0
        asteroidsPerSecond = 0.0
        asteroidsPerCentisecond = 0.0
        shipTexture = "Ship1"
        currentTexture = SKTexture(imageNamed: "Ship1")
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Scene Setup and Content Creation
    override func didMoveToView(view: SKView) {
        
        if currentTrack != "Space Battle.wav" {
            playBackgroundMusic("Space Battle.wav")
//            setCurrentTrack("Space Battle.wav")
        }
        
        // initialize high score for first run
        if (NSUserDefaults.standardUserDefaults().objectForKey("HighScore") == nil) {
            var firstScore:[Int] = [0, 0]
            var firstScoreAsNSArray = NSArray(array: firstScore)
            
            NSUserDefaults.standardUserDefaults().setObject(firstScoreAsNSArray, forKey:"HighScore")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
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
        countdownLabel.fontName = "Transformers Movie"
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
        let texture = SKTexture(imageNamed: shipTexture)
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
        
        // Initialize High Score Label
        var currentHighScore = NSUserDefaults.standardUserDefaults().objectForKey("HighScore") as NSArray
        
        var highScoreLabel = SKLabelNode()
        highScoreLabel.position = CGPoint(x: size.width * 0.2, y: size.height * 0.935)
        highScoreLabel.fontColor = UIColor.whiteColor()
        highScoreLabel.fontSize = 15
        highScoreLabel.fontName = "Transformers Movie"
        highScoreLabel.text = "Best: \(currentHighScore[0])m:\(currentHighScore[1])s"
        addChild(highScoreLabel)
        
        // Initialize score timer label
        scoreLabel.position = CGPoint(x: size.width * 0.2, y: size.height * 0.88)
        scoreLabel.fontColor = UIColor.whiteColor()
        scoreLabel.fontSize = 15
        scoreLabel.fontName = "Transformers Movie"

        scoreLabel.text = "Time: \(self.minutes/60)m:\(self.seconds)s"
        addChild(scoreLabel)
        
        // Initialize countdown timer label
        countdownLabel.position = CGPoint(x: size.width * 0.67, y: size.height * 0.88)
        countdownLabel.fontColor = UIColor.whiteColor()
        countdownLabel.fontSize = 20
        countdownLabel.fontName = "Transformers Movie"
        countdownLabel.text = "\(self.timeLeft)"
        addChild(countdownLabel)
        
        // nextCheckpointLabel next checkpoint label
        nextCheckpointLabel.position = CGPoint(x: size.width * 0.67, y: size.height * 0.935)
        nextCheckpointLabel.fontColor = UIColor.whiteColor()
        nextCheckpointLabel.fontSize = 15
        nextCheckpointLabel.fontName = "Transformers Movie"
        nextCheckpointLabel.text = "Next Checkpoint: \(self.checkpointDistance)"
        addChild(nextCheckpointLabel)
        
        // start the clock
        var actionwait = SKAction.waitForDuration(1.0)
        var actionrun = SKAction.runBlock({
            self.minutes++
            self.seconds++
            self.timeLeft--
            
            self.countdownLabel.text = "\(self.timeLeft)"
            
            if self.timeLeft <= 0 {
                self.endGame()
            }
            
            // increment the level after x seconds
//            if self.seconds % 15 == 0 {
//                self.incrementLevel()
//            }
            if self.seconds == 60 {self.seconds = 0}
            self.scoreLabel.text = "Time: \(self.minutes/60)m:\(self.seconds)s"
        })
        scoreLabel.runAction(SKAction.repeatActionForever(SKAction.sequence([actionwait,actionrun])))
        

        // initialize stamina bar boarder
        staminaBarBoarder.color = UIColor.blackColor()
        staminaBarBoarder.size = CGSize(width: size.width * 0.089, height: size.height * 0.752)
        staminaBarBoarder.position = CGPoint(x: size.width * 0.05, y: size.height * 0.125)
        staminaBarBoarder.anchorPoint = CGPointMake(0.0, 0.0)
        
        addChild(staminaBarBoarder)
        staminaBarBoarder.hidden = true
        
        // initialize stamina chip bar
        staminaChip.color = UIColor.yellowColor()
        staminaChip.size = CGSize(width: size.width * 0.07, height: size.height * 0.74)
        staminaChip.position = CGPoint(x: size.width * 0.06, y: size.height * 0.13)
        staminaChip.anchorPoint = CGPointMake(0.0, 0.0)
        
        addChild(staminaChip)
        staminaChip.hidden = true
        
        // initialize stamina bar
        staminaBar.color = UIColor.greenColor()
        staminaBar.size = CGSize(width: size.width * 0.07, height: size.height * 0.74)
        staminaBar.position = CGPoint(x: size.width * 0.06, y: size.height * 0.13)
        staminaBar.anchorPoint = CGPointMake(0.0, 0.0)
        
        addChild(staminaBar)
        staminaBar.hidden = true
        
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
        
        // check if boost button touched
        if theNode.name == "boostButtonNode" {
            var theButton = theNode as SKSpriteNode
            theButton.texture = SKTexture(imageNamed: "Boost4Pressed")
            
            boosting = true
        }
        
        // check if brake button touched
        if theNode.name == "brakeButtonNode" {
            var theButton = theNode as SKSpriteNode
            theButton.texture = SKTexture(imageNamed: "Brake3Pressed")
            
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
            var theButton = self.childNodeWithName("boostButtonNode") as SKSpriteNode
            theButton.texture = SKTexture(imageNamed: "Boost4")
            boosting = false
        } else {
            var theButton = self.childNodeWithName("boostButtonNode") as SKSpriteNode
            theButton.texture = SKTexture(imageNamed: "Boost4Pressed")
            boosting = true
        }
        
        if thingsTouched.containsObject("brakeButtonNode") == false {
            var theButton = self.childNodeWithName("brakeButtonNode") as SKSpriteNode
            theButton.texture = SKTexture(imageNamed: "Brake3")
            braking = false
        } else {
            var theButton = self.childNodeWithName("brakeButtonNode") as SKSpriteNode
            theButton.texture = SKTexture(imageNamed: "Brake3Pressed")
            braking = true
        }
        
        if thingsTouched.containsObject("shield") == false {
            if ship.shipState == SpaceShip.states.SHIELDING {
                updatePlayerState(3)
            }
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
            var theButton = self.childNodeWithName("boostButtonNode") as SKSpriteNode
            theButton.texture = SKTexture(imageNamed: "Boost4")
            boosting = false
        }
        
        if thingsTouched.containsObject("brakeButtonNode") == false {
            var theButton = self.childNodeWithName("brakeButtonNode") as SKSpriteNode
            theButton.texture = SKTexture(imageNamed: "Brake3")
            braking = false
        }
        
        if thingsTouched.containsObject("shield") == false {
            if ship.shipState == SpaceShip.states.SHIELDING {
                updatePlayerState(3)
            }
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
    var starCounter = 0
    var asteroidCounter = 0
//    var secondCounter = 0
    var deciSecondCounter = 0
    
    func timerUpdate() {
        if playState == 0 {
            
        } else if playState == 1 {
            centiseconds++
            starCounter++
            asteroidCounter++
            
            deciSecondCounter++
        
//            secondCounter++
            
            if starCounter > centisecondsPerStar {
                starCounter = 0
                addStar()
            }
            
            if asteroidCounter > centisecondsPerAsteroid {
                asteroidCounter = 0
                addAsteroid()
            }

//            
            if deciSecondCounter > 10 {
                deciSecondCounter = 0
                for asteroid in asteroids {
                    (asteroid as Asteroid).rotateAsteroid()
                }
            }

            if centiseconds % 100 == 0 {
                if shipEnergy < 97 {
                    shipEnergy += 3
                }
                
                var ratio = CGFloat(shipEnergy / maxEnergy)
                if (self.shipEnergy > 100) {
                    ratio = CGFloat(100.0)
                }
                staminaBar.size.height = maxStaminaBarHeight * CGFloat(ratio)
                
                if (!chipFlag) {
                    staminaChip.size.height = maxStaminaBarHeight * CGFloat(ratio)
                }
            }
//            if secondCounter > 100 {
//                secondCounter = 0
//                if shipEnergy < 97 {
//                    shipEnergy += 3
//                }
//                
//                var ratio = CGFloat(shipEnergy / maxEnergy)
//                if (self.shipEnergy > 100) {
//                    ratio = CGFloat(100.0)
//                }
//                staminaBar.size.height = maxStaminaBarHeight * CGFloat(ratio)
//                
//                if (!chipFlag) {
//                    staminaChip.size.height = maxStaminaBarHeight * CGFloat(ratio)
//                }
//            }
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        if playState == 0 {
            
        } else if playState == 1 {
            // update ships position
            updatePosition(currentTime)
            
            // modify action speed to align with shipSpeed T = D / V
            starSpanTime = 520.0 / (Double(ship.forwardSpeed)/3.0)
            starsPerSecond = starsOnScreen / starSpanTime
            starsPerCentisecond = starsPerSecond/100.0
            centisecondsPerStar = Int(1.0/starsPerCentisecond)
            
            asteroidSpanTime = 520.0 / Double(ship.forwardSpeed)
            asteroidsPerSecond = asteroidsOnScreen / asteroidSpanTime
            asteroidsPerCentisecond = asteroidsPerSecond/100.0
            centisecondsPerAsteroid = Int(1.0/asteroidsPerCentisecond)
            
            //        println(ship.forwardSpeed)
            
            // starsOnScreen = spawnRate * spanTime
            // spawnRate = starsOnScreen/starSpanTime
            //spawnRate = starsOnScreen / spanTime
            //speed = CGFloat(spawnRate)
            
            processUserTapsForUpdate(currentTime)
            updateGameObjects()
            processContactsForUpdate(currentTime)
            
            ship.distTraveled = ship.distTraveled + (Double(ship.forwardSpeed)/100.0)
            
            if checkpointDistance - ship.distTraveled <= 0 {
                checkpointDistance = checkpointBase + checkpointIncrement
                checkpointIncrement += 1000
                timeLeft += 10
            }
            
            nextCheckpointLabel.text = "Next Checkpoint: \(Int(self.checkpointDistance - ship.distTraveled))"
            
        }
    }
    
    // !! CAREFUL !! speed is a variable already used
    //    var shipSpeed  = 100
    var accel = 0.0
    var averageAmount = 6.0
    var averageTilt = 0.0
    var averageCounter = 0.0
    var average = 0.0
    
//    var currentTexture = SKTexture(imageNamed: String(textureName + "TiltLeft1"))
    
    ////
//    var animationList = [-0.2, -0.1, 0.0, 0.1, 0.2]
    var animationList = [-0.25, -0.14, -0.07, 0.0, 0.07, 0.14, 0.25]
    func getClosest(xData: Double) -> Double {
        var closest = 0.0
        var distance = 999.0
        for number in animationList {
            if fabs(number - xData) < distance {
                distance = fabs(number - xData)
                closest = number
            }
        }
        if distance < 0.03 {
            return closest
        } else {
            return -42.0
        }
    
    }
    
    ////
    func updatePosition(currentTime: CFTimeInterval) {
        if (boosting) {
            if ship.forwardSpeed < 1000 {
                ship.forwardSpeed += 1
            }
        } else {
            if ship.forwardSpeed > 50 {
                ship.forwardSpeed -= 1
            }
        }
        
        if (braking) {
            if ship.forwardSpeed > 50 {
                ship.forwardSpeed -= 5
            }
        }
        
        if let data = motionManager.accelerometerData {
            if (fabs(data.acceleration.x) > 0.01) {
                ship.physicsBody!.applyForce(CGVectorMake(0.0, 0.0))
                accel = data.acceleration.x * Double(ship.turnSpeed)
                ship.physicsBody!.applyForce(CGVectorMake(CGFloat(accel), 0))
            }
        
            
            // !! Dont delete old method of animation
//            if averageCounter < averageAmount {
//                averageTilt += data.acceleration.x
//                averageCounter += 1
//            } else {
//                averageCounter = 0.0
//                average = averageTilt / averageAmount
//                averageTilt = 0.0
//                
//                println(average)
//                if(average < -0.085) {
//                    ship.texture = SKTexture(imageNamed: "Ship1TiltLeft2")
//                    currentTexture = SKTexture(imageNamed: "Ship1TiltLeft2")
//                    
//                } else if (average < -0.04) {
//                    ship.texture = SKTexture(imageNamed: "Ship1TiltLeft1")
//                    currentTexture = SKTexture(imageNamed: "Ship1TiltLeft1")
//                } else if(average > 0.085) {
//                    ship.texture = SKTexture(imageNamed: "Ship1TiltRight2")
//                    currentTexture = SKTexture(imageNamed: "Ship1TiltRight2")
//                } else if(average > 0.04) {
//                    ship.texture = SKTexture(imageNamed: "Ship1TiltRight1")
//                    currentTexture = SKTexture(imageNamed: "Ship1TiltRight1")
//                } else {
//                    ship.texture = SKTexture(imageNamed: "Ship1")
//                    currentTexture = SKTexture(imageNamed: "Ship1")
//                }
//
//            }
            
            
            var closest = getClosest(data.acceleration.x)
            if closest != -42.0 {
//                if closest == animationList[0] {
//                    ship.texture = SKTexture(imageNamed: shipTexture + "TiltLeft2")
//                    currentTexture = SKTexture(imageNamed: shipTexture + "TiltLeft2")
//                } else if closest == animationList[1] {
//                    ship.texture = SKTexture(imageNamed: shipTexture + "TiltLeft1")
//                    currentTexture = SKTexture(imageNamed: shipTexture + "TiltLeft1")
//                } else if closest == animationList[2] {
//                    ship.texture = SKTexture(imageNamed: shipTexture)
//                    currentTexture = SKTexture(imageNamed: shipTexture)
//                } else if closest == animationList[3] {
//                    ship.texture = SKTexture(imageNamed: shipTexture + "TiltRight1")
//                    currentTexture = SKTexture(imageNamed: shipTexture + "TiltRight1")
//                } else if closest == animationList[4] {
//                    ship.texture = SKTexture(imageNamed: shipTexture + "TiltRight2")
//                    currentTexture = SKTexture(imageNamed: shipTexture + "TiltRight2")
//                }
                
                if closest == animationList[0] {
                    ship.texture = SKTexture(imageNamed: shipTexture + "TiltLeft3")
                    currentTexture = SKTexture(imageNamed: shipTexture + "TiltLeft3")
                } else if closest == animationList[1] {
                    ship.texture = SKTexture(imageNamed: shipTexture + "TiltLeft2")
                    currentTexture = SKTexture(imageNamed: shipTexture + "TiltLeft2")
                } else if closest == animationList[2] {
                    ship.texture = SKTexture(imageNamed: shipTexture + "TiltLeft1")
                    currentTexture = SKTexture(imageNamed: shipTexture + "TiltLeft1")
                } else if closest == animationList[3] {
                    ship.texture = SKTexture(imageNamed: shipTexture)
                    currentTexture = SKTexture(imageNamed: shipTexture)
                } else if closest == animationList[4] {
                    ship.texture = SKTexture(imageNamed: shipTexture + "TiltRight1")
                    currentTexture = SKTexture(imageNamed: shipTexture + "TiltRight1")
                } else if closest == animationList[5] {
                    ship.texture = SKTexture(imageNamed: shipTexture + "TiltRight2")
                    currentTexture = SKTexture(imageNamed: shipTexture + "TiltRight2")
                } else if closest == animationList[6] {
                    ship.texture = SKTexture(imageNamed: shipTexture + "TiltRight3")
                    currentTexture = SKTexture(imageNamed: shipTexture + "TiltRight3")
                }

            }
        }
        
        
    }
    
    
    func updateGameObjects(){
        for star in stars {
            var halfSpeed = Double(ship.forwardSpeed) / 3.0
            (star as Star).updateVelocity(halfSpeed)
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
//                runAction(drainAction, withKey: "drainAction1")
            }

        }
        else if (currentState == 3) {
            // sound stuff
            //            fadingOut = true
            //            fadingIn = false
            //            doVolumeFadeOut()
            
        
            
            staminaBar.color = UIColor.greenColor()
            
            ship.unShield()
            ship.texture = currentTexture

            //player.texture = SKTexture(imageNamed: "bouldini")
            
            // return to normal color
            //player.colorBlendFactor = 0.0
            
            //removeActionForKey("drainAction1")
//            removeActionForKey("defenseSound")
            
            
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
        let texture = SKTexture(imageNamed: "staru")
        ("staru")
        let star = Star(texture: texture, color: SKColor.redColor(), size: texture.size())
        
        // send up mini rock
        stars.addObject(star)
        self.addChild(star)
    }
    
    func addEnergy() {
        // Create sprite
        let texture = SKTexture(imageNamed: "Ship")
        let energy = Energy(texture: texture, color: SKColor.redColor(), size: texture.size())
        
        
        // send up mini rock
        energies.addObject(energy)
        self.addChild(energy)
    }
    
    func addAsteroid() {
        // Create sprite
        let texture = SKTexture(imageNamed: "Asteroid1")
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
                let texture = SKTexture(imageNamed: "Asteroid1")
                let bullet = ShipBullet(texture: texture, color: SKColor.redColor(),
                    size: texture.size())
                bullet.position =
                    CGPointMake(ship.position.x, ship.position.y + ship.frame.size.height - bullet.frame.size.height / 2)
                let bulletDestination = CGPointMake(ship.position.x, self.frame.size.height + bullet.frame.size.height / 2)
                self.fireBullet(bullet, toDestination: bulletDestination, withDuration: 1.0, andSoundFileName: "ShipBullet.wav")
            }
        }
    }
    
    /* ------ Contact Handler ------ */

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
    
    /*  ------ contact management ------ */
    
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
        }
    }
    
    func asteroidCollision(firstBody: SKPhysicsBody, secondBody: SKPhysicsBody){
        if ((firstBody.categoryBitMask & Contact.Ship != 0)
            && (secondBody.categoryBitMask & Contact.Asteroid != 0)) {
                //done to make sure removed from array too
                
                rockDidCollideWithPlayer(firstBody.node as SKSpriteNode, rock: secondBody.node as SKSpriteNode)
                
//                secondBody.node!.position.y = viewSize.height * -0.1
        }
    }
    
    
    func shipBulletAsteroidCollision(firstBody: SKPhysicsBody, secondBody: SKPhysicsBody){
        if ((firstBody.categoryBitMask & Contact.Asteroid != 0)
            && (secondBody.categoryBitMask & Contact.ShipBullet != 0)) {
                //done to make sure removed from array too
                firstBody.node!.position.y = viewSize.height * -0.1
                secondBody.node!.removeFromParent() //remove this and have continues bullet
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
            if ship.forwardSpeed > 100 {
                ship.forwardSpeed -= 100

            }
            let rockSplat = newRockSplat()
            rockSplat.position = rock.position
            rockSplat.position.y -= rock.size.height * 0.1
            addChild(rockSplat)
            
            // Show that the player was damaged by blinking
            //            let blinkAction = SKAction.sequence([SKAction.fadeOutWithDuration(0.1), SKAction.fadeInWithDuration(0.1)])
            //            let blinkForTime = SKAction.repeatAction(blinkAction, count: 2)
            //            player.runAction(SKAction.sequence([blinkForTime]))
            //
            //            let squishAction = SKAction.sequence([SKAction.scaleYTo(0.0, duration: 0.1), SKAction.scaleYTo(1.0, duration: 0.3)])
            //            player.runAction(SKAction.sequence([squishAction]))
            
            // drain energy on hit old
            /*chipFlag = true
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
            
            runAction(chipReduceAction)*/
            
        }
        
        // send rock down low to remove it
        rock.position.y = viewSize.height * -0.1
       
        // Remove rock from view
//        rock.removeFromParent()
    }
    
    func endGame() {
        
        /* high score stuff */
        
        var score:[Int] = [minutes/60, seconds]
        var scoreAsNSArray = NSArray(array: score)
        
        // get the current high score
        var currentHighScore = NSUserDefaults.standardUserDefaults().objectForKey("HighScore") as NSArray
        
        var newScore = score[0] * 60 + score[1]
        var oldScore = Int(currentHighScore[0] as NSNumber) * 60 + Int(currentHighScore[1] as NSNumber)
        
        /* switch to game over scene */
        
        // Check if the ending score is higher than the high score, if it is update it
        if ( newScore > oldScore ) {
            // Save high score
            // Score must be typcasted as an NSArray to work with UserDefaults
            // Gotcha: you can't save in arrays, only Ints, typecasting to as NSArray does not work
            NSUserDefaults.standardUserDefaults().setObject(scoreAsNSArray, forKey:"HighScore")
            NSUserDefaults.standardUserDefaults().synchronize()
            
            // switch to win screen
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            let gameOverScene = GameOverScene(size: self.size,
                won: true,
                seconds:self.seconds,
                minutes:self.minutes,
                shipTexture:shipTexture)
            self.view?.presentScene(gameOverScene, transition: reveal)
        } else {
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            let gameOverScene = GameOverScene(size: self.size,
                won: false,
                seconds:self.seconds,
                minutes:self.minutes,
                shipTexture:shipTexture)
            self.view?.presentScene(gameOverScene, transition: reveal)
            
        }
        
        
        
    }

}



