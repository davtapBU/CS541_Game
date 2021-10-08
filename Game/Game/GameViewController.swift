//
//  GameViewController.swift
//  Game
//
//  Created by David Tapia on 10/6/21.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    var scene: GameScene?

    override func loadView() {
        super.loadView()
        self.view = SKView()
        self.view.bounds = UIScreen.main.bounds
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupScene()
    }

    func setupScene() {
        if let view = self.view as? SKView, scene == nil {
            let scene = GameScene(size: view.bounds.size)
            view.presentScene(scene)
            self.scene = scene
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
