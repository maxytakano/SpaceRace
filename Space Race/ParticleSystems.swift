//
//  ParticleSystem.swift
//  spritekitTest190
//
//  Created by Max Takano on 10/15/14.
//  Copyright (c) 2014 Max Takano. All rights reserved.
//

import Foundation
import SpriteKit

// Probably will want to pass in the image type of wanted particle
func newExplosion() -> SKEmitterNode {
    let explosion = SKEmitterNode()
    
    //explosion.particleTexture =
    explosion.particleTexture = SKTexture(imageNamed: "Kakuna")
    explosion.particleColor = UIColor.redColor()
    explosion.numParticlesToEmit = 100
    explosion.particleBirthRate = 450
    explosion.particleLifetime = 2
    explosion.emissionAngleRange = 360
    explosion.particleSpeed = 100
    explosion.particleSpeedRange = 50
    explosion.xAcceleration = 0
    explosion.yAcceleration = 0
    explosion.particleAlpha = 1.0
    explosion.particleAlphaRange = 0.0
    explosion.particleAlphaSpeed = 0.0
    explosion.particleScale = 0.75
    explosion.particleScaleRange = 0.4
    explosion.particleScaleSpeed = -0.5
    explosion.particleRotation = 0
    explosion.particleRotationRange = 0
    explosion.particleRotationSpeed = 0
    
    explosion.particleColorBlendFactor = 0.0
    explosion.particleColorBlendFactorRange = 0
    explosion.particleColorBlendFactorSpeed = 0
    explosion.particleBlendMode = SKBlendMode.Add
    
    return explosion
}

func newRockSplat() -> SKEmitterNode {
    let rockSplat = SKEmitterNode()
    
    rockSplat.particleTexture = SKTexture(imageNamed: "basicRock")
    //rockSplat.particleColor = UIColor.redColor()
    rockSplat.numParticlesToEmit = 20
    rockSplat.particleBirthRate = 600
    rockSplat.particleLifetime = 0.7
    rockSplat.emissionAngle = 1.57
    rockSplat.emissionAngleRange = 3.14
    rockSplat.particleSpeed = 80
    rockSplat.particleSpeedRange = 20
    rockSplat.xAcceleration = 0
    rockSplat.yAcceleration = -400.0
    rockSplat.particleAlpha = 1.0
    //rockSplat.particleAlphaRange = 0.0
    //rockSplat.particleAlphaSpeed = 0.0
    rockSplat.particleScale = 0.6
    rockSplat.particleScaleRange = 0.3
    rockSplat.particleScaleSpeed = -0.5
    rockSplat.particleRotation = 0
    rockSplat.particleRotationRange = 0
    rockSplat.particleRotationSpeed = 2.0
    
    //rockSplat.particleColorBlendFactor = 0.0
    //rockSplat.particleColorBlendFactorRange = 0
    //rockSplat.particleColorBlendFactorSpeed = 0
    //rockSplat.particleBlendMode = SKBlendMode.Add
    
    return rockSplat
}

func newFirework(fireworkColor: UIColor) -> SKEmitterNode {
    let firework = SKEmitterNode()
    
    //explosion.particleTexture =
    firework.particleTexture = SKTexture(imageNamed: "basicRock")
    firework.particleColor = fireworkColor
    firework.numParticlesToEmit = 100
    firework.particleBirthRate = 350
    firework.particleLifetime = 2
    firework.emissionAngleRange = 360
    firework.particleSpeed = 100
    firework.particleSpeedRange = 50
    firework.xAcceleration = 0
    firework.yAcceleration = 0
    firework.particleAlpha = 1.0
    firework.particleAlphaRange = 0.0
    firework.particleAlphaSpeed = 0.0
    firework.particleScale = 0.75
    firework.particleScaleRange = 0.4
    firework.particleScaleSpeed = -0.5
    firework.particleRotation = 0
    firework.particleRotationRange = 0
    firework.particleRotationSpeed = 0
    
    firework.particleColorBlendFactor = 1.0
    firework.particleColorBlendFactorRange = 0
    firework.particleColorBlendFactorSpeed = 0
    firework.particleBlendMode = SKBlendMode.Add
    
    return firework
}