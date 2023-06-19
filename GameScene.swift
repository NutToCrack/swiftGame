//
//  GameScene.swift
//  DodgingBallGame
//
//  Created by Karol Orzechowski on 16/06/2023.
//

import SpriteKit
import GameplayKit



class GameScene: SKScene, ButtonDelegate, SKPhysicsContactDelegate {
    
    let ballCategory: UInt32 = 0x1 << 0
    let wallCategory: UInt32 = 0x1 << 1
    let spikeCategory: UInt32 = 0x1 << 2
    let ball = SKSpriteNode(imageNamed: "Volleyball")
   
    let leftButton = Button(texture: nil, color: .magenta, size: CGSize(width: 100, height: 80))
    let bottomPlane = SKShapeNode(rectOf: CGSize(width: 1000, height: 10))
    let spike = SKShapeNode(rectOf: CGSize(width: 50, height: 50))
    let rightButton = Button(texture: nil, color: .purple, size: CGSize(width: 100, height: 80))
    let jumpButton = Button(texture: nil, color: .green, size: CGSize(width: 100, height: 80))
    var timer = DispatchTime.now()
    var resultTimer = DispatchTime.now()
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
        //collluiison-detetion-in-spritekit stackoverflow
    }
    
    func didBegin(_ contact: SKPhysicsContact)
    {
        if (contact.bodyA.node?.physicsBody?.collisionBitMask == spikeCategory &&
            contact.bodyB.node?.physicsBody?.collisionBitMask == ballCategory)
        {
            print ("Hit!")
            // restart game here
        }
    }
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        ball.name = "ball"
        ball.position = CGPoint(x: view.frame.width / 2, y: view.frame.height / 2)
        ball.physicsBody = SKPhysicsBody(circleOfRadius: 25)
        ball.physicsBody!.isDynamic = true
        ball.physicsBody!.allowsRotation = true
        ball.physicsBody!.restitution = 0.4
        ball.physicsBody!.collisionBitMask = ballCategory
        ball.physicsBody!.contactTestBitMask = UInt32(7)
        bottomPlane.position = CGPoint(x: 0, y: 100)
        bottomPlane.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: frame.width, height: 1), center: CGPoint(x: frame.width/2, y: 5))
        bottomPlane.physicsBody!.isDynamic = false
        bottomPlane.fillColor = SKColor.red
        bottomPlane.physicsBody!.collisionBitMask = wallCategory
        bottomPlane.physicsBody!.contactTestBitMask = UInt32(7)
        leftButton.name = "left"
        jumpButton.name = "jump"
        leftButton.position = CGPoint(x: 0, y: 10)
        rightButton.position = CGPoint(x: frame.width - 100, y: 10)
        jumpButton.position = CGPoint(x: frame.width / 2, y: 10)
        leftButton.delegate = self
        rightButton.delegate = self
        jumpButton.delegate = self
        spike.position = CGPoint(x: frame.width/2, y: frame.height * 0.8)
        spike.fillColor = SKColor.red
        spike.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: 50))
        spike.physicsBody!.isDynamic = false
        ball.size = CGSize(width: 50, height: 50)
        spike.name = "spike"
        spike.physicsBody!.collisionBitMask = spikeCategory
        spike.physicsBody!.contactTestBitMask = UInt32(7)
        addChild(rightButton)
        addChild(ball)
        addChild(leftButton)
        addChild(bottomPlane)
        addChild(jumpButton)
        addChild(spike)
    }

    func buttonClicked(sender: Button) {
        if (jumped && (Double(DispatchTime.now().uptimeNanoseconds - timer.uptimeNanoseconds) / 1_000_000_000 < 0.5) && sender.name == "jump")
        {
            jumped = false
            jump()
            timer = DispatchTime.now()
        }
        else if (sender.name == "jump" && (Double(DispatchTime.now().uptimeNanoseconds - timer.uptimeNanoseconds) / 1_000_000_000 > 1.0))
        {
            jumped = true
            jump()
            timer = DispatchTime.now()
        }
            
    }
    
    func moveBall(left:Bool=false)
    {
        if(left)
        {
            ball.position = CGPoint(x: ball.position.x - 5, y: ball.position.y)
            ball.zRotation = ball.zRotation + 0.2
        }
        else {
            ball.position = CGPoint(x: ball.position.x + 5, y: ball.position.y)
            ball.zRotation = ball.zRotation - 0.2
        }
    }
    
    func jump()
    {
        ball.physicsBody!.applyImpulse(CGVector(dx: 0, dy: 40))
    }
}
