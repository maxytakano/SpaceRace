//
//  MenuScene.swift
//  SpriteKitSimpleGame
//
//  Created by Max Takano on 10/16/2014
//  Copyright (c) 2014 Max Takano. All rights reserved.
//

import SpriteKit
import GameKit
import UIKit


class MainMenu: SKScene {
    
    //    let background = SKSpriteNode(imageNamed: "background2")
    let _title:SKSpriteNode = SKSpriteNode(imageNamed:"TitleBanner")
    let _singlePlayerButton: SKSpriteNode = SKSpriteNode(imageNamed: "SinglePlayer")
    let _multiPlayerButton: SKSpriteNode = SKSpriteNode(imageNamed: "MultiPlayer")
    let _leaderButton: SKSpriteNode = SKSpriteNode(imageNamed: "Leaderboard")
    let _optionsButton: SKSpriteNode = SKSpriteNode(imageNamed: "Options")
    
    /**************** Star Scroller ****************/

    var mystars:NSMutableArray = []
    var mycentisecondsPerStar = 0
    var mystarSpanTime = 0.0
    var mystarsOnScreen = 160.0
    var mystarsPerSecond = 0.0
    var mystarsPerCentisecond = 0.0
    var mystarCounter = 0
    var mystarSpeed = 100
    
