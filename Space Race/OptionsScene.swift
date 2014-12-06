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
    var firstTouched = "none"
    
    let _musicSwitchOn: SKSpriteNode = SKSpriteNode(imageNamed: "switchOn.png")
    let _musicSwitchOff: SKSpriteNode = SKSpriteNode(imageNamed: "switchOff.png")
    let _soundSwitchOn: SKSpriteNode = SKSpriteNode(imageNamed: "switchOn.png")
    let _soundSwitchOff: SKSpriteNode = SKSpriteNode(imageNamed: "switchOff.png")
    let _backButton: SKSpriteNode = SKSpriteNode(imageNamed: "backButton.png")
    
    override func didMoveToView(view: SKView) {
        let BACK_POSITION = CGPoint(x: self.size.width * 0.15, y: self.size.height * 0.9)
        _backButton.position = BACK_POSITION
        _backButton.setScale(0.5)
        self.addChild(_backButton)
        
        let MUSIC_POSITION = CGPoint(x: self.size.width * 0.75, y: self.size.height * 0.70)
        _musicSwitchOff.position = MUSIC_POSITION
        _musicSwitchOff.setScale(0.5)
        self.addChild(_musicSwitchOff)
        
        _musicSwitchOn.position = MUSIC_POSITION
        _musicSwitchOn.setScale(0.5)
        self.addChild(_musicSwitchOn)
        
        let SOUND_POSITION = CGPoint(x: self.size.width * 0.25, y: self.size.height * 0.70)
        _soundSwitchOff.position = SOUND_POSITION
        _soundSwitchOff.setScale(0.5)
        self.addChild(_soundSwitchOff)
        
        _soundSwitchOn.position = SOUND_POSITION
        _soundSwitchOn.setScale(0.5)
        self.addChild(_soundSwitchOn)
        
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
                setOn(_soundSwitchOn)
                
                if let musicIsOn = userDefaults.valueForKey("music") as? Int {
                    if(musicIsOn == 1) {
                        setOn(_musicSwitchOn)
                    }
                    else {
                        setOn(_musicSwitchOn)
                    }
                }
            }
            else {
                setOn(_soundSwitchOn)
                setOn(_musicSwitchOn)
            }
        }
        else {
            setOn(_musicSwitchOn)
            setOn(_soundSwitchOn)
        }
        
        //add credits
        let _creditsLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        _creditsLabel.fontSize = 12
        _creditsLabel.position = CGPoint(x: self.size.width * 0.25, y: self.size.height * 0.5)
        _creditsLabel.text = "Credits"
        self.addChild(_creditsLabel)
        
        let _creditsContent = UILabel(frame: CGRectMake(0, 0,
            self.size.width, self.size.height))
        //originX, originY, width, height
        _creditsContent.center = CGPoint(x: self.size.width * 0.25, y: self.size.width * 0.6 )
        _creditsContent.textAlignment = NSTextAlignment.Left
        _creditsContent.numberOfLines = 0
        _creditsContent.lineBreakMode = NSLineBreakMode.ByWordWrapping
        _creditsContent.textColor = UIColor.whiteColor()
        println(_creditsContent.textColor)
        _creditsContent.font = UIFont(name: "Menlo-Bold", size: 10)
        
        self.view?.addSubview(_creditsContent)
        
        
        
        
        //finished
        println("didMoveToView OptionScene")
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        println("touch began")
        for touch: AnyObject in touches {
            if CGRectContainsPoint(_backButton.frame, touch.locationInNode(self)) {
                _backButton.color = UIColor.redColor()
                _backButton.colorBlendFactor = 1.0
                firstTouched = "back"
            }
            if CGRectContainsPoint(_soundSwitchOn.frame, touch.locationInNode(self)) {
                firstTouched = "sound"
            }
            if CGRectContainsPoint(_musicSwitchOn.frame, touch.locationInNode(self)) {
                firstTouched = "music"
            }
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        println("touch ended")
        for touch: AnyObject in touches {
            if CGRectContainsPoint(_backButton.frame, touch.locationInNode(self)) &&
                firstTouched == "back" {
                    let transition = SKTransition.fadeWithDuration(1)
                    let scene = MainMenu(size: self.scene!.size)
                    self.view?.presentScene(scene, transition: transition)
            }
            if CGRectContainsPoint(_musicSwitchOn.frame, touch.locationInNode(self)) &&
                firstTouched == "music" {
                    if (isHidden(_musicSwitchOn)) {
                        setOn(_musicSwitchOn)
                    }
                    else {
                        setOff(_musicSwitchOn)
                    }
            }
            if CGRectContainsPoint(_soundSwitchOn.frame, touch.locationInNode(self)) &&
                firstTouched == "sound" {
                    if (isHidden(_soundSwitchOn)) {
                        setOn(_soundSwitchOn)
                    }
                    else {
                        setOff(_soundSwitchOn)
                    }
            }
        }
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        println("touch moved")
        for touch: AnyObject in touches {
            if CGRectContainsPoint(_backButton.frame, touch.locationInNode(self)) &&
                firstTouched == "back" {
                    _backButton.color = UIColor.redColor()
                    _backButton.colorBlendFactor = 1.0
            }
        }
    }
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
        // not needed
    }
    
    func setOn(sender: SKSpriteNode) {
        if (isSwitchMusic(sender)) {
            _musicSwitchOn.hidden = false
            _musicSwitchOff.hidden = true
            saveSwitchResults("music", switchedTo: isHidden(_musicSwitchOn))
            println("music on")
        }
        else {
            _soundSwitchOn.hidden = false
            _soundSwitchOff.hidden = true
            saveSwitchResults("sound", switchedTo: isHidden(_soundSwitchOn))
            println("sound on")
        }
    }
    
    func setOff(sender: SKSpriteNode) {
        if (isSwitchMusic(sender)) {
            _musicSwitchOn.hidden = true
            _musicSwitchOff.hidden = false
            saveSwitchResults("music", switchedTo: isHidden(_musicSwitchOn))
            println("music off")
        }
        else {
            _soundSwitchOn.hidden = true
            _soundSwitchOff.hidden = false
            saveSwitchResults("sound", switchedTo: isHidden(_soundSwitchOn))
            println("sound off")
        }
    }
    
    func isHidden (sender: SKSpriteNode) -> Bool{
        if (isSwitchMusic(sender)) {
            return _musicSwitchOn.hidden
        }
        else {
            return _soundSwitchOn.hidden
        }
    }
    
    func isSwitchMusic(sender: SKSpriteNode) -> Bool {
        return (sender == _musicSwitchOn || sender == _musicSwitchOff)
    }
    
    // Function to save the current state of the for states as default
    func saveSwitchResults(switchName: String, switchedTo: Bool) {
        userDefaults.setValue(isHidden(_musicSwitchOn), forKey: "music")
        userDefaults.setValue(isHidden(_soundSwitchOn), forKey: "sound")
        userDefaults.synchronize()
        println("defaults saved")
    }
}
