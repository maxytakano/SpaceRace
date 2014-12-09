//
//  TutorialScene.swift
//  Galactic Space Race
//
//  Created by Max Takano on 12/8/14.
//  Copyright (c) 2014 Max Takano. All rights reserved.
//

import SpriteKit

class TutorialScene: SKScene {
    
    let background = SKSpriteNode(imageNamed: "TutorialScreen")
    let _backButton: SKSpriteNode = SKSpriteNode(imageNamed: "Back")
    
    override func didMoveToView(view: SKView) {
        
        backgroundColor = UIColor.blackColor()
        
        background.size = self.frame.size
        background.position = CGPointMake(self.frame.width * 0.5, self.frame.height * 0.5)
        self.addChild(background)
        
        let BACK_POSITION = CGPoint(x: _backButton.size.width/2, y: self.size.height-(_backButton.size.height)/2.1)
        _backButton.position = BACK_POSITION
        _backButton.setScale(0.8)
        _backButton.zPosition = 10
        self.addChild(_backButton)
        
        
        
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