    func myinitStars() {
//        stars = []
//        starCounter = 0
//        centisecondsPerStar = 999999
//        starSpanTime = 0.0
//        starsOnScreen = 120.0
//        starsPerSecond = 0.0
//        starsPerCentisecond = 0.0
//        starSpeed = 300
        mypregenStars()
        
        var mytimer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: Selector("mytimerUpdate"), userInfo: nil, repeats: true)
        
    }
    
    func mypregenStars() {
        var myplacement:CGFloat = 0.0
        for (var i = 0; i < Int(mystarsOnScreen); i++ ) {
            println(mystarsOnScreen)
            myplacement += (self.size.height / CGFloat(mystarsOnScreen))
            myaddStar(myplacement)
        }
    }
    
    func mytimerUpdate() {
        mystarCounter++
        if mystarCounter > mycentisecondsPerStar {
            mystarCounter = 0
            myaddStar(self.size.height * 1.1)
        }
        
        mystarSpanTime = 520.0 / (Double(mystarSpeed)/3.0)
        mystarsPerSecond = mystarsOnScreen / mystarSpanTime
        mystarsPerCentisecond = mystarsPerSecond/100.0
        mycentisecondsPerStar = Int(1.0/mystarsPerCentisecond)
        
        for star in mystars {
            var myhalfSpeed = Double(mystarSpeed) / 3.0
            (star as Star).updateVelocity(myhalfSpeed)
            if star.position.y < self.size.height * -0.1 {
                mystars.removeObject(star)
                star.removeFromParent()
            }
        }
    }
    
    func myaddStar(starPosition:CGFloat) {
        // Create sprite
        let texture = SKTexture(imageNamed: "staru")
        ("staru")
        let star = Star(texture: texture, color: SKColor.redColor(), size: texture.size())
        star.mystarSetup(starPosition)
        
        let randomX = getRandom(min: CGFloat(0.0), CGFloat(1.0))
        star.position.x = self.size.width * randomX
        star.zPosition = -10
        
        mystars.addObject(star)
        self.addChild(star)
    }
    
    /**************** Star Scroller ****************/
    
    override func didMoveToView(view: SKView) {
        // initialize high score for first run
        if (NSUserDefaults.standardUserDefaults().objectForKey("HighScore") == nil) {
            //println("first Score")
            var firstScore:[Int] = [0, 0]
            var firstScoreAsNSArray = NSArray(array: firstScore)
            
            NSUserDefaults.standardUserDefaults().setObject(firstScoreAsNSArray, forKey:"HighScore")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
        myinitStars()
        
        if currentTrack != "Keep Running.wav" {
            playBackgroundMusic("Keep Running.wav")
        }
        
        //        background.anchorPoint = CGPoint(x: 0, y: 0)
        //        background.size = self.size
        //        background.zPosition = -2
        //        self.addChild(background)
        self.backgroundColor = UIColor.blackColor()
        
        //title banner
        _title.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.8)
        _title.setScale(1.5)
        self.addChild(_title)
        
        // start button unpressed
        _singlePlayerButton.position = CGPoint(x: self.size.width * 0.5 , y:self.size.height * 0.57)
        _singlePlayerButton.setScale(2.4)
        self.addChild(_singlePlayerButton)
        
        // multiplayer button unpressed
        _multiPlayerButton.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.35)
        _multiPlayerButton.setScale(2.4)
        self.addChild(_multiPlayerButton)
        
        // leader button unpressed
        _leaderButton.position = CGPoint(x: self.size.width * 0.26, y: self.size.height * 0.15)
        _leaderButton.setScale(1.4)
        self.addChild(_leaderButton)
        
        // options button unpressed
        _optionsButton.position = CGPoint(x: self.size.width * 0.74, y: self.size.height * 0.15)
        _optionsButton.setScale(1.4)
        self.addChild(_optionsButton)
        
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            if CGRectContainsPoint(_singlePlayerButton.frame, touch.locationInNode(self)) {
                _singlePlayerButton.color = UIColor.blueColor()
                _singlePlayerButton.colorBlendFactor = 0.3
            }
            if CGRectContainsPoint(_multiPlayerButton.frame, touch.locationInNode(self)) {
                _multiPlayerButton.color = UIColor.blueColor()
                _multiPlayerButton.colorBlendFactor = 0.3
            }
            if CGRectContainsPoint(_leaderButton.frame, touch.locationInNode(self)) {
                _leaderButton.color = UIColor.blueColor()
                _leaderButton.colorBlendFactor = 0.3
            }
            if CGRectContainsPoint(_optionsButton.frame, touch.locationInNode(self)) {
                _optionsButton.color = UIColor.blueColor()
                _optionsButton.colorBlendFactor = 0.3
            }
        }
    }


    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            if CGRectContainsPoint(_singlePlayerButton.frame, touch.locationInNode(self))  {
                let transition = SKTransition.fadeWithDuration(1)
                let scene = ShipSelectionScene(size: self.scene!.size, multiplayer: false)
                self.view?.presentScene(scene, transition: transition)
            }
            if CGRectContainsPoint(_multiPlayerButton.frame, touch.locationInNode(self)) {
                // tell the view controller to switch to the multiplayer view.
//                NSNotificationCenter.defaultCenter().postNotificationName("GoToMultiplayer", object: self)
                // !!!! pass in a bool to ship selection for multi or not
                
                let transition = SKTransition.fadeWithDuration(1)
                let scene = ShipSelectionScene(size: self.scene!.size, multiplayer: true)
                self.view?.presentScene(scene, transition: transition)
            }
            if CGRectContainsPoint(_leaderButton.frame, touch.locationInNode(self)) {
                // Show the score scene
                let transition = SKTransition.fadeWithDuration(1)
                let scene = ScoresScene(size: self.scene!.size)
                self.view?.presentScene(scene, transition: transition)
            }
            if CGRectContainsPoint(_optionsButton.frame, touch.locationInNode(self)) {
                // Show the score scene
                let transition = SKTransition.fadeWithDuration(1)
                let scene = OptionsScene(size: self.scene!.size)
                self.view?.presentScene(scene, transition: transition)
            }
        
            
            _singlePlayerButton.colorBlendFactor = 0.0
            _multiPlayerButton.colorBlendFactor = 0.0
            _leaderButton.colorBlendFactor = 0.0
            _optionsButton.colorBlendFactor = 0.0
        }
    }
    
    /*override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
    for touch: AnyObject in touches {
    if CGRectContainsPoint(_playButton.frame, touch.locationInNode(self)) {
    _playButton.hidden = false
    _playButtonPressed.hidden = true
    }
    if CGRectContainsPoint(_menuButton.frame, touch.locationInNode(self)) {
    _menuButton.hidden = false
    _menuButtonPressed.hidden = true
    }
    }
    }*/
    
    /*override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
    
    }
    
    override func touchesCancelled(touches: NSSet, withEvent event: UIEvent) {
    
    }*/
}

