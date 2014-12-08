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
    
    let _musicSwitchOn: SKSpriteNode = SKSpriteNode(imageNamed: "SwitchOn")
    let _musicSwitchOff: SKSpriteNode = SKSpriteNode(imageNamed: "SwitchOff")
    let _soundSwitchOn: SKSpriteNode = SKSpriteNode(imageNamed: "SwitchOn")
    let _soundSwitchOff: SKSpriteNode = SKSpriteNode(imageNamed: "SwitchOff")
    let _backButton: SKSpriteNode = SKSpriteNode(imageNamed: "Back")
    let _creditsButton: SKSpriteNode = SKSpriteNode(imageNamed: "credits")
    let _tutorialButton: SKSpriteNode = SKSpriteNode(imageNamed: "Tutorial")
    
    override func didMoveToView(view: SKView) {
        let _optionsLabel = SKLabelNode(fontNamed: "Transformers Movie")
        _optionsLabel.fontSize = 45
        _optionsLabel.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.78)
        _optionsLabel.text = "OPTIONS"
        self.addChild(_optionsLabel)
        
        let BACK_POSITION = CGPoint(x: _backButton.size.width/2, y: self.size.height-(_backButton.size.height)/2.1)
        _backButton.position = BACK_POSITION
        _backButton.setScale(0.8)
        self.addChild(_backButton)
        
        let MUSIC_POSITION = CGPoint(x: self.size.width * 0.75, y: self.size.height * 0.70)
        _musicSwitchOff.position = MUSIC_POSITION
        _musicSwitchOff.setScale(0.8)
        self.addChild(_musicSwitchOff)
        
        _musicSwitchOn.position = MUSIC_POSITION
        _musicSwitchOn.setScale(0.8)
        self.addChild(_musicSwitchOn)
        
        let _musicLabel = SKLabelNode(fontNamed: "Transformers Movie")
        _musicLabel.fontSize = 30
        _musicLabel.position = CGPoint(x: self.size.width * 0.26, y: self.size.height * 0.68)
        _musicLabel.text = "MUSIC"
        self.addChild(_musicLabel)
        
        let SOUND_POSITION = CGPoint(x: self.size.width * 0.75, y: self.size.height * 0.59)
        _soundSwitchOff.position = SOUND_POSITION
        _soundSwitchOff.setScale(0.8)
        self.addChild(_soundSwitchOff)
        
        _soundSwitchOn.position = SOUND_POSITION
        _soundSwitchOn.setScale(0.8)
        self.addChild(_soundSwitchOn)
        
        let _soundLabel = SKLabelNode(fontNamed: "Transformers Movie")
        _soundLabel.fontSize = 30
        _soundLabel.position = CGPoint(x: self.size.width * 0.25, y: self.size.height * 0.57)
        _soundLabel.text = "SOUND"
        self.addChild(_soundLabel)
        
        
        
        // Get defaults from app data
        if let soundIsOn = userDefaults.valueForKey("sound") as? Bool {
            if (soundIsOn) {
                setOn(_soundSwitchOn)
            }
            else {
                setOff(_soundSwitchOn)
            }
        }
        else { //soundIsOn = nil
            setOn(_soundSwitchOn)
        }
        
        if let musicIsOn = userDefaults.valueForKey("music") as? Bool {
            if (musicIsOn) {
                setOn(_musicSwitchOn)
            }
            else {
                setOff(_musicSwitchOn)
            }
        }
        else { //musicIsOn = nil
            setOn(_musicSwitchOn)
        }
        
        _tutorialButton.position = CGPoint(x: self.size.width * 0.25, y: self.size.height * 0.44)
        _tutorialButton.setScale(1.4)
        self.addChild(_tutorialButton)
        
        _creditsButton.position = CGPoint(x: self.size.width * 0.75, y:self.size.height * 0.44)
        _creditsButton.setScale(1.4)
        self.addChild(_creditsButton)
        
        //
        //        let _creditsContent = UILabel(frame: CGRectMake(0, 0,
        //            self.size.width, self.size.height))
        //        //originX, originY, width, height
        //        _creditsContent.center = CGPoint(x: self.size.width * 0.25, y: self.size.width * 0.6 )
        //        _creditsContent.textAlignment = NSTextAlignment.Left
        //        _creditsContent.numberOfLines = 0
        //        _creditsContent.lineBreakMode = NSLineBreakMode.ByWordWrapping
        //        _creditsContent.textColor = UIColor.whiteColor()
        //        println(_creditsContent.textColor)
        //        _creditsContent.font = UIFont(name: "Menlo-Bold", size: 10)
        //
        //        self.view?.addSubview(_creditsContent)
        
        
        
        
        //finished
        println("didMoveToView OptionsScene")
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        println("touch began")
        for touch: AnyObject in touches {
            if CGRectContainsPoint(_backButton.frame, touch.locationInNode(self)) {
                _backButton.color = UIColor.blueColor()
                _backButton.colorBlendFactor = 0.3
                firstTouched = "back"
            }
            if CGRectContainsPoint(_soundSwitchOn.frame, touch.locationInNode(self)) {
                firstTouched = "sound"
            }
            if CGRectContainsPoint(_musicSwitchOn.frame, touch.locationInNode(self)) {
                firstTouched = "music"
            }
            if CGRectContainsPoint(_tutorialButton.frame, touch.locationInNode(self)) {
                _tutorialButton.color = UIColor.blueColor()
                _tutorialButton.colorBlendFactor = 0.3
                firstTouched = "tutorial"
            }
            if CGRectContainsPoint(_creditsButton.frame, touch.locationInNode(self)) {
                _creditsButton.color = UIColor.blueColor()
                _creditsButton.colorBlendFactor = 0.3
                firstTouched = "credits"
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
            if CGRectContainsPoint(_tutorialButton.frame, touch.locationInNode(self)) &&
                firstTouched == "tutorial" {
//                    let transition = SKTransition.fadeWithDuration(1)
                    //                    let scene = TutorialScene(size: self.scene!.size)
//                    self.view?.presentScene(scene, transition: transition)
            }
            if CGRectContainsPoint(_creditsButton.frame, touch.locationInNode(self)) &&
                firstTouched == "credits" {
                    let transition = SKTransition.fadeWithDuration(1)
                    let scene = CreditsScene(size: self.scene!.size)
                    self.view?.presentScene(scene, transition: transition)
            }
        }
        _tutorialButton.colorBlendFactor = 0
        _creditsButton.colorBlendFactor = 0
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        //        println("touch moved")
        //        for touch: AnyObject in touches {
        //            if CGRectContainsPoint(_backButton.frame, touch.locationInNode(self)) &&
        //                firstTouched == "back" {
        //                    _backButton.color = UIColor.redColor()
        //                    _backButton.colorBlendFactor = 1.0
        //            }
        //        }
    }
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
        // not needed
    }
    
    func setOn(sender: SKSpriteNode) {
        if (isSwitchMusic(sender)) {
            _musicSwitchOn.hidden = false
            _musicSwitchOff.hidden = true
            saveSwitchResults("music", switchedTo: !isHidden(_musicSwitchOn))
            
            println("music on")
            if backgroundMusicPlayer == nil {
                playBackgroundMusic("Keep Running.wav")
            } else {
                if !backgroundMusicPlayer.playing {
                    playBackgroundMusic("Keep Running.wav")
                }
            }
        }
        else {
            _soundSwitchOn.hidden = false
            _soundSwitchOff.hidden = true
            saveSwitchResults("sound", switchedTo: !isHidden(_soundSwitchOn))
            println("sound on")
        }
    }
    
    func setOff(sender: SKSpriteNode) {
        if (isSwitchMusic(sender)) {
            _musicSwitchOn.hidden = true
            _musicSwitchOff.hidden = false
            saveSwitchResults("music", switchedTo: !isHidden(_musicSwitchOn))
            
            if backgroundMusicPlayer != nil {
                if backgroundMusicPlayer.playing {
                    backgroundMusicPlayer.stop()
                    setCurrentTrack("none")
                }
            }
            println("music off")
        }
        else {
            _soundSwitchOn.hidden = true
            _soundSwitchOff.hidden = false
            saveSwitchResults("sound", switchedTo: !isHidden(_soundSwitchOn))
            println("sound off")
        }
    }
    
    func isHidden (sender: SKSpriteNode) -> Bool{
        return sender.hidden
    }
    
    func isSwitchMusic(sender: SKSpriteNode) -> Bool {
        return (sender == _musicSwitchOn || sender == _musicSwitchOff)
    }
    
    // Function to save the current state of the for states as default
    func saveSwitchResults(switchName: String, switchedTo: Bool) {
        userDefaults.setValue(switchedTo, forKey: switchName)
        userDefaults.synchronize()
        println("defaults saved")
    }
}
