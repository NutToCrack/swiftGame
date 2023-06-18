//
//  Button.swift
//  DodgingBallGame
//
//  Created by Karol Orzechowski on 18/06/2023.
//

import Foundation

import SpriteKit

protocol ButtonDelegate: class {
    func buttonClicked(sender: Button)
}

class Button: SKSpriteNode
{
    weak var delegate: ButtonDelegate!
    var isPressed = false
        override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    func setup() {
        isUserInteractionEnabled = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        setScale(0.9)
        isPressed = true
        self.delegate.buttonClicked(sender: self)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isPressed = false
        setScale(1.0)
    }
    
    
}
