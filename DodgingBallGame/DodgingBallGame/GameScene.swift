//
//  GameScene.swift
//  DodgingBallGame
//
//  Created by Karol Orzechowski on 16/06/2023.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, ButtonDelegate {
    
    let label = SKLabelNode(text: "Hello There!")
    let leftButton = Button(texture: nil, color: .magenta, size: CGSize(width: 100, height: 80))
    let bottomPlane = SKLabelNode(text: "Bottom PLane")
    let rightButton = Button(texture: nil, color: .purple, size: CGSize(width: 100, height: 80))
    var timer = DispatchTime.now()
    var jumped = false
    override func update(_ currentTime: TimeInterval) {
        if (leftButton.isPressed)
        {
            moveBall(left: true)
        }
        else if (rightButton.isPressed)
        {
            moveBall(left: false)
        }
        else if (jumped && ((DispatchTime.now().uptimeNanoseconds - timer.uptimeNanoseconds) < 10))
        {
            jumped = false
            //jump
        }
        else if (jumped)
        {
            timer = DispatchTime.now()
            jumped = true
        }
        // collisions -> thats would do nicely
        //collluiison-detetion-in-spritekit stackoverflow
    }
    
    override func didMove(to view: SKView) {
        label.position = CGPoint(x: view.frame.width / 2, y: view.frame.height / 2)
        label.fontSize = 45
        label.fontColor = SKColor.purple
        label.fontName = "Avenir"
        label.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        label.physicsBody!.isDynamic = true
        label.physicsBody!.allowsRotation = true
        bottomPlane.position = CGPoint(x: 0, y: 0)
        bottomPlane.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: frame.width, height: 40), center: CGPoint(x: frame.width/2, y: 0))
        bottomPlane.physicsBody!.isDynamic = false
        leftButton.name = "left"
        leftButton.position = CGPoint(x: 0, y: 100)
        rightButton.position = CGPoint(x: frame.width - 100, y: 100)
        leftButton.delegate = self
        rightButton.delegate = self
        addChild(rightButton)
        addChild(label)
        addChild(leftButton)
        addChild(bottomPlane)
        //let recognizer = UITapGestureRecognizer(target: self, action: #selector(tap))
        //view.addGestureRecognizer(recognizer)
    }

    func buttonClicked(sender: Button) {
        switch sender.name {
        case "left":
            print("moved left")
            //while sender.isPressed {
              //moveBall(left: true)
                //}
            
        case "right":
            print("moved right")
        default:
            print("Unknown button pressed!")
        }
    }
    
    func moveBall(left:Bool=false)
    {
        if(left)
        {
            //label.position = CGPoint(x: label.position.x - 5, y: label.position.y)
            let moveAction = SKAction.move(to: CGPoint(x: label.position.x - 5, y: label.position.y), duration: 0)
            //label.physicsBody!.applyAngularImpulse(0.1)
            label.run(moveAction)
        }
        else {
            label.position = CGPoint(x: label.position.x + 5, y: label.position.y)        }
    }
    
    func jump()
    {
        
    }
}
