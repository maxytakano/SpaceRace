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

class ScoresScene: SKScene, GKGameCenterControllerDelegate {
    
    override func didMoveToView(view: SKView) {
        showLeaderboard()
    }
    
    func showLeaderboard() {
        var gcViewController = GKGameCenterViewController()
        gcViewController.gameCenterDelegate = self
        
        gcViewController.viewState = GKGameCenterViewControllerState.Leaderboards
        println(myLeaderboardIdentifier)
        gcViewController.leaderboardIdentifier = myLeaderboardIdentifier
        
        var vc = self.view?.window?.rootViewController
        vc?.presentViewController(gcViewController, animated: true, completion: nil)
        
    }
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController!) {
        
        var vc = self.view?.window?.rootViewController
        vc?.dismissViewControllerAnimated(true, completion: nil)
        
        
        let transition = SKTransition.fadeWithDuration(1)
        let scene = MainMenu(size: self.scene!.size)
        self.view?.presentScene(scene, transition: transition)
        
        
    }
    
}


