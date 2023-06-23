//
//  GameScene.swift
//  DodgingBallGame
//
//  Created by Karol Orzechowski on 16/06/2023.
//

import SpriteKit
import GameplayKit
 
enum GameError: Error {
    case runtimeError(String)
}

class GameScene: SKScene, ButtonDelegate, SKPhysicsContactDelegate {
    let curves = ["line", "cosinus"]
    var newCurve = true
    let ballCategory: UInt32 = 0x1 << 0
    let wallCategory: UInt32 = 0x1 << 1
    let spikeCategory: UInt32 = 0x1 << 2
    let ball = SKSpriteNode(imageNamed: "Volleyball")
    var spikes: [SKShapeNode] = []
    var speedFactor = 1.0
    var sequenceFinished = false
    var direction = ""
    var curve = ""
   
    let leftButton = Button(texture: nil, color: .magenta, size: CGSize(width: 100, height: 80))
    let bottomPlane = SKShapeNode(rectOf: CGSize(width: 1000, height: 10))
    let spike = SKShapeNode(rectOf: CGSize(width: 10, height: 10))
    let rightButton = Button(texture: nil, color: .purple, size: CGSize(width: 100, height: 80))
    let jumpButton = Button(texture: nil, color: .green, size: CGSize(width: 100, height: 80))
    var timer = DispatchTime.now()
    var resultTimer = DispatchTime.now()
    var result = 0.0
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
        do {
            try moveSpikes()
        } catch let error {
            print(error)
        }
        
    }
    
    func didBegin(_ contact: SKPhysicsContact)
    {
        if (contact.bodyA.node?.physicsBody?.collisionBitMask == spikeCategory &&
            contact.bodyB.node?.physicsBody?.collisionBitMask == ballCategory)
        {
            result = Double(DispatchTime.now().uptimeNanoseconds / 1_000_000_000) - Double(resultTimer.uptimeNanoseconds) / 1_000_000_000
            print ("Hit!")
            print(Int(result.rounded()))
            // restart game here
        }
    }
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        let constraintX = SKConstraint.positionX(SKRange.init(lowerLimit: frame.minX, upperLimit: frame.maxX))
        let constraintY = SKConstraint.positionY(SKRange.init(lowerLimit: frame.minY, upperLimit: frame.maxY))
        ball.constraints = [constraintX, constraintY]
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
        spike.position = CGPoint(x: 0, y: frame.height * 0.8)
        spike.fillColor = SKColor.red
        spike.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 10, height: 10))
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
    
    func moveSpikes() throws
    {
        // move current curve
        // choose curve
        // random direction
        // spawn curve
        // after finished increase speed
        
        switch direction {
        case "left":
            moveSpikesLeft()
        case "right":
            moveSpikesRight()
        case "up":
            moveSpikesUp()
        case "down":
            moveSpikesDown()
        default:
            break
        }
        checkCurve()
        if (newCurve)
        {
            curve = curves.randomElement()!
            chooseDirection(curve)
            switch curve
            {
            case "line":
               try generateLine()
            case "cosinus":
                generateCosinius()
            case "angledLine":
                {}()
            default:
                throw GameError.runtimeError("Unknow curve chosen!")
            }
            speedFactor = speedFactor + 0.1
            print(direction)
            print(curve)
        }
    }
    func moveSpikesLeft() {
        for spike in spikes {
            spike.position.x = spike.position.x - speedFactor
        }
    }
    
    func moveSpikesRight()
    {
        for spike in spikes {
            spike.position.x = spike.position.x + speedFactor
        }
    }
    
    func moveSpikesUp()
    {
        for spike in spikes {
            spike.position.y = spike.position.y + speedFactor
        }
    }
    
    func moveSpikesDown()
    {
        for spike in spikes {
            spike.position.y = spike.position.y - speedFactor
        }
    }
    func cleanUpSpikes()
    {
        removeChildren(in: spikes)
        spikes.removeAll()
    }
    func generateCosinius() {
        cleanUpSpikes()
        spike.position = direction == "right" ?  CGPoint(x:frame.minX - 1500, y: frame.minY + frame.height / 2) :
        CGPoint(x:frame.maxX + 100, y: frame.minY + frame.height / 2)
        for i in 0...150
        {
            let newSpike: SKShapeNode = spike.copy() as! SKShapeNode
            newSpike.position = CGPoint(x: spike.position.x + CGFloat(i * 10) , y: 50 * cos(0.02 * ( spike.position.x + CGFloat(i * 10))) + 100)
            spikes.append(newSpike)
        }
        for spike in spikes {
            addChild(spike)
        }
    }
    
    func generateAngledLine() {
        cleanUpSpikes()
        spike.position = CGPoint(x:frame.minX - frame.width, y: frame.minY + frame.height / 2)
        for i in 0...300
        {
            let newSpike: SKShapeNode = spike.copy() as! SKShapeNode
            newSpike.position = CGPoint(x: spike.position.x + CGFloat(i * 10) , y: spike.position.y - CGFloat(i * 10))
            spikes.append(newSpike)
        }
        for spike in spikes {
            addChild(spike)
        }
    }
    
    func generateLine() throws {
        // change number of squares
        cleanUpSpikes()
        switch direction {
        case "left":
            spike.position = CGPoint(x: frame.maxX + 1, y: frame.maxY - CGFloat(5) )
            spikes.append(spike)
            for i in 0...40 {
                let newSpike: SKShapeNode = spike.copy() as! SKShapeNode
                newSpike.position = CGPoint(x: spike.position.x, y: spike.position.y - CGFloat(i * 10))
                spikes.append(newSpike)
            }
        case "right":
            spike.position = CGPoint(x: frame.minX - 1, y: frame.maxY - CGFloat(5) )
            spikes.append(spike)
            for i in 0...40 {
                let newSpike: SKShapeNode = spike.copy() as! SKShapeNode
                newSpike.position = CGPoint(x: spike.position.x, y: spike.position.y - CGFloat(i * 10))
                spikes.append(newSpike)
            }
        case "up":
            spike.position = CGPoint(x: frame.minX - 1, y: frame.minY + 50 )
            spikes.append(spike)
            for i in 0...40 {
                let newSpike: SKShapeNode = spike.copy() as! SKShapeNode
                newSpike.position = CGPoint(x: spike.position.x + CGFloat(i * 10), y: spike.position.y)
                spikes.append(newSpike)
            }
        case "down":
            spike.position = CGPoint(x: frame.minX - 1, y: frame.maxY + 1 )
            spikes.append(spike)
            for i in 0...40 {
                let newSpike: SKShapeNode = spike.copy() as! SKShapeNode
                newSpike.position = CGPoint(x: spike.position.x + CGFloat(i * 10), y: spike.position.y)
                spikes.append(newSpike)
            }
        default:
            throw GameError.runtimeError("Invalid direction!")
        }
        let holeBeginIndex = Int.random(in: 10...30)
        for element in spikes.enumerated()
        {
            if (element.offset >= holeBeginIndex && element.offset <= holeBeginIndex + 10)
            {
              continue
            }
            addChild(element.element)
        }
    }
    func checkCurve(){
        newCurve = {
            switch direction {
            case "up":
                return spikes.allSatisfy({$0.position.y > frame.maxY + 1})
            case "down":
                return spikes.allSatisfy({$0.position.y < frame.minY + 50})
            case "left":
                return spikes.allSatisfy({$0.position.x < frame.minX - 1})
            case "right":
                return spikes.allSatisfy({$0.position.x > frame.maxX + 1})
            default:
                return true
            }
        }()
    }
    func chooseDirection(_ curve:String) {
        if (curve == "cosinus")
        {
            direction = ["left", "right"].randomElement()!
        }
        else {
            direction = ["left", "right", "up", "down"].randomElement()!
        }
    }
}
