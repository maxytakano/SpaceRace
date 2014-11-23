//
//  GameTextures.swift
//  Space Race
//
//  Created by Max Takano on 11/13/14.
//  Copyright (c) 2014 Max Takano. All rights reserved.
//

import SpriteKit

let GameTexturesSharedInstance = GameTextures()

class GameTextures {
    class var sharedInstance:GameTextures {
        return GameTexturesSharedInstance
    }
    
    var textureAtlas = SKTextureAtlas()
    
    init() {
        textureAtlas = SKTextureAtlas(named: "artwork")
    }
}
