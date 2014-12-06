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
    
    let background = SKSpriteNode(imageNamed: "background2")
    let _playButton: SKSpriteNode = SKSpriteNode(imageNamed: "startButton1")
    let _menuButton: SKSpriteNode = SKSpriteNode(imageNamed: "startButton1")
    let _leaderButton: SKSpriteNode = SKSpriteNode(imageNamed: "leaderboardButton1")
    let _optionsButton: SKSpriteNode = SKSpriteNode(imageNamed: "againButton")
    
    override func didMoveToView(view: SKView) {
        // initialize high score for first run
        if (NSUserDefaults.standardUserDefaults().objectForKey("HighScore") == nil) {
            //println("first Score")
            var firstScore:[Int] = [0, 0]
            var firstScoreAsNSArray = NSArray(array: firstScore)
            
            NSUserDefaults.standardUserDefaults().setObject(firstScoreAsNSArray, forKey:"HighScore")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
        background.anchorPoint = CGPoint(x: 0, y: 0)
        background.size = self.size
        background.zPosition = -2
        self.addChild(background)
        
        
        // start button unpressed
        _playButton.position = CGPoint(x: self.size.width/2 , y:self.size.height * 0.38)
        _playButton.setScale(1.2)
        
        self.addChild(_playButton)
        
        // multiplayer button unpressed
        _menuButton.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.18)
        _menuButton.setScale(1.2)
        self.addChild(_menuButton)
        
        // leader button unpressed
        _leaderButton.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.8)
        _leaderButton.setScale(1.2)
        self.addChild(_leaderButton)
        
        // options button unpressed
        _optionsButton.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.6)
        _optionsButton.setScale(1.2)
        self.addChild(_optionsButton)
        
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            if CGRectContainsPoint(_playButton.frame, touch.locationInNode(self)) {
                _playButton.color = UIColor.redColor()
                _playButton.colorBlendFactor = 1.0
            }
            if CGRectContainsPoint(_menuButton.frame, touch.locationInNode(self)) {
                _menuButton.color = UIColor.redColor()
                _menuButton.colorBlendFactor = 1.0
            }
            if CGRectContainsPoint(_leaderButton.frame, touch.locationInNode(self)) {
                _leaderButton.color = UIColor.redColor()
                _leaderButton.colorBlendFactor = 1.0
            }
            if CGRectContainsPoint(_optionsButton.frame, touch.locationInNode(self)) {
                _optionsButton.color = UIColor.redColor()
                _optionsButton.colorBlendFactor = 1.0
            }
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            if CGRectContainsPoint(_playButton.frame, touch.locationInNode(self))  {
                let transition = SKTransition.fadeWithDuration(1)
                let scene = GameScene(size: self.scene!.size)
                self.view?.presentScene(scene, transition: transition)
            }
            if CGRectContainsPoint(_menuButton.frame, touch.locationInNode(self)) {
                // tell the view controller to switch to the multiplayer view.
                NSNotificationCenter.defaultCenter().postNotificationName("GoToMultiplayer", object: self)
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
        
            
            _playButton.colorBlendFactor = 0.0
            _menuButton.colorBlendFactor = 0.0
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

