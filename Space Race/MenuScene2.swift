//
//  MenuScene.swift
//  Space Race
//
//  Created by Joshua Yuen on 12/2/14.
//  Copyright (c) 2014 Max Takano. All rights reserved.
//

import Foundation
import SpriteKit
import QuartzCore

class MenuScene2: SKScene {
    let _singlePlayerButton: SKSpriteNode = SKSpriteNode(imageNamed: "singlePlayerButton.png")
    let _singlePlayerButtonPressed: SKSpriteNode = SKSpriteNode(imageNamed: "singlePlayerButton_pressed.png")
    let _multiPlayerButton: SKSpriteNode = SKSpriteNode(imageNamed: "multiPlayerButon.png")
    let _multiPlayerButtonPressed: SKSpriteNode = SKSpriteNode(imageNamed: "multiPlayerButtonPressed.png")
    let _tutorialButton: SKSpriteNode = SKSpriteNode(imageNamed: "tutorialButton.png")
    let _tutorialButtonPressed: SKSpriteNode = SKSpriteNode(imageNamed: "tutorialButtonPressed.png")
    let _optionsButton: SKSpriteNode = SKSpriteNode(imageNamed: "optionsButton.png")
    let _optionsButtonPressed: SKSpriteNode = SKSpriteNode(imageNamed: "optionsButtonPressed.png")
    let _leaderboardButton: SKSpriteNode = SKSpriteNode(imageNamed: "leaderboardButton.png")
    let _leaderboardButtonPressed: SKSpriteNode = SKSpriteNode(imageNamed: "leaderboardButtonPressed.png")
    
    let SCALE_FACTOR: CGFloat = CGFloat(0.5)
    
    var firstTouched = "none"
    
