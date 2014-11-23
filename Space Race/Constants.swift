//
//  Constants.swift
//  Space Race
//
//  Created by Max Takano on 11/13/14.
//  Copyright (c) 2014 Max Takano. All rights reserved.
//

import CoreGraphics

let kDebug:Bool = true
var kFontName = "Silom-Bold"
var viewSize:CGSize!

// MARK: Game Layers
class GameLayer {
    class var Background:CGFloat    { return 0 }
    class var Stars:CGFloat         { return 1 }
    class var Game:CGFloat          { return 2 }
    class var Effects:CGFloat       { return 3 }
    class var Interface:CGFloat     { return 4 }
}

// MARK: Contact Categories
class Contact {
    class var Ship:UInt32               { return 1 << 0 }
    class var Star:UInt32               { return 1 << 1 }
    class var Asteroid:UInt32           { return 1 << 2 }
    class var Frame:UInt32              { return 1 << 2 }
}