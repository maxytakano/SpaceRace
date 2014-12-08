//
//  Buttons.swift
//  Space Race
//
//  Created by Max Takano on 12/4/14.
//  Copyright (c) 2014 Max Takano. All rights reserved.
//

import SpriteKit

func boostButtonNode() -> SKSpriteNode {
    let texture = SKTexture(imageNamed: "basicRock")
    let boostNode = SKSpriteNode(texture: texture,
        color: UIColor.whiteColor(),
        size: texture.size())
    boostNode.setScale(2.0)
    boostNode.position = CGPoint(x: viewSize.width * 0.8, y: viewSize.height * 0.1)
    boostNode.name = "boostButtonNode"
    boostNode.zPosition = GameLayer.Interface
    return boostNode
}

// Brake button
func brakeButtonNode() -> SKSpriteNode {
    let texture = SKTexture(imageNamed: "basicRock")
    let brakeNode = SKSpriteNode(texture: texture,
        color: UIColor.whiteColor(),
        size: texture.size())
    brakeNode.setScale(2.0)
    brakeNode.position = CGPoint(x: viewSize.width * 0.2, y: viewSize.height * 0.1)
    brakeNode.name = "brakeButtonNode"
    brakeNode.zPosition = GameLayer.Interface
    return brakeNode
}

