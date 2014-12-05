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
        let BACK_POSITION = CGPoint(x: self.size.width * 0.15, y: self.size.height * 0.9)
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
        
        //SevenSwitch is top left, while iOS default is bottom left
        _musicSwitch.center = CGPoint(x: self.size.width * 0.75, y: self.size.height * 0.30)
        _soundSwitch.center = CGPoint(x: self.size.width * 0.25, y: self.size.height * 0.30)
        
        // Associate events for when the switches are changed
        _musicSwitch.addTarget(self, action: "musicWasSwitched:", forControlEvents: UIControlEvents.ValueChanged)
        _soundSwitch.addTarget(self, action: "soundWasSwitched:", forControlEvents: UIControlEvents.ValueChanged)
        
        // Add labels to the switches
        let _musicLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        _musicLabel.fontSize = 15
        _musicLabel.position = CGPoint(x: self.size.width*0.75, y: self.size.height*0.75)
        _musicLabel.text = "Music"
        self.addChild(_musicLabel)
        
        let _soundLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        _soundLabel.fontSize = 15
        _soundLabel.position = CGPoint(x: self.size.width*0.25, y: self.size.height*0.75)
        _soundLabel.text = "Sound"
        self.addChild(_soundLabel)
        
        // Get defaults from app data
        if let soundIsOn = userDefaults.valueForKey("sound") as? Int{
            if(soundIsOn == 1) {
                _soundSwitch.setOn(true, animated: false)
                
                if let musicIsOn = userDefaults.valueForKey("music") as? Int {
                    if(musicIsOn == 1) {
                        _musicSwitch.setOn(true, animated: false)
                    }
                    else {
                        _musicSwitch.setOn(false, animated: false)
                    }
                }
            }
            else {
                _soundSwitch.setOn(false, animated: false)
                _musicSwitch.setOn(false, animated: false)
            }
        }
        else {
            _musicSwitch.setOn(true, animated: true)
            _soundSwitch.setOn(true, animated: true)
        }
        
        //add credits
        
        
        //finished
        println("didMoveToView OptionScene")
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        println("touch began")
        for touch: AnyObject in touches {
            if CGRectContainsPoint(_backButton.frame, touch.locationInNode(self)) {
                _backButton.hidden = true
                _backButtonPressed.hidden = false
            }
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        println("touch ended")
        for touch: AnyObject in touches {
            if CGRectContainsPoint(_backButton.frame, touch.locationInNode(self))  {
                
                let transition = SKTransition.fadeWithDuration(1)
                let scene = MainMenuScene(size: self.scene!.size)
                self.view?.presentScene(scene, transition: transition)
                _musicSwitch.removeFromSuperview()
                _soundSwitch.removeFromSuperview()
            }
        }
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        println("touch moved")
        for touch: AnyObject in touches {
            if CGRectContainsPoint(_backButton.frame, touch.locationInNode(self)) {
                _backButton.hidden = false
                _backButtonPressed.hidden = true
            }
        }
    }
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
        // not needed
    }
    
    // Function for when music switch changes
    func musicWasSwitched(sender: SevenSwitch) {
        saveSwitchResults("music", offOrOn: sender.on)
    }
    
    // Function for when sound switch changes
    func soundWasSwitched(sender: SevenSwitch) {
        saveSwitchResults("sound", offOrOn: sender.on)
        
    }
    
    // Function to save the current state of the for states as default
    func saveSwitchResults(switchName: String, offOrOn: Bool) {
        switch switchName {
            case "music":
                _musicSwitch.setOn(offOrOn, animated: true)
                println("musicSwitch switched")
            case "sound":
                _soundSwitch.setOn(offOrOn, animated: true)
                println("soundSwitch switched")
            default:
                println("switch unknown")
        }
        
        userDefaults.setValue(_musicSwitch.on, forKey: "music")
        userDefaults.setValue(_soundSwitch.on, forKey: "sound")
        userDefaults.synchronize()
    }
}