//
//  GameScene.swift
//  Game
//
//  Created by David Tapia on 10/6/21.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var lastUpdateTime: TimeInterval = 0
    
    //Constants for nodes
    let ballRadius: CGFloat = 15
    let paddleSize = CGSize(width: 100, height: 10)
    let paddleEdgeOffset: CGFloat = 60
    let wallWidth: CGFloat = 10
    
    
    var ball: SKShapeNode!
    var topPaddle: SKShapeNode!
    var bottomPaddle: SKShapeNode!
    
    var topPaddleDirection = PaddleDirection.still
    var bottomPaddleDirection = PaddleDirection.still
    
    override func didMove(to view: SKView) {
        startGame()
    }
    
    func startGame() {
        // We will call this after the game is over to start again, so
        // start by removing all of the nodes so we have a blank scene
        self.removeAllChildren()
        setUpPhysicsWorld()
        createBall()
        createWalls()
        createPassedBallDetectors()
        createPaddles()
        createScore()
        
        resetBall()
    }
    
    func setUpPhysicsWorld() {
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
    }
    
    func createBall() {
        let ball = SKShapeNode(circleOfRadius: ballRadius)
        ball.position = CGPoint(x: size.width/2, y: size.height/2)
        ball.physicsBody =
        SKPhysicsBody(circleOfRadius: ballRadius)
            .ideal()
        
        ball.strokeColor = .white
        ball.fillColor = .systemOrange
        
        addChild(ball)
        self.ball = ball
    }
    
    func resetBall() {
        ball?.physicsBody?.velocity = CGVector(dx: 200, dy: 200)
    }
    
    func createWalls() {
        createVerticalWall(x: wallWidth/2)
        createVerticalWall(x: size.width - wallWidth/2)
    }
    
    func createPassedBallDetectors() {
    }
    
    func createPaddles() {
        self.topPaddle = createPaddle(y: size.height - paddleEdgeOffset, color: .systemRed)
        self.bottomPaddle = createPaddle(y: paddleEdgeOffset, color: .systemBlue)
    }
    
    func createScore() {
    }
    
    func touchDown(atPoint pos : CGPoint) {
    }
    
    func touchMoved(toPoint pos : CGPoint) {
    }
    
    func touchUp(atPoint pos : CGPoint) {
    }
    
    // This function is called if a finger is placed on the screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
        
        guard let view = self.view else { return }
        
        for touch in touches {
            let location = touch.location(in: self)
            let direction: PaddleDirection =
            (location.x < view.frame.midX) ? .left : .right
            
            if location.y < view.frame.midY {
                bottomPaddleDirection = direction
            } else {
                topPaddleDirection = direction
            }
        }
    }
    
    // This function is called if a finger is moved on the screen
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    // This function is called if a finger is removed from the screen
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
        
        guard let view = self.view else { return }
        for touch in touches {
            let location = touch.location(in: self)
            
            if location.y < view.frame.midY {
                bottomPaddleDirection = .still
            } else {
                topPaddleDirection = .still
            }
        }
    }
    
    // This function is called if any two objects touch each other
    @nonobjc func didBegin(_ contact: SKPhysicsContact) {
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        defer {
            lastUpdateTime = currentTime
        }
        
        guard lastUpdateTime > 0 else {
            return
        }
        
        let amount = CGFloat(150.0 * (currentTime - lastUpdateTime))
        
        movePaddle(bottomPaddle, direction: bottomPaddleDirection, amount: amount)
        movePaddle(topPaddle, direction: topPaddleDirection, amount: amount)
    }
    
    func createVerticalWall(x: CGFloat) {
        let wallSize = CGSize(width: wallWidth, height: size.height)
        let wall = SKShapeNode(rectOf: wallSize)
        wall.physicsBody =
        SKPhysicsBody(rectangleOf: wallSize)
            .ideal()
            .manualMovement()
        
        wall.position = CGPoint(x: x, y: size.height/2)
        wall.strokeColor = .systemOrange
        wall.fillColor = .systemOrange
        addChild(wall)
    }
    
    func createPaddle(y: CGFloat, color: UIColor) -> SKShapeNode {
        let paddle = SKShapeNode(rectOf: paddleSize)
        paddle.physicsBody =
        SKPhysicsBody(rectangleOf: paddleSize)
            .ideal()
            .manualMovement()
        
        paddle.position = CGPoint(x: size.width/2, y: y)
        paddle.strokeColor = color
        paddle.fillColor = color
        addChild(paddle)
        return paddle
    }
    
    func movePaddle(_ paddle: SKNode?, direction: PaddleDirection, amount: CGFloat) {
        guard let view = self.view else { return }
        guard let paddle = paddle else { return }
        
        var pos = paddle.position
        switch direction {
        case .left:
            pos.x = pos.x - amount
            if pos.x < wallWidth + paddleSize.width/2 {
                pos.x = wallWidth + paddleSize.width/2
            }
        case .right:
            pos.x = pos.x + amount
            if pos.x > view.frame.maxX - wallWidth - paddleSize.width / 2 {
                pos.x = view.frame.maxX - wallWidth - paddleSize.width / 2
            }
        case .still:
            return
        }
        paddle.position = pos
    }
}

// Enumeration to breakdown our screen into quadrants to determine in which direction to move the paddle
enum PaddleDirection {
    case left
    case right
    case still
}

//Extension to the SpriteKit Physics body class to make ideal objects that have no friction
// or drag, and don't interact with the environment but can collide with other objects.
extension SKPhysicsBody {
    func ideal() -> SKPhysicsBody {
        self.friction = 0
        self.linearDamping = 0
        self.angularDamping = 0
        self.restitution = 1
        return self
    }
    
    func manualMovement() -> SKPhysicsBody {
        self.isDynamic = false
        self.allowsRotation = false
        self.affectedByGravity = false
        return self
    }
}

// Functions that help us make and use vectors
extension CGVector {
    
    init(angleRadians: CGFloat, length: CGFloat) {
        let dx = cos(angleRadians) * length
        let dy = sin(angleRadians) * length
        self.init(dx: dx, dy: dy)
    }
    
    init(angleDegrees: CGFloat, length: CGFloat) {
        self.init(angleRadians: angleDegrees / 180.0 * .pi, length: length)
    }
    
    func angleRadians() -> CGFloat {
        return atan2(dy, dx)
    }
    
    func angleDegrees() -> CGFloat {
        return angleRadians() * 180.0 / .pi
    }
    
    func length() -> CGFloat {
        return sqrt(pow(dx, 2) + pow(dy, 2))
    }
}