    override func didMoveToView(view: SKView) {
        let SINGLEPLAYER_POINT = CGPoint(x:self.size.width/3, y:self.size.height * 0.5)
        _singlePlayerButtonPressed.position = SINGLEPLAYER_POINT
        _singlePlayerButtonPressed.setScale(SCALE_FACTOR)
        self.addChild(_singlePlayerButtonPressed)
        _singlePlayerButtonPressed.hidden = true
        
        let MULTIPLAYER_POINT = CGPoint(x:self.size.width/3, y:self.size.height * 0.35)
        _multiPlayerButtonPressed.position = MULTIPLAYER_POINT
        _multiPlayerButtonPressed.setScale(SCALE_FACTOR)
        self.addChild(_multiPlayerButtonPressed)
        _multiPlayerButtonPressed.hidden = true
        
        let TUTORIAL_POINT = CGPoint(x:self.size.width * 0.8, y:self.size.height * 0.1)
        _tutorialButtonPressed.position = TUTORIAL_POINT
        _tutorialButtonPressed.setScale(SCALE_FACTOR)
        self.addChild(_tutorialButtonPressed)
        _tutorialButtonPressed.hidden = true
        
        let OPTIONS_POINT = CGPoint(x:self.size.width * 0.5, y:self.size.height * 0.1)
        _optionsButtonPressed.position = OPTIONS_POINT
        _optionsButtonPressed.setScale(SCALE_FACTOR)
        self.addChild(_optionsButtonPressed)
        _optionsButtonPressed.hidden = true
        
        let LEADERBOARD_POINT = CGPoint(x:self.size.width * 0.2, y:self.size.height * 0.1)
        _leaderboardButtonPressed.position = LEADERBOARD_POINT
        _leaderboardButtonPressed.setScale(SCALE_FACTOR)
        self.addChild(_leaderboardButtonPressed)
        _leaderboardButtonPressed.hidden = true
        
        _singlePlayerButton.position = SINGLEPLAYER_POINT
        _singlePlayerButton.setScale(SCALE_FACTOR)
        self.addChild(_singlePlayerButton)
        
        _multiPlayerButton.position = MULTIPLAYER_POINT
        _multiPlayerButton.setScale(SCALE_FACTOR)
        self.addChild(_multiPlayerButton)

        _tutorialButton.position = TUTORIAL_POINT
        _tutorialButton.setScale(SCALE_FACTOR)
        self.addChild(_tutorialButton)
        
        _optionsButton.position = OPTIONS_POINT
        _optionsButton.setScale(SCALE_FACTOR)
        self.addChild(_optionsButton)
        
        _leaderboardButton.position = LEADERBOARD_POINT
        _leaderboardButton.setScale(SCALE_FACTOR)
        self.addChild(_leaderboardButton)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        println("touch began")
        for touch: AnyObject in touches {
            if CGRectContainsPoint(_singlePlayerButton.frame, touch.locationInNode(self)) {
                _singlePlayerButton.hidden = true
                _singlePlayerButtonPressed.hidden = false
                firstTouched = "singlePlayer"
            }
            if CGRectContainsPoint(_multiPlayerButton.frame, touch.locationInNode(self)) {
                _multiPlayerButton.hidden = true
                _multiPlayerButtonPressed.hidden = false
                firstTouched = "multiPlayer"
            }
            if CGRectContainsPoint(_tutorialButton.frame, touch.locationInNode(self)) {
                _tutorialButton.hidden = true
                _tutorialButtonPressed.hidden = false
                firstTouched = "tutorial"
            }
            if CGRectContainsPoint(_optionsButton.frame, touch.locationInNode(self)) {
                _optionsButton.hidden = true
                _optionsButtonPressed.hidden = false
                firstTouched = "options"
            }
            if CGRectContainsPoint(_leaderboardButton.frame, touch.locationInNode(self)) {
                _leaderboardButton.hidden = true
                _leaderboardButtonPressed.hidden = false
                firstTouched = "leaderboard"
            }
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            if CGRectContainsPoint(_singlePlayerButton.frame, touch.locationInNode(self)) &&
                                    firstTouched == "singlePlayer" {
                let transition = SKTransition.fadeWithDuration(1)
                let scene = GameScene(size: self.scene!.size)
                self.view?.presentScene(scene, transition: transition)
            }
            if CGRectContainsPoint(_multiPlayerButton.frame, touch.locationInNode(self)) &&
                                    firstTouched == "multiPlayer" {
                let transition = SKTransition.fadeWithDuration(1)
                let scene = GameScene(size: self.scene!.size)
                self.view?.presentScene(scene, transition: transition)
            }
            if CGRectContainsPoint(_tutorialButton.frame, touch.locationInNode(self)) &&
                                    firstTouched == "tutorial" {
//                let transition = SKTransition.fadeWithDuration(1)
//                let scene = TutorialScene(size: self.scene!.size)
//                self.view?.presentScene(scene, transition: transition)
            }
            if CGRectContainsPoint(_optionsButton.frame, touch.locationInNode(self)) &&
                                    firstTouched == "options" {
                let transition = SKTransition.fadeWithDuration(1)
                let scene = OptionsScene(size: self.scene!.size)
                self.view?.presentScene(scene, transition: transition)
            }
            if CGRectContainsPoint(_leaderboardButton.frame, touch.locationInNode(self)) &&
                                    firstTouched == "leaderboard" {
//                let transition = SKTransition.fadeWithDuration(1)
//                let scene = LeaderboardScene(size: self.scene!.size)
//                self.view?.presentScene(scene, transition: transition)
            }
        }
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        println("touch moved")
        for touch: AnyObject in touches {
            if CGRectContainsPoint(_singlePlayerButton.frame, touch.locationInNode(self)) {
                _singlePlayerButton.hidden = false
                _singlePlayerButtonPressed.hidden = true
            }
            if CGRectContainsPoint(_multiPlayerButton.frame, touch.locationInNode(self)) {
                _multiPlayerButton.hidden = false
                _multiPlayerButtonPressed.hidden = true
            }
            if CGRectContainsPoint(_tutorialButton.frame, touch.locationInNode(self)) {
                _tutorialButton.hidden = false
                _tutorialButtonPressed.hidden = true
            }
            if CGRectContainsPoint(_optionsButton.frame, touch.locationInNode(self)) {
                _optionsButton.hidden = false
                _optionsButtonPressed.hidden = true
            }
            if CGRectContainsPoint(_leaderboardButton.frame, touch.locationInNode(self)) {
                _leaderboardButton.hidden = false
                _leaderboardButtonPressed.hidden = true
            }
        }
    }
    
    override func touchesCancelled(touches: NSSet, withEvent event: UIEvent) {
        println("touch cancelled")
    }
}