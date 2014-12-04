//
//  OptionScene.swift
//  Space Race
//
//  Created by Joshua Yuen on 12/3/14.
//  Copyright (c) 2014 Max Takano. All rights reserved.
//

import Foundation
import SpriteKit

class OptionsScene: SKScene {
    
    var userDefaults = NSUserDefaults.standardUserDefaults()
    let _musicSwitch = SevenSwitch()
    let _soundSwitch = SevenSwitch()
    let _backButton: SKSpriteNode = SKSpriteNode(imageNamed: "backButton.png")
    let _backButtonPressed: SKSpriteNode = SKSpriteNode(imageNamed: "backButtonPressed.png")
    
    override func didMoveToView(view: SKView) {
        let BACK_POSITION = CGPoint(x: self.size.width * 0.2, y: self.size.height * 0.9)
        _backButtonPressed.position = BACK_POSITION
        _backButtonPressed.setScale(0.5);
        self.addChild(_backButtonPressed)
        _backButtonPressed.hidden = true
        
        _backButton.position = BACK_POSITION
        _backButton.setScale(0.5)
        self.addChild(_backButton)
        
        runAction(SKAction.sequence([
            SKAction.waitForDuration(0),
            SKAction.runBlock() {
                self.view?.addSubview(self._musicSwitch)
                self.view?.addSubview(self._soundSwitch)
                // anchorPoint
            }
            ])
        )
        _musicSwitch.center = CGPoint(x: self.size.width * 0.75, y: self.size.height * 0.75)
        _soundSwitch.center = CGPoint(x: self.size.width * 0.25, y: self.size.height * 0.75)
        
        // Associate events for when the switches are changed
        _musicSwitch.addTarget(self, action: "musicWasSwitched:", forControlEvents: UIControlEvents.ValueChanged)
        _soundSwitch.addTarget(self, action: "soundWasSwitched:", forControlEvents: UIControlEvents.ValueChanged)
        
        // Add labels to the switches
        let _musicLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        _musicLabel.fontSize = 15
        _musicLabel.position = CGPoint(x: self.size.width*0.75, y: self.size.height*0.80)
        _musicLabel.text = "Music"
        self.addChild(_musicLabel)
        
        let _soundLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        _soundLabel.fontSize = 15
        _soundLabel.position = CGPoint(x: self.size.width*0.25, y: self.size.height*0.80)
        _soundLabel.text = "Sound"
        self.addChild(_soundLabel)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {

    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {

    }
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {

    }
}