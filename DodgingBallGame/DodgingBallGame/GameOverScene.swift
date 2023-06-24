//
//  GameOverScene.swift
//  DodgingBallGame
//
//  Created by Karol Orzechowski on 24/06/2023.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene {
    var result: Int = 0
    
    override func didMove(to view: SKView) {
        let gameOver = SKLabelNode(text: "GAME OVER")
        gameOver.fontSize = 40
        gameOver.position = CGPoint(x: frame.midX, y: frame.midY + 50)
        let resultNode = SKLabelNode(text: "Result: \(result)")
        resultNode.fontSize = 20
        resultNode.position = CGPoint(x: frame.midX, y: frame.midY)
        let resume = SKLabelNode(text: "Tap to play again")
        resume.position = CGPoint(x: frame.midX, y: frame.midY - 50)
        resume.fontSize = 15
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(tap))
        view.addGestureRecognizer(recognizer)
        addChild(gameOver)
        addChild(resume)
        addChild(resultNode)
    }
    
    @objc
    func tap(recognizer: UIGestureRecognizer)
    {
        restart()
    }
    
    func restart() -> Void {
        for rec in (view?.gestureRecognizers)!
        {
            view?.removeGestureRecognizer(rec)
        }
        let transition = SKTransition.fade(with: .black, duration: 5)
        let restartScene = GameScene(size: (view?.frame.size)!)
        self.view?.presentScene(restartScene, transition: transition)
    }
    
}
