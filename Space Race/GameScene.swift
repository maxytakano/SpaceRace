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
    var pelletGunPowerups:NSMutableArray
    var laserPowerups:NSMutableArray
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
    
    // Powerup timers
    var pelletGunTimer: Int
    //var invincibleTimer: Int
    var laserTimer: Int
    var laser: LaserBullet!
    var laserPressed = false
    
    /* -------- Initialization --------  */
    
    func setShipTexture(name:String) {
        shipTexture = name
        currentTexture = SKTexture(imageNamed: name)
    }
    
    override init(size: CGSize) {
        stars = []
        energies = []
        asteroids = []
        pelletGunPowerups = []
        laserPowerups = []
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
        
        // powerup timer inits
        pelletGunTimer = 0
        laserTimer = 0
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Scene Setup and Content Creation
    override func didMoveToView(view: SKView) {
        
        if currentTrack != "Space Battle.wav" {
            playBackgroundMusic("Space Battle.wav")
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
        
        // laser image
        let texture2 = SKTexture(imageNamed: "blueLaser")
        
//        laser = LaserBullet(texture: texture2, color: SKColor.whiteColor(), size:
//            CGSizeMake(texture2.size().width, (viewSize.height * 0.8) * 2.0))
        laser = LaserBullet(texture: texture2, color: SKColor.whiteColor(), size:
            CGSizeMake(texture2.size().width, viewSize.height * 0.74 ))
        laser.makeLaserBullet(ship)
        
        pregenStars()
    }
    
    func pregenStars() {
        var placement:CGFloat = 0.0
        for (var i = 0; i < Int(starsOnScreen); i++ ) {
            
            placement += (viewSize.height / CGFloat(starsOnScreen))
            addStar(placement)
        }
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
        
        println(ship.getLaserActive())
        
        if ship.shipState == SpaceShip.states.SHIELDING {
            println("touch began: state is shielding")
        }
        
        // check the ships state
        if (ship.shipState == SpaceShip.states.NORMAL) {
            println("touch began: state is normal")
            if (theNode.name != "boostButtonNode" && theNode.name != "brakeButtonNode") {
                // enter shielding state
                updatePlayerState(1)
            }
        } else if (ship.shipState == SpaceShip.states.PELLETGUN) {
            println("touch began: state is pellet")
            // bullet
            if (theNode.name != "boostButtonNode" && theNode.name != "brakeButtonNode"){
//                if let touch : AnyObject = touches.anyObject() {
//                    if (touch.tapCount == 1) {
//                        
//                         add a tap to the queue
//                        self.tapQueue.append(1)
//    
//                    }
//                }
                // fire bullet
                fireShipBullets()
            }
        } else if (ship.shipState == SpaceShip.states.LASER) {
            println("touch began: state is laser")
            // bullet
            if (theNode.name != "boostButtonNode" && theNode.name != "brakeButtonNode"){
                println("START LASER")
                if(!ship.getLaserActive()){
                    laserTimer = self.minutes
                    println("laser 1111: \(laserTimer)")
                    ship.activeLaser(laser)
                    println(laser)
                    laserPressed = true
                    self.addChild(laser)
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
            if theNode.name == nil || theNode.name == "Asteroid" || theNode.name == "Energy" || theNode.name == "PelletGunPowerup" || theNode.name == "InvinciblePowerup" || theNode.name == "LaserPowerup" {
                thingsTouched.addObject("shield")
//                if ship.shipState == SpaceShip.states.SHIELDING {
//                    thingsTouched.addObject("shield")
//                }
//                else if ship.shipState == SpaceShip.states.PELLETGUN {
//                    thingsTouched.addObject("pelletMode")
//                }
                
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
        
//        if ship.shipState == SpaceShip.states.NORMAL {
        if thingsTouched.containsObject("shield") == false {
            if ship.shipState == SpaceShip.states.SHIELDING {
                updatePlayerState(3)
            }
        } else {
            
            if ship.shipState == SpaceShip.states.PELLETGUN {
                updatePlayerState(2)
            } else if ship.shipState != SpaceShip.states.SHIELDING {
                
            }
            
//            if ship.shipState != SpaceShip.states.SHIELDING {
//                updatePlayerState(1)
//            }
        }
//        }
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
                println("touched endeed: changing to shield state")
                updatePlayerState(3)
            } // !! why do we have to goto pellet
            else if ship.shipState == SpaceShip.states.PELLETGUN {
                updatePlayerState(2)
            }
        }
        
    }
    
//    func processUserTapsForUpdate(currentTime: CFTimeInterval) {
//        for tapCount in self.tapQueue {
//            if tapCount == 1 {
//                self.fireShipBullets()
//            }
//            self.tapQueue.removeAtIndex(0)
//        }
//    }
    
    /* -------- Updates -------- */
    var starCounter = 0
    var asteroidCounter = 0
//    var secondCounter = 0
    var deciSecondCounter = 0
    var beltCounter = 0
    var energyCounter = 0
    var pelletCounter = 0
    var laserCounter = 0
    
    func timerUpdate() {
        if playState == 0 {
            
        } else if playState == 1 {
            centiseconds++
            starCounter++
            asteroidCounter++
            
            deciSecondCounter++
            beltCounter++
            energyCounter++
            pelletCounter++
            laserCounter++
            
            if ship.getLaserActive() {
                //                ship.childNodeWithName("LaserBullet")?.position.x = ship.position.x
                laser.position.x = ship.position.x
            }
        
//            secondCounter++
            
            if starCounter > centisecondsPerStar {
                starCounter = 0
                addStar(viewSize.height * 1.1)
            }
            
            if energyCounter > 300 {
                energyCounter = 0
                addEnergy()
            }
            
            if pelletCounter > 300 {
                pelletCounter = 0
                addPelletPowerup()
            }
            
            if laserCounter > 100 {
                laserCounter = 0
                addLaserPowerup()
            }
            
            if asteroidCounter > centisecondsPerAsteroid {
                asteroidCounter = 0
                addAsteroid()
            }

            if deciSecondCounter > 10 {
                deciSecondCounter = 0
                for asteroid in asteroids {
                    (asteroid as Asteroid).rotateAsteroid()
                }
            }
            
            if beltCounter > 700 {
                beltCounter = 0
                addAsteroidBelt()
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
            
//            if ship.getLaserActive() {
////                ship.childNodeWithName("LaserBullet")?.position.x = ship.position.x
//                laser.position.x = ship.position.x
//            }
            
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
            
//            processUserTapsForUpdate(currentTime)
            updateGameObjects()
            processContactsForUpdate(currentTime)
            updatePowerups()
            
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
            
            var closest = getClosest(data.acceleration.x)
            if closest != -42.0 {
                
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
        
        for powerup in pelletGunPowerups {
            (powerup as PelletGunPowerup).updateVelocity(ship.forwardSpeed)
            if powerup.position.y < viewSize.height * -0.1 {
                pelletGunPowerups.removeObject(powerup)
                powerup.removeFromParent()
            }
        }
        
        for powerup in laserPowerups {
            (powerup as LaserPowerup).updateVelocity(ship.forwardSpeed)
            if powerup.position.y < viewSize.height * -0.1 {
                laserPowerups.removeObject(powerup)
                powerup.removeFromParent()
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
    
    func updatePowerups(){
        if(ship.shipState == SpaceShip.states.LASER){
            println("laser timey 2: \(laserTimer)")
            
            if laserPressed {
                if(self.minutes - laserTimer >= 5){
                    laserPressed = false
                    updatePlayerState(3)
                    println("BACK TO SHIELD")
                }
            }
            
            
        } /*else if(ship.shipState == SpaceShip.states.INVINCIBLE){
            if(self.minutes - invincibleTimer <= 5){
                println("invincible")
                updatePlayerState(4)
                if(self.minutes - invincibleTimer == 0 && ship.forwardSpeed < 1000){
                    ship.forwardSpeed += 250
                }
                
            }else{
                updatePlayerState(3)
            }
            
        }*/
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
                
//                ship.texture = SKTexture(imageNamed: "bright_block3")
                //player.texture = SKTexture(imageNamed: "bright_block3")
                
                var drainAction = SKAction.repeatActionForever(
                    SKAction.sequence([
                        SKAction.runBlock(drainStamina),
                        SKAction.waitForDuration(0.1)
                        ])
                )
//                runAction(drainAction, withKey: "drainAction1")
            }

        } else if currentState == 2 {
            if(self.minutes - pelletGunTimer >= 10){
                ship.unShield()
            }
        } else if (currentState == 3) {
            // sound stuff
            //            fadingOut = true
            //            fadingIn = false
            //            doVolumeFadeOut()
            
        
            
            staminaBar.color = UIColor.greenColor()
            
            ship.unShield()
//            ship.texture = currentTexture
            
            if ship.getLaserActive() {
                ship.deactiveLaser(laser)
                laser.removeFromParent()
            }

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
    
    func addStar(starPosition:CGFloat) {
        // Create sprite
        let texture = SKTexture(imageNamed: "staru")
        ("staru")
        let star = Star(texture: texture, color: SKColor.redColor(), size: texture.size())
        star.starSetup(starPosition)
        
        // send up mini rock
        stars.addObject(star)
        self.addChild(star)
    }
    
    func addEnergy() {
        // Create sprite
        let texture = SKTexture(imageNamed: "EnergyUp")
        let energy = Energy(texture: texture, color: SKColor.redColor(), size: texture.size())
        
        
        // send up mini rock
        energies.addObject(energy)
        self.addChild(energy)
    }
    
    func addAsteroid() {
        // Create sprite
        let texture = SKTexture(imageNamed: "Asteroid1")
        let asteroid = Asteroid(texture: texture, color: SKColor.redColor(), size: texture.size())
        
        // setup Regular asteroid
        asteroid.asteroidSetup()
        
        // send up mini rock
        asteroids.addObject(asteroid)
        self.addChild(asteroid)
    }
    
    func addPelletPowerup() {
        // Create sprite
        let texture = SKTexture(imageNamed: "Laser2")
        let powerup = PelletGunPowerup(texture: texture, color: SKColor.redColor(), size: texture.size())
        
        // send up mini rock
        pelletGunPowerups.addObject(powerup)
        self.addChild(powerup)
    }
    
    func addLaserPowerup(){
        // Create sprite
        let texture = SKTexture(imageNamed: "Laser")
        let powerup = LaserPowerup(texture: texture, color: SKColor.redColor(), size: texture.size())
        
        // send up mini rock
        laserPowerups.addObject(powerup)
        self.addChild(powerup)
    }
    
    func addAsteroidBelt() {
        let scalePic = CGFloat(0.7)
        // Create sprite
        let texture = SKTexture(imageNamed: "basicRock")
        
        // rand = the gaps size percentage
        //let rand = getRandom(min: 0.5, 0.7)
        let rand = CGFloat(0.5)
        
        let beltWidth = viewSize.width * rand
        let beltWidthRock = beltWidth/(texture.size().width * scalePic)
        let beltNumber = viewSize.width/(texture.size().width * scalePic)
        
        //        println("# rock \(beltNumber)  size of whole: \(beltWidthRock)")
        
        let holePercent = getRandom(min: 0.0, ((beltNumber-beltWidthRock)/beltNumber))
        
        var startHole = Int(holePercent*beltNumber)
        //        println("\(startHole)")
        
        var coord = -1
        var scale = CGFloat(1.1)
        var layer = 0
        
        // how long the belt is
//        var layerLimit = Int(getRandom(min: 15.0, 25.0))
//        var layerLimit = 40
        var layerLimit = 1
        
        // Constant change for uniform zig zags
        let change = getRandom(min: 0, 1.0)
        var directionGoing = "right"
        
        while layer < layerLimit {
            while coord < Int(beltNumber) {
                let asteroidAdd = Asteroid(texture: texture, color: SKColor.redColor(), size: texture.size())
                asteroidAdd.setScale(scalePic)
                if(startHole == coord){
                    coord = coord + Int(beltWidthRock)
                }else{
                    coord++
                }
//                asteroidAdd.asteroidBeltSetup(viewSize.width*((CGFloat(coord)+getRandom(min: 0.0, 1.0))/beltNumber), scale: scale)
                asteroidAdd.asteroidBeltSetup(viewSize.width*((CGFloat(coord))/beltNumber), scale: scale)
                asteroids.addObject(asteroidAdd)
                self.addChild(asteroidAdd)
            }
            
//            scale = scale + getRandom(min: 0.01, 0.05)
//            layer++
//            coord = -1
//            let change = getRandom(min: 0, 1.0)
//            if change < 0.20 {
//                if((startHole+1)+Int(beltWidthRock) <= Int(beltNumber)){
//                    startHole++
//                }else{
//                    startHole--
//                }
//                
//            } else if change > 0.80 {
//                if((startHole-1)-Int(beltWidthRock) >= 0 ){
//                    startHole--
//                }else{
//                    startHole++
//                }
//            }
            println("adding a layer")
            
            // Zig zag generation
//            scale = scale + getRandom(min: 0.01, 0.05)
//            println(texture.size().height)
            scale = scale + ((texture.size().height/1.0 * scalePic) / viewSize.height)
//            scale = scale + ((texture.size().height/1.5) / viewSize.height)
//            scale = scale + 0.1
            layer++
            coord = -1
            
            let zigzagDifficulty = 3
            
            if layer % zigzagDifficulty == 0 {
                if directionGoing == "right" {
                    if((startHole)+Int(beltWidthRock) <= Int(beltNumber)){
                        startHole++
                    } else {
                        directionGoing = "left"
                    }
                } else if directionGoing == "left" {
                    if(startHole >= 0 ){
                        startHole--
                    } else {
                        directionGoing = "right"
                    }
                }
            }
            
            
                
            
//            if change <= 0.50 {
//                if((startHole+1)+Int(beltWidthRock) <= Int(beltNumber)){
//                    startHole++
//                } else {
//                    startHole--
//                }
//                
//            } else {
//                if((startHole-1)-Int(beltWidthRock) >= 0 ){
//                    startHole--
//                }else{
//                    startHole++
//                }
//            }
        }
    }
    
    //Bullets Helpers
    
    func fireBullet(bullet: SKNode, toDestination destination:CGPoint, withDuration duration:CFTimeInterval, andSoundFileName soundName: String) {
        
        println("bullet")
        let bulletAction = SKAction.sequence([SKAction.moveTo(destination, duration: duration), SKAction.waitForDuration(3.0/60.0), SKAction.removeFromParent()])
        let sound = SKAction.playSoundFileNamed(soundName, waitForCompletion: false)
        bullet.runAction(SKAction.group([bulletAction, sound]))
        self.addChild(bullet)
    }
    
    let bulletSize = CGSizeMake(4, 8)
    func fireShipBullets() {
        
//        let existingBullet = self.childNodeWithName(nameShipBullet)
//        
//        if existingBullet == nil {
//            if let ship = self.childNodeWithName(nameShip) {
//                let texture = SKTexture(imageNamed: "Asteroid1")
//                let bullet = ShipBullet(texture: texture, color: SKColor.redColor(),
//                    size: texture.size())
//                bullet.position =
//                    CGPointMake(ship.position.x, ship.position.y + ship.frame.size.height - bullet.frame.size.height / 2)
//                let bulletDestination = CGPointMake(ship.position.x, self.frame.size.height + bullet.frame.size.height / 2)
//                self.fireBullet(bullet, toDestination: bulletDestination, withDuration: 1.0, andSoundFileName: "ShipBullet.wav")
//            }
//        }
        
        if let ship = self.childNodeWithName(nameShip) {
            let texture = SKTexture(imageNamed: "LaserBolt")
            let bullet = ShipBullet(texture: texture, color: SKColor.redColor(),
                size: texture.size())
            bullet.position =
                CGPointMake(ship.position.x, ship.position.y + ship.frame.size.height - bullet.frame.size.height / 2)
            let bulletDestination = CGPointMake(ship.position.x, self.frame.size.height + bullet.frame.size.height / 2)
            self.fireBullet(bullet, toDestination: bulletDestination, withDuration: 1.0, andSoundFileName: "LaserCannon.wav")
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
        shipLaserBulletAsteroidCollision(firstBody, secondBody: secondBody)
        pelletGunPowerupCollision(firstBody, secondBody: secondBody)
        energyCollision(firstBody, secondBody: secondBody)
        laserPowerupCollision(firstBody, secondBody: secondBody)
        asteroidCollision(firstBody, secondBody: secondBody)
        
    }
    
    func energyCollision(firstBody: SKPhysicsBody, secondBody: SKPhysicsBody){
        if ((firstBody.categoryBitMask & Contact.Ship != 0)
            && (secondBody.categoryBitMask & Contact.Energy != 0)) {
             
                //done to make sure removed from array too
//                energies.removeObject(secondBody.node!)
//                secondBody.node?.removeFromParent()
                
                secondBody.node!.position.y = viewSize.height * -0.1
                
                shipEnergy += 40
                var ratio = CGFloat(shipEnergy / maxEnergy)
                if (self.shipEnergy > 100) {
                    ratio = CGFloat(100.0)
                }
                staminaBar.size.height = maxStaminaBarHeight * CGFloat(ratio)
                
                runAction(SKAction.playSoundFileNamed("Powerup.wav", waitForCompletion: false))
        }
    }
    
    func pelletGunPowerupCollision(firstBody: SKPhysicsBody, secondBody: SKPhysicsBody){
        if ((firstBody.categoryBitMask & Contact.Ship != 0)
            && (secondBody.categoryBitMask & Contact.PelletGunPowerup != 0)) {
                
                //done to make sure removed from array too
                //                energies.removeObject(secondBody.node!)
                //                secondBody.node?.removeFromParent()
                
                if(ship.shipState == SpaceShip.states.SHIELDING){
                    updatePlayerState(3)
                }
                ship.pelletGun()
                pelletGunTimer = self.minutes
                secondBody.node!.position.y = viewSize.height * -0.1
                //                println("energy")
                
                runAction(SKAction.playSoundFileNamed("Powerup.wav", waitForCompletion: false))
        }
    }
    
    func laserPowerupCollision(firstBody: SKPhysicsBody, secondBody: SKPhysicsBody){
        if ((firstBody.categoryBitMask & Contact.Ship != 0)
            && (secondBody.categoryBitMask & Contact.LaserPowerup != 0)) {
                //done to make sure removed from array too
                //                energies.removeObject(secondBody.node!)
                //                secondBody.node?.removeFromParent()
                
                if(ship.shipState == SpaceShip.states.SHIELDING){
                    updatePlayerState(3)
                }
                ship.laser()
                println("ship set to laser!")
//                laserTimer = self.minutes
                secondBody.node!.position.y = viewSize.height * -0.1
                                println("energy")
                
                runAction(SKAction.playSoundFileNamed("Powerup.wav", waitForCompletion: false))
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
    
    func shipLaserBulletAsteroidCollision(firstBody: SKPhysicsBody, secondBody: SKPhysicsBody){
        if ((firstBody.categoryBitMask & Contact.Asteroid != 0)
            && (secondBody.categoryBitMask & Contact.Laser != 0)) {
                //done to make sure removed from array too
                println("COLLIDE")
                firstBody.node!.position.y = viewSize.height * -0.1
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



