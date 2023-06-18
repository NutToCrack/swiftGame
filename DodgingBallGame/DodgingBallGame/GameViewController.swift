//
//  GameViewController.swift
//  DodgingBallGame
//
//  Created by Karol Orzechowski on 16/06/2023.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        let scene = GameScene(size: view.frame.size)
        let skView = view as! SKView
        skView.presentScene(scene)
    }
}
