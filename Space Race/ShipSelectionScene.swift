//
//  ShipSelectionScene.swift
//  Galactic Space Race
//
//  Created by Brian Soe on 12/6/14.
//  Copyright (c) 2014 Max Takano. All rights reserved.
//

import SpriteKit
import GameKit
import UIKit

class ShipSelectionScene: SKScene {
    let background = SKSpriteNode(imageNamed: "backgroundSelection")
    
    // array of button nodes
    let buttons = [SKSpriteNode(imageNamed: "BasicHex"), SKSpriteNode(imageNamed: "BasicHex"),
        SKSpriteNode(imageNamed: "BasicHex"), SKSpriteNode(imageNamed: "BasicHex"),
        SKSpriteNode(imageNamed: "BasicHex"),SKSpriteNode(imageNamed: "BasicHex")]
    
    // array of ship textures
    let textures = ["Ship1", "Ship2", "Ship3", "Ship4", "Ship5", "Ship6"]
    
    // array of ship icon nodes
    let icons = [SKSpriteNode(imageNamed: "Ship1"), SKSpriteNode(imageNamed: "Ship2"),
        SKSpriteNode(imageNamed: "Ship3"), SKSpriteNode(imageNamed: "Ship4"),
        SKSpriteNode(imageNamed: "Ship5"),SKSpriteNode(imageNamed: "Ship6")]
    
    let _back : SKSpriteNode = SKSpriteNode(imageNamed: "Back")
    
    // the "OK" button
    let _confirm : SKSpriteNode = SKSpriteNode(imageNamed: "Confirm")
    
    // ship pointer
    var _currShip : SKSpriteNode = SKSpriteNode(imageNamed: "Ship1")
    
    var shipName = "Ship1"
    
    /* Convert a color hex value to UIColor */
    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    /* Create ship selection button */
    func buildButton(hexagon : SKSpriteNode, icon : SKSpriteNode, point : CGPoint){
        
        // hexagon button background setup
        hexagon.position = point
        hexagon.setScale(1.2)
        hexagon.zPosition = 2
        
        // ship icon setup
        icon.position = point
        icon.setScale(0.37)
        icon.zPosition = 3
        
        // add hexagon and icon to game
        self.addChild(hexagon)
        self.addChild(icon)
    }
    
    override func didMoveToView(view: SKView) {
        
        if currentTrack != "Space Fighter Loop.mp3" {
            playBackgroundMusic("Space Fighter Loop.mp3")
            setCurrentTrack("Space Fighter Loop.mp3")
        }
        
        // pivot for buttons
        let buttonCenter = self.size.width/2
        let buttonTop = self.size.height * 0.4
        let buttonWidth = buttons[0].size.width * 0.8
        let buttonHeight = buttons[0].size.height * 0.8
        
        // setup default for ship pointer
        _currShip.texture = SKTexture(imageNamed: textures[0])
        _currShip.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.7)
        _currShip.setScale(1.3)
        self.addChild(_currShip)
        
        // background image
        background.anchorPoint = CGPoint(x: 0, y: 0)
        background.size = self.size
        background.zPosition = -2
        self.addChild(background)
        
        // setup default for button colors
        for button in buttons {
            button.color = UIColor.blueColor()
            //button.colorBlendFactor = 0.3
//            button.color = UIColorFromRGB(0x5687c8)
        }
        buttons[0].colorBlendFactor = 0.3
        
        // construct build with given location
        buildButton(buttons[0], icon: icons[0], point: CGPoint(x: buttonCenter, y: buttonTop))
        buildButton(buttons[1], icon: icons[1], point: CGPoint(x: buttonCenter-buttonWidth*1.12, y: buttonTop-buttonHeight/1.39))
        buildButton(buttons[2], icon: icons[2], point: CGPoint(x: buttonCenter+buttonWidth*1.12, y: buttonTop-buttonHeight/1.39))
        buildButton(buttons[3], icon: icons[3], point: CGPoint(x: buttonCenter-buttonWidth*1.12, y: buttonTop-buttonHeight/0.46))
        buildButton(buttons[4], icon: icons[4], point: CGPoint(x: buttonCenter+buttonWidth*1.12, y: buttonTop-buttonHeight/0.46))
        buildButton(buttons[5], icon: icons[5], point: CGPoint(x: buttonCenter, y: buttonTop-buttonHeight/0.345))
        
