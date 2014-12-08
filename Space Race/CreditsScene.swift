//
//  CreditsScene.swift
//  Galactic Space Race
//
//  Created by Max Takano on 12/8/14.
//  Copyright (c) 2014 Max Takano. All rights reserved.
//

import SpriteKit

class CreditsScene: SKScene {
    
    let background = SKSpriteNode(imageNamed: "CreditsPage2")
    let _backButton: SKSpriteNode = SKSpriteNode(imageNamed: "Back")
    
    override func didMoveToView(view: SKView) {
        
        backgroundColor = UIColor.blackColor()
        
        background.size = self.frame.size
        background.position = CGPointMake(self.frame.width * 0.5, self.frame.height * 0.5)
        self.addChild(background)
        
        let BACK_POSITION = CGPoint(x: _backButton.size.width/2, y: self.size.height-(_backButton.size.height)/2.1)
        _backButton.position = BACK_POSITION
        _backButton.setScale(0.8)
        self.addChild(_backButton)
        
        
        let webLabel = SKLabelNode(fontNamed: "Transformers Movie")
        webLabel.text = "CHECK OUT MORE SWEET APPS AT MAXTAKANO.COM"
        webLabel.fontSize = 12
        webLabel.fontColor = SKColor.whiteColor()
        webLabel.position = CGPoint(x: size.width * 0.5, y: size.height * 0.85)
        addChild(webLabel)
        
        // Max's Title
        let maxLabel = SKLabelNode(fontNamed: "Transformers Movie")
        maxLabel.text = "- OVERLORD/(LEAD DEVELOPER)"
        maxLabel.fontSize = 11.5
        maxLabel.fontColor = SKColor.whiteColor()
        maxLabel.position = CGPoint(x: size.width * 0.71, y: size.height * 0.7635)
        addChild(maxLabel)
        
        // Tim's Title
        let timLabel = SKLabelNode(fontNamed: "Transformers Movie")
        timLabel.text = "- LEAD GAME DESIGNER"
        timLabel.fontSize = 11.5
        timLabel.fontColor = SKColor.whiteColor()
        timLabel.position = CGPoint(x: size.width * 0.71, y: size.height * 0.737)
        addChild(timLabel)
        
        // -265
        
        // Jason's Title
        let jasonLabel = SKLabelNode(fontNamed: "Transformers Movie")
        jasonLabel.text = "- LEAD NETWORKING ENGINEER"
        jasonLabel.fontSize = 11.5
        jasonLabel.fontColor = SKColor.whiteColor()
        jasonLabel.position = CGPoint(x: size.width * 0.71, y: size.height * 0.7105)
        addChild(jasonLabel)
        
        // Josh's Title
        let joshLabel = SKLabelNode(fontNamed: "Transformers Movie")
        joshLabel.text = "- EMPEROR PAL-PUN-TINE"
        joshLabel.fontSize = 11
        joshLabel.fontColor = SKColor.whiteColor()
        joshLabel.position = CGPoint(x: size.width * 0.71, y: size.height * 0.6840)
        addChild(joshLabel)
        
        // Brian's Title
        let brianLabel = SKLabelNode(fontNamed: "Transformers Movie")
        brianLabel.text = "- LEAD UI DESIGNER"
        brianLabel.fontSize = 11
        brianLabel.fontColor = SKColor.whiteColor()
        brianLabel.position = CGPoint(x: size.width * 0.71, y: size.height * 0.6575)
        addChild(brianLabel)
        
        // Brandon's Title
        let brandonLabel = SKLabelNode(fontNamed: "Transformers Movie")
        brandonLabel.text = "- LEAD ARTIST"
        brandonLabel.fontSize = 11
        brandonLabel.fontColor = SKColor.whiteColor()
        brandonLabel.position = CGPoint(x: size.width * 0.71, y: size.height * 0.6310)
        addChild(brandonLabel)
        
        
        //        background.anchorPoint = CGPoint(x: 0, y: 0)
        //        background.size = self.size
        //        background.zPosition = -2
        //        self.addChild(background)
        
      
        
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            if CGRectContainsPoint(_backButton.frame, touch.locationInNode(self)) {
                _backButton.color = UIColor.blueColor()
                _backButton.colorBlendFactor = 0.3
            }
        }
    }

    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            
            if CGRectContainsPoint(_backButton.frame, touch.locationInNode(self)) {
                    let transition = SKTransition.fadeWithDuration(1)
                    let scene = OptionsScene(size: self.scene!.size)
                    self.view?.presentScene(scene, transition: transition)
            }
            
        }
    }
    

}

