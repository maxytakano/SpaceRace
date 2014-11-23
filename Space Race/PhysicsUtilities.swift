//
//  PhysicsUtilities.swift
//  spritekitTest190
//
//  Created by Max Takano on 10/15/14.
//  Copyright (c) 2014 Max Takano. All rights reserved.
//

import Foundation
import SpriteKit

// Operator overloads
func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

// length and normalize
extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}

//sqrt
#if !(arch(x86_64) || arch(arm64))
    func sqrt(a: CGFloat) -> CGFloat {
        return CGFloat(sqrtf(Float(a)))
    }
#endif


// Random functions
func getRandom() -> CGFloat {
    return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
}

func getRandom(#min: CGFloat, max: CGFloat) -> CGFloat {
    return getRandom() * (max - min) + min
}



