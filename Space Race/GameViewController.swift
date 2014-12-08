//
//  GameViewController.swift
//  Space Race
//
//  Created by Max Takano on 11/6/14.
//  Copyright (c) 2014 Max Takano. All rights reserved.
//

import UIKit
import SpriteKit
import GameKit

var myLeaderboardIdentifier = ""

class GameViewController: UIViewController, GKGameCenterControllerDelegate {
//    class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // auth player
        self.authenticatePlayer()
        
        // Configure the view.
        let scene = MainMenu(size: view.bounds.size)
        let skView = self.view as SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        // new
        skView.showsDrawCount = true
        //skView.showsPhysics = true
            
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
    
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .AspectFill
        //scene.scaleMode = .ResizeFill
        
        skView.presentScene(scene)
    }
    
    override func awakeFromNib() {
        // go to multiplayer
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "goToMultiplayer", name: "GoToMultiplayer", object: nil)
        
        // nib for switching into authing leaderboard
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "authenticatePlayer", name: "GoToLeaderboard", object: nil)
    }
    
    /**********************************************************************/
    let auth_name = "present_authentication_view_controller"
    let localplayer = "local_player_authenticated"
    /**********************************************************************/
    
    var gameCenterEnabled = false
    var localPlayer = GKLocalPlayer.localPlayer()

    func authenticatePlayer() {
        
        localPlayer.authenticateHandler = {(viewController , error  ) -> Void in
            
            //handle authentication
            if (viewController != nil) {
                self.presentViewController(viewController, animated: true, completion: nil)
            } else {
                if(self.localPlayer.authenticated) {
                    self.gameCenterEnabled = true
                    
                    println("Authentication Success")
                    self.localPlayer.loadDefaultLeaderboardIdentifierWithCompletionHandler( {(leaderboardIdentifier : String!, error : NSError!) -> Void in
                        if (error != nil) {
                            print(error.localizedDescription)
                        } else {
                            myLeaderboardIdentifier = leaderboardIdentifier
                        }
                        
                    })
                } else {
                    println("Authentication Failure")
                    self.gameCenterEnabled = false
                }
                
            }
        }
    }
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController!)
    {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func goToMultiplayer() {
        println("going to multiplayer")
        
        if(localPlayer.authenticated) {
            playerAuthenticated()
        } else {
            println("trying to auth again")
            
            // Display the "must log in message"
            var alert: UIAlertView = UIAlertView()
            alert.title = "Multiplayer requires that you are logged into Game Center. Please open the Game Center app and login."
            alert.addButtonWithTitle("OK")
            alert.show()
            
            
            // NOTE: reauthentication does not work, login once at start instead
//            NSNotificationCenter.defaultCenter().addObserver(self, selector: "showAuthenticationViewController", name: auth_name, object: nil)
//            
//            /* Check if user is logged in */
//            GameKitHelper.SharedGameKitHelper.reAuthenticateLocalPlayer()
//            
//            /* If authemticated, find match */
//            NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerAuthenticated", name: localplayer, object: nil)

        }
    }
    
    func showAuthenticationViewController() {
        let gameKitHelper = GameKitHelper.SharedGameKitHelper
        self.presentViewController(gameKitHelper.authenticationViewController!, animated: true, completion: nil)
    }
    
    func playerAuthenticated() {
        println("authed")
    
        // Prepare the multiplayer scene
        let gameScene = MultiplayerStaging(size: self.view.bounds.size)
        
        // Connect the scene to the networking engine
        let networkingEngine = MultiplayerNetworking()
        networkingEngine.delegate = gameScene
        gameScene.networkingEngine = networkingEngine
        GameKitHelper.SharedGameKitHelper.findMatchWithMinPlayers(2, maxPlayers: 2, viewController: self, delegate: networkingEngine)
        
        println("Player authenticated, presenting multiplayer scene.")
        
        let myView = self.view as SKView
        myView.presentScene(gameScene)
    }
    
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.All.rawValue)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
