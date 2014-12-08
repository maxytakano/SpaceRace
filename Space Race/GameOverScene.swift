//
//  GameOverScreen.swift
//  spritekitTest190
//
//  Created by Max Takano on 10/14/14.
//  Copyright (c) 2014 Max Takano. All rights reserved.
//

import Foundation
import SpriteKit
import GameKit

class GameOverScene: SKScene {
    
    let background = SKSpriteNode(imageNamed: "gameOver1.png")
    let _againButton: SKSpriteNode = SKSpriteNode(imageNamed: "retry")
    let _menuButton: SKSpriteNode = SKSpriteNode(imageNamed: "menu.png")
    
    // init score report
    var score:Int64 = 0
    var shipName:String = "Ship1"
    
    
    init(size: CGSize, won:Bool, seconds:Int, minutes:Int, shipTexture:String) {
        super.init(size: size)
        
        shipName = shipTexture
        // init background
        background.anchorPoint = CGPoint(x: 0, y: 0)
        background.size = self.size
        background.zPosition = -2
        self.addChild(background)
        
        // Again button
        _againButton.position = CGPoint(x: self.size.width * 0.74 , y: self.size.height * 0.15)
        _againButton.setScale(1.4)
        self.addChild(_againButton)
        
        // Menu button
        _menuButton.position = CGPoint(x: self.size.width * 0.26 , y: self.size.height * 0.15)
        _menuButton.setScale(1.4)
        self.addChild(_menuButton)
    
        
        let winlabel = SKLabelNode(fontNamed: "Transformers Movie")
        winlabel.text = "GAME OVER"
        winlabel.fontSize = 45
        winlabel.fontColor = SKColor.whiteColor()
        winlabel.position = CGPoint(x: size.width * 0.5, y: size.height * 0.87)
        addChild(winlabel)
        
        if won {
            let scoreLabel = SKLabelNode(fontNamed: "Transformers Movie")
            scoreLabel.text = "NEW RECORD!"
            scoreLabel.fontSize = 40
            scoreLabel.fontColor = SKColor.whiteColor()
            scoreLabel.position = CGPoint(x: size.width * 0.5, y: size.height * 0.73)
            addChild(scoreLabel)
        } else {
            let scoreLabel = SKLabelNode(fontNamed: "Transformers Movie")
            scoreLabel.text = "TIME LASTED"
            scoreLabel.fontSize = 40
            scoreLabel.fontColor = SKColor.whiteColor()
            scoreLabel.position = CGPoint(x: size.width * 0.5, y: size.height * 0.73)
            addChild(scoreLabel)
        }
        
        let timeLabel = SKLabelNode(fontNamed: "Transformers Movie")
        timeLabel.text = "\(minutes/60)M : \(seconds)S"
        timeLabel.fontSize = 40
        timeLabel.fontColor = SKColor.whiteColor()
        timeLabel.position = CGPoint(x: size.width * 0.5, y: size.height * 0.63)
        addChild(timeLabel)
        
        
        if (won) {
            let bestLabel = SKLabelNode(fontNamed: "Transformers Movie")
            bestLabel.text = "PREVIOUS BEST"
            bestLabel.fontSize = 40
            bestLabel.fontColor = SKColor.whiteColor()
            bestLabel.position = CGPoint(x: size.width * 0.5, y: size.height * 0.47)
            addChild(bestLabel)
        } else {
            let bestLabel = SKLabelNode(fontNamed: "Transformers Movie")
            bestLabel.text = "BEST TIME"
            bestLabel.fontSize = 40
            bestLabel.fontColor = SKColor.whiteColor()
            bestLabel.position = CGPoint(x: size.width * 0.5, y: size.height * 0.47)
            addChild(bestLabel)
        }
        
        
        var currentHighScore = NSUserDefaults.standardUserDefaults().objectForKey("HighScore") as NSArray
        
        let highScoreLabel = SKLabelNode(fontNamed: "Transformers Movie")
        highScoreLabel.text = "\(currentHighScore[0])m:\(currentHighScore[1])s"
        highScoreLabel.fontSize = 40
        highScoreLabel.fontColor = SKColor.whiteColor()
        highScoreLabel.position = CGPoint(x: size.width * 0.5, y: size.height * 0.37)
        addChild(highScoreLabel)
        
        // set the score to be sent to game center
        score = Int64(minutes)
        
        // send the score to game center
        reportScore()
    }
    
    func reportScore () {
        var score = GKScore(leaderboardIdentifier: myLeaderboardIdentifier)
        score.value = self.score
        
        GKScore.reportScores([score], withCompletionHandler: {(error : NSError!) -> Void in
            if (error != nil) {
                print(error.localizedDescription)
            } else {
                println("success")
            }
        })
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            if CGRectContainsPoint(_againButton.frame, touch.locationInNode(self)) {
                _againButton.color = UIColor.redColor()
                _againButton.colorBlendFactor = 1.0
            }
            if CGRectContainsPoint(_menuButton.frame, touch.locationInNode(self)) {
                _menuButton.color = UIColor.redColor()
                _menuButton.colorBlendFactor = 1.0
            }
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            if CGRectContainsPoint(_againButton.frame, touch.locationInNode(self))  {
                let transition = SKTransition.fadeWithDuration(1)
                let scene = GameScene(size: self.scene!.size)
                scene.setShipTexture(shipName)
                self.view?.presentScene(scene, transition: transition)
            }
            if CGRectContainsPoint(_menuButton.frame, touch.locationInNode(self)) {
                let transition = SKTransition.fadeWithDuration(1)
                let scene = MainMenu(size: self.scene!.size)
                self.view?.presentScene(scene, transition: transition)
            }
        }
        _againButton.colorBlendFactor = 0.0
        _menuButton.colorBlendFactor = 0.0
    }
    
    /*override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
    
    }
    
    
    override func touchesCancelled(touches: NSSet, withEvent event: UIEvent) {
    
    }*/
    
    // 6
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}