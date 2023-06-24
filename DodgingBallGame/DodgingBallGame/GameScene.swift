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
    let curves = ["line", "cosinus", "square"]
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
   
    let leftButton = Button(texture: SKTexture(imageNamed: "arrow"), color: .magenta, size: CGSize(width: 80, height: 80))
    let bottomPlane = SKShapeNode(rectOf: CGSize(width: 1000, height: 10))
    let spike = SKShapeNode(rectOf: CGSize(width: 10, height: 10))
    let rightButton = Button(texture: SKTexture(imageNamed: "arrow"), color: .purple, size: CGSize(width: 80, height: 80))
    let jumpButton = Button(texture: SKTexture(imageNamed: "arrow"), color: .green, size: CGSize(width: 80, height: 80))
    var timer = DispatchTime.now()
    var resultTimer = DispatchTime.now()
    var result = 0.0
    var jumped = false
    
    override func update(_ currentTime: TimeInterval) {
        if (leftButton.isPressed)
        {
            moveBallLeft()
        }
        else if (rightButton.isPressed)
        {
            moveBallRight()
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
            endGame()
        }
    }
    
    private func endGame() {
        let transision = SKTransition.fade(with: .purple, duration: 5)
        let endGame = GameOverScene(size: (view?.frame.size)!)
        endGame.result = Int(result)
        self.view?.presentScene(endGame, transition: transision)
    }
    
   private func buttonsSetUp()
    {
        leftButton.name = "left"
        jumpButton.name = "jump"
        rightButton.name = "right"
        leftButton.position = CGPoint(x: 50, y: 40)
        leftButton.zRotation = CGFloat(Double.pi / 2)
        rightButton.position = CGPoint(x: frame.width - 50, y: 40)
        rightButton.zRotation = CGFloat(Double.pi * 3/2)
        jumpButton.position = CGPoint(x: frame.width / 2, y: 40)
        leftButton.delegate = self
        rightButton.delegate = self
        jumpButton.delegate = self
        addChild(rightButton)
        addChild(leftButton)
        addChild(jumpButton)
        }
    private func ballSetUp(constraintX: SKConstraint, constraintY: SKConstraint)
    {
        ball.constraints = [constraintX, constraintY]
        ball.name = "ball"
        ball.position = CGPoint(x: frame.width / 2, y: frame.height / 2)
        ball.physicsBody = SKPhysicsBody(circleOfRadius: 25)
        ball.physicsBody!.isDynamic = true
        ball.physicsBody!.allowsRotation = true
        ball.physicsBody!.restitution = 0.4
        ball.physicsBody!.collisionBitMask = ballCategory
        ball.physicsBody!.contactTestBitMask = UInt32(7)
        ball.size = CGSize(width: 50, height: 50)
        addChild(ball)
    }
    
    private func spikeSetUp()
    {
        spike.position = CGPoint(x: 0, y: frame.height * 0.8)
        spike.fillColor = SKColor.red
        spike.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 10, height: 10))
        spike.physicsBody!.isDynamic = false
        
        spike.name = "spike"
        spike.physicsBody!.collisionBitMask = spikeCategory
        spike.physicsBody!.contactTestBitMask = UInt32(7)
        
    }
    
    private func bottomPlaneSetUp()
    {
        bottomPlane.position = CGPoint(x: 0, y: 100)
        bottomPlane.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: frame.width, height: 1), center: CGPoint(x: frame.width/2, y: 5))
        bottomPlane.physicsBody!.isDynamic = false
        bottomPlane.fillColor = SKColor.red
        bottomPlane.physicsBody!.collisionBitMask = wallCategory
        bottomPlane.physicsBody!.contactTestBitMask = UInt32(7)
        addChild(bottomPlane)
    }
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        let constraintX = SKConstraint.positionX(SKRange.init(lowerLimit: frame.minX, upperLimit: frame.maxX))
        let constraintY = SKConstraint.positionY(SKRange.init(lowerLimit: frame.minY, upperLimit: frame.maxY))
        spikeSetUp()
        buttonsSetUp()
        ballSetUp(constraintX: constraintX, constraintY: constraintY)
        bottomPlaneSetUp()
        
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
    
    private func moveBallLeft()
    {
            ball.position = CGPoint(x: ball.position.x - 5, y: ball.position.y)
            ball.zRotation = ball.zRotation + 0.2
    }

 private func moveBallRight()
 {
   ball.position = CGPoint(x: ball.position.x + 5, y: ball.position.y)
   ball.zRotation = ball.zRotation - 0.2
 }
    
    private func jump()
    {
        ball.physicsBody!.applyImpulse(CGVector(dx: 0, dy: 40))
    }
    
    private func moveSpikes() throws
    {
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
            case "square":
                generateSquare()
            default:
                throw GameError.runtimeError("Unknow curve chosen!")
            }
            speedFactor = speedFactor + 0.1
        }
    }
    private func moveSpikesLeft() {
        for spike in spikes {
            spike.position.x = spike.position.x - CGFloat(speedFactor)
        }
    }
    
    private func moveSpikesRight()
    {
        for spike in spikes {
            spike.position.x = spike.position.x + CGFloat(speedFactor)
        }
    }
    
    private func moveSpikesUp()
    {
        for spike in spikes {
            spike.position.y = spike.position.y + CGFloat(speedFactor)
        }
    }
    
    private func moveSpikesDown()
    {
        for spike in spikes {
            spike.position.y = spike.position.y - CGFloat(speedFactor)
        }
    }
    private func cleanUpSpikes()
    {
        removeChildren(in: spikes)
        spikes.removeAll()
    }
    private func generateCosinius() {
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
    
    func generateSquare()
    {
        cleanUpSpikes()
        spike.position = CGPoint(x:frame.minX, y: 80)
        spikes.append(spike)
        print(spike.position.x)
        for i in 0...15
        {
            let newSpike: SKShapeNode = spike.copy() as! SKShapeNode
            let newX = spike.position.x + CGFloat(i * 10)
            newSpike.position = CGPoint(x: newX , y:  (0.02 * newX * newX) + 80)
            if (i < 8 || i > 11)
            {
                spikes.append(newSpike)
                
            }
            
            
        }
        for i in 0...15
        {
            let newSpike: SKShapeNode = spike.copy() as! SKShapeNode
            let newX = spike.position.x - CGFloat(i * 10)
            newSpike.position = CGPoint(x: newX , y:  (0.02 * newX * newX) + 80)
            if (i < 8 || i > 11)
            {
                spikes.append(newSpike)
            }
            
            
        }
        if (direction == "left")
        {
            for spike in spikes
            {
                spike.position.x = spike.position.x + frame.width + 100
                addChild(spike)
            }
        }
        else {
            for spike in spikes {
                spike.position.x = spike.position.x - 100
                addChild(spike)
            }
        }
           }
    
    func generateLine() throws {
        cleanUpSpikes()
        let holeBeginIndex = Int.random(in: 10...25)
        if (direction == "left" || direction == "right")
        {
            spike.position = CGPoint(x: frame.maxX + 1, y: frame.maxY - CGFloat(5) )
            spikes.append(spike)
            for i in 0...40 {
                let newSpike: SKShapeNode = spike.copy() as! SKShapeNode
                newSpike.position = CGPoint(x: spike.position.x, y: spike.position.y - CGFloat(i * 10))
                if (i >= holeBeginIndex && i <= holeBeginIndex + 10)
                {
                    continue
                }
                spikes.append(newSpike)
                addChild(newSpike)            }
            
        } else {
            spike.position = CGPoint(x: frame.minX - 1, y: frame.minY + 50 )
            spikes.append(spike)
            for i in 0...40 {
                let newSpike: SKShapeNode = spike.copy() as! SKShapeNode
                newSpike.position = CGPoint(x: spike.position.x + CGFloat(i * 10), y: spike.position.y)
                if (i >= holeBeginIndex && i <= holeBeginIndex + 10)
                {
                    continue
                }
                spikes.append(newSpike)
                addChild(newSpike)
            }
            
        }
    }
    func checkCurve(){
        newCurve = {
            switch direction {
            case "up":
                return spikes.allSatisfy({$0.position.y > frame.maxY + 50})
            case "down":
                return spikes.allSatisfy({$0.position.y < frame.minY + 50})
            case "left":
                return spikes.allSatisfy({$0.position.x < frame.minX - 50})
            case "right":
                return spikes.allSatisfy({$0.position.x > frame.maxX + 50})
            default:
                return true
            }
        }()
    }
    func chooseDirection(_ curve:String) {
        if (curve == "cosinus" || curve == "square")
        {
            direction = ["left", "right"].randomElement()!
        }
        else {
            direction = ["left", "right", "up", "down"].randomElement()!
        }
    }
}
