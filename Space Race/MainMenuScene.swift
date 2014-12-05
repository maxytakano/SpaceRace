//
//  MenuScene.swift
//  SpriteKitSimpleGame
//
//  Created by Max Takano on 10/16/2014
//  Copyright (c) 2014 Max Takano. All rights reserved.
//

import Foundation
import SpriteKit
import GameKit
import UIKit

class MainMenuScene: SKScene {
    
    let background = SKSpriteNode(imageNamed: "background2")
    let _singlePlayerButton: SKSpriteNode = SKSpriteNode(imageNamed: "startButton1")
    let _multiPlayerButton: SKSpriteNode = SKSpriteNode(imageNamed: "startButton1")
    let _tutorialButton: SKSpriteNode = SKSpriteNode(imageNamed: "tutorialButton.png")
    let _optionsButton: SKSpriteNode = SKSpriteNode(imageNamed: "optionsButton.png")
    let _leaderboardButton: SKSpriteNode = SKSpriteNode(imageNamed: "leaderboardButton.png")
    
    let UPSCALE_FACTOR: CGFloat = CGFloat(1.0)
    let DOWNSCALE_FACTOR: CGFloat = CGFloat(0.5)
    
    var firstTouched = "none"
    
    override func didMoveToView(view: SKView) {
//        // initialize high score for first run
//        if (NSUserDefaults.standardUserDefaults().objectForKey("HighScore") == nil) {
//            //println("first Score")
//            var firstScore:[Int] = [0, 0]
//            var firstScoreAsNSArray = NSArray(array: firstScore)
//            
//            NSUserDefaults.standardUserDefaults().setObject(firstScoreAsNSArray, forKey:"HighScore")
//            NSUserDefaults.standardUserDefaults().synchronize()
//        }
        
        background.anchorPoint = CGPoint(x: 0, y: 0)
        background.size = self.size
        background.zPosition = -2
        self.addChild(background)
        
        
        // start button unpressed
        _singlePlayerButton.position = CGPoint(x: self.size.width/2 , y:self.size.height * 0.40)
        _singlePlayerButton.setScale(UPSCALE_FACTOR)
        
        self.addChild(_singlePlayerButton)
        
        // leaderboard button unpressed
        _multiPlayerButton.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.25)
        _multiPlayerButton.setScale(UPSCALE_FACTOR)
        self.addChild(_multiPlayerButton)
        
        let TUTORIAL_POINT = CGPoint(x:self.size.width * 0.8, y:self.size.height * 0.1)
        _tutorialButton.position = TUTORIAL_POINT
        _tutorialButton.setScale(DOWNSCALE_FACTOR)
        self.addChild(_tutorialButton)
        
        let OPTIONS_POINT = CGPoint(x:self.size.width * 0.5, y:self.size.height * 0.1)
        _optionsButton.position = OPTIONS_POINT
        _optionsButton.setScale(DOWNSCALE_FACTOR)
        self.addChild(_optionsButton)
        
        let LEADERBOARD_POINT = CGPoint(x:self.size.width * 0.2, y:self.size.height * 0.1)
        _leaderboardButton.position = LEADERBOARD_POINT
        _leaderboardButton.setScale(DOWNSCALE_FACTOR)
        self.addChild(_leaderboardButton)

    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            if CGRectContainsPoint(_singlePlayerButton.frame, touch.locationInNode(self)) {
                _singlePlayerButton.color = UIColor.redColor()
                _singlePlayerButton.colorBlendFactor = 1.0
                firstTouched = "singlePlayer"
            }
            if CGRectContainsPoint(_multiPlayerButton.frame, touch.locationInNode(self)) {
                _multiPlayerButton.color = UIColor.redColor()
                _multiPlayerButton.colorBlendFactor = 1.0
                firstTouched = "multiPlayer"
            }
            if CGRectContainsPoint(_tutorialButton.frame, touch.locationInNode(self)) {
                _tutorialButton.color = UIColor.redColor()
                _tutorialButton.colorBlendFactor = 1.0
                firstTouched = "tutorial"
            }
            if CGRectContainsPoint(_optionsButton.frame, touch.locationInNode(self)) {
                _optionsButton.color = UIColor.redColor()
                _optionsButton.colorBlendFactor = 1.0
                firstTouched = "options"
            }
            if CGRectContainsPoint(_leaderboardButton.frame, touch.locationInNode(self)) {
                _leaderboardButton.color = UIColor.redColor()
                _leaderboardButton.colorBlendFactor = 1.0
                firstTouched = "leaderboard"
            }
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            if CGRectContainsPoint(_singlePlayerButton.frame, touch.locationInNode(self)) &&
                                    firstTouched == "singlePlayer"  {
                let transition = SKTransition.fadeWithDuration(1)
                let scene = GameScene(size: self.scene!.size)
                self.view?.presentScene(scene, transition: transition)
            }
            if CGRectContainsPoint(_multiPlayerButton.frame, touch.locationInNode(self)) &&
                                    firstTouched == "multiPlayer" {
                // tell the view controller to switch to the multiplayer view.
                NSNotificationCenter.defaultCenter().postNotificationName("GoToMultiplayer", object: self)
//                let transition = SKTransition.fadeWithDuration(1)
//                let scene = MultiplayerStaging(size: self.scene!.size)
//                self.view?.presentScene(scene, transition: transition)
            }
//            if CGRectContainsPoint(_tutorialButton.frame, touch.locationInNode(self)) &&
//                firstTouched == "tutorial"  {
//                    let transition = SKTransition.fadeWithDuration(1)
//                    let scene = TutorialScene(size: self.scene!.size)
//                    self.view?.presentScene(scene, transition: transition)
//            }
            if CGRectContainsPoint(_optionsButton.frame, touch.locationInNode(self)) &&
                firstTouched == "options"  {
                    let transition = SKTransition.fadeWithDuration(1)
                    let scene = OptionsScene(size: self.scene!.size)
                    self.view?.presentScene(scene, transition: transition)
            }
//            if CGRectContainsPoint(_leaderboardButton.frame, touch.locationInNode(self)) &&
//                firstTouched == "leaderboard"  {
//                    let transition = SKTransition.fadeWithDuration(1)
//                    let scene = LeaderboardScene(size: self.scene!.size)
//                    self.view?.presentScene(scene, transition: transition)
//            }
            _singlePlayerButton.colorBlendFactor = 0.0
            _multiPlayerButton.colorBlendFactor = 0.0
            _tutorialButton.colorBlendFactor = 0.0
            _optionsButton.colorBlendFactor = 0.0
            _leaderboardButton.colorBlendFactor = 0.0
        }
    }
    
    
    /*override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
    
    }
    
    override func touchesCancelled(touches: NSSet, withEvent event: UIEvent) {
    
    }*/
}

