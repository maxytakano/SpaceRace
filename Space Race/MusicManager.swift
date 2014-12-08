//
//  MusicManager.swift
//  Galactic Space Race
//
//  Created by Max Takano on 12/8/14.
//  Copyright (c) 2014 Max Takano. All rights reserved.
//

import Foundation
import AVFoundation

var backgroundMusicPlayer: AVAudioPlayer!
var currentTrack = "none"

func playBackgroundMusic(filename: String) {
    let url = NSBundle.mainBundle().URLForResource(
        filename, withExtension: nil)
    if (url == nil) {
        println("Could not find file: \(filename)")
        return
    }
    
    var error: NSError? = nil
    backgroundMusicPlayer =
        AVAudioPlayer(contentsOfURL: url, error: &error)
    if backgroundMusicPlayer == nil {
        println("Could not create audio player: \(error!)")
        return
    }
    
    backgroundMusicPlayer.numberOfLoops = -1
    backgroundMusicPlayer.prepareToPlay()
    //backgroundMusicPlayer.volume = 0
    backgroundMusicPlayer.play()
}

func setCurrentTrack(trackName:String) {
    currentTrack = trackName
}