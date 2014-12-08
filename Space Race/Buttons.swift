//
//  Buttons.swift
//  Space Race
//
//  Created by Max Takano on 12/4/14.
//  Copyright (c) 2014 Max Takano. All rights reserved.
//

import SpriteKit

func boostButtonNode() -> SKSpriteNode {
    let texture = SKTexture(imageNamed: "Boost4")
    let boostNode = SKSpriteNode(texture: texture,
        color: UIColor.whiteColor(),
        size: texture.size())
    boostNode.setScale(1.0)
    boostNode.anchorPoint = CGPointMake(1.0, 0.0)
    boostNode.position = CGPoint(x: viewSize.width * 1.0, y: viewSize.height * 0.0)
//    boostNode.position = CGPoint(x: viewSize.width * 0.85, y: viewSize.height * 0.07)
    
    boostNode.name = "boostButtonNode"
    boostNode.zPosition = GameLayer.Interface
    return boostNode
}

// Brake button
func brakeButtonNode() -> SKSpriteNode {
    let texture = SKTexture(imageNamed: "Brake3")
    let brakeNode = SKSpriteNode(texture: texture,
        color: UIColor.whiteColor(),
        size: texture.size())
    brakeNode.setScale(1.0)
    brakeNode.anchorPoint = CGPointMake(0.0, 0.0)
//    brakeNode.position = CGPoint(x: viewSize.width * 0.15, y: viewSize.height * 0.07)
    brakeNode.position = CGPoint(x: viewSize.width * 0.0, y: viewSize.height * 0.0)
    brakeNode.name = "brakeButtonNode"
    brakeNode.zPosition = GameLayer.Interface
    return brakeNode
}

