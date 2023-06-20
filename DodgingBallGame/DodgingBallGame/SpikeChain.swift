//
//  SpikeChain.swift
//  DodgingBallGame
//
//  Created by Karol Orzechowski on 20/06/2023.
//

import Foundation
import SpriteKit

class Spike: SKSpriteNode
{
//    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
//        super.init(texture: texture, color: color, size: <#T##CGSize#>)
//    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    func setup() {
        isUserInteractionEnabled = false
    }
    
}