        // back button
        _back.position = CGPoint(x: _back.size.width/2, y: self.size.height-(_back.size.height)/3)
        _back.setScale(0.8)
        addChild(_back)
        
        // OK button
        _confirm.position = CGPoint(x: buttonCenter, y: buttonTop-buttonHeight/0.695)
        _confirm.setScale(1.2)
        _confirm.zPosition = 1
        self.addChild(_confirm)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            var pointer = -1 // pointer use to determine what user chose
            
            if CGRectContainsPoint(icons[0].frame, touch.locationInNode(self)) {
                pointer = 0
            }
            if CGRectContainsPoint(icons[1].frame, touch.locationInNode(self)) {
                pointer = 1
            }
            if CGRectContainsPoint(icons[2].frame, touch.locationInNode(self)) {
                pointer = 2
            }
            if CGRectContainsPoint(icons[3].frame, touch.locationInNode(self)) {
                pointer = 3
            }
            if CGRectContainsPoint(icons[4].frame, touch.locationInNode(self)) {
                pointer = 4
            }
            if CGRectContainsPoint(icons[5].frame, touch.locationInNode(self)) {
                pointer = 5
            }
            if CGRectContainsPoint(_back.frame, touch.locationInNode(self)) {
//                _back.color = UIColor.blackColor()
//                _back.colorBlendFactor = 0.7
                _back.color = UIColor.blueColor()
                _back.colorBlendFactor = 0.3
            }
            if CGRectContainsPoint(_confirm.frame, touch.locationInNode(self)) {
                _confirm.color = UIColor.blueColor()
//                _confirm.color = UIColorFromRGB(0x87A96B)
                _confirm.colorBlendFactor = 0.3
            }
            // if a ship icon has been touched apply color and texture
            if pointer > -1 {
                for button in buttons{
                    button.colorBlendFactor = 0.0
                }
                buttons[pointer].colorBlendFactor = 0.3
                shipName = textures[pointer]
                _currShip.texture = SKTexture(imageNamed: textures[pointer])
            }
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            _confirm.colorBlendFactor = 0.0
            _back.colorBlendFactor = 0.0
            
            // play game when selected ship
            if CGRectContainsPoint(_confirm.frame, touch.locationInNode(self)){
                // singleplayer
                let transition = SKTransition.fadeWithDuration(1)
                let scene = GameScene(size: self.size)
                scene.setShipTexture(shipName) // send ship info to gameplay
                self.view?.presentScene(scene, transition: transition)
             
                // for multi
//                 NSNotificationCenter.defaultCenter().postNotificationName("GoToMultiplayer", object: self)
            }
            
            // go back to menu
            if CGRectContainsPoint(_back.frame, touch.locationInNode(self)){
                let transition = SKTransition.fadeWithDuration(1)
                let scene = MainMenu(size: self.size)
                self.view?.presentScene(scene, transition: transition)
            }
        }
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            var pointer = -1 // pointer use to determine what user chose
            
            if CGRectContainsPoint(icons[0].frame, touch.locationInNode(self)) {
                pointer = 0
            }
            if CGRectContainsPoint(icons[1].frame, touch.locationInNode(self)) {
                pointer = 1
            }
            if CGRectContainsPoint(icons[2].frame, touch.locationInNode(self)) {
                pointer = 2
            }
            if CGRectContainsPoint(icons[3].frame, touch.locationInNode(self)) {
                pointer = 3
            }
            if CGRectContainsPoint(icons[4].frame, touch.locationInNode(self)) {
                pointer = 4
            }
            if CGRectContainsPoint(icons[5].frame, touch.locationInNode(self)) {
                pointer = 5
            }
            // if a ship icon has been touched apply color and texture
            if pointer > -1 {
                for button in buttons{
                    button.colorBlendFactor = 0.0
                }
                buttons[pointer].colorBlendFactor = 0.3
                shipName = textures[pointer]
                _currShip.texture = SKTexture(imageNamed: textures[pointer])
            }
        }
    }
    
}
