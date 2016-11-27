//
//  GameScene.swift
//  SushiNeko
//
//  Created by Mehmet Sadıç on 22/11/2016.
//  Copyright © 2016 Mehmet Sadıç. All rights reserved.
//

import SpriteKit
import GameplayKit

// Tracking enum for use with character and sushi side
enum Side {
  case left, right, none
}

// Tracking enum for game state
enum GameState {
  case title, ready, playing, gameOver
}

class GameScene: SKScene {
  
  // Game objects
  var sushiBasePiece: SushiPiece!
  var character: Character!
  var playButton: MSButtonNode!
  var healthBar: SKSpriteNode!
  var scoreLabel: SKLabelNode!
  
  // game management
  var state: GameState = .title
  
  // sushi tower array
  var sushiTower: [SushiPiece] = []
  
  // health counter
  var health: CGFloat = 1.0 {
    didSet {
      // scale health bar between 0.0 -> 1.0 e.g 0 -> 100%
      healthBar.xScale = health
    }
  }
  
  // score counter
  var score: Int = 0 {
    didSet {
      scoreLabel.text = String(score)
    }
  }
  
  override func didMove(to view: SKView) {
    
    // Connect game objects
    self.sushiBasePiece = self.childNode(withName: "sushiBasePiece") as! SushiPiece
    self.character = self.childNode(withName: "character") as! Character
    self.playButton = self.childNode(withName: "playButton") as! MSButtonNode
    self.healthBar = self.childNode(withName: "healthBar") as! SKSpriteNode
    self.scoreLabel = self.childNode(withName: "scoreLabel") as! SKLabelNode
    
    // Setup chopstick connections
    sushiBasePiece.connectChopsticks()
    
    // Manually stack start of the tower
    addTowerPiece(side: .none)
    addTowerPiece(side: .right)
    
    // Add 10 pieces to sushi tower randomly
    addRandomPieces(total: 10)
    
    // setup play button selected handler
    playButton.selectedHandler = {
      // start game
      self.state = .ready
    }
    
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    // Called when touch begins
    
    // game not ready to play
    guard state == .ready || state == .playing else { return }
    
    // game begins on first touch
    state = .playing
    
    // All we need is a single touch
    let touch = touches.first!
    
    // Get touch position in scene
    let touchLocation = touch.location(in: self)
    
    // is the location on the left/right side of screen
    if touchLocation.x < 0 {
      character.side = .left
    } else {
      character.side = .right
    }
    
    // Remove and grab first sushi piece from suhi tower array
    let firstPiece = sushiTower.first as SushiPiece!
    
    /* check character side against sushi piece side (this is our death scenario) */
    if character.side == firstPiece?.side {
      
      // Drop all sushi pieces down one place
      for sushiPiece in sushiTower {
        let dropAction = SKAction.move(by: CGVector(dx: 0, dy: -55), duration: 0.10)
        sushiPiece.run(dropAction)
      }
      
      gameOver()
      
      // no need to continue as player is dead
      return
    }
    
    // increment health
    health += 0.1
    // cap the health
    if health > 1.0 { health = 1.0 }
    
    // increment score
    score += 1
    
    sushiTower.removeFirst()
    
    // Drop all sushi pieces down one place
    for sushiPiece in sushiTower {
      let dropAction = SKAction.move(by: CGVector(dx: 0, dy: -55), duration: 0.10)
      sushiPiece.run(dropAction)
      
      // Reduce z position to stop z position climb over UI
      sushiPiece.zPosition -= 1
    }
    
    firstPiece?.flip(character.side)
    
    // Add a new random sushi piece to top of sushi tower
    addRandomPieces(total: 1)
  }
  
  override func update(_ currentTime: TimeInterval) {
    // Called before each frame is rendered
    
    guard state == .playing else { return }
    
    // decrease health
    health -= 0.01
    
    // has the player ran out of health?
    if health < 0 { gameOver() }
  }
  
  func addTowerPiece(side: Side) {
    // Add new sushi piece to the sushi tower
    
    // Copy original sushi piece
    let newPiece = sushiBasePiece.copy() as! SushiPiece
    newPiece.connectChopsticks()
    
    // Access last piece properties
    let lastPiece = sushiTower.last
    
    // Add on top of last piece, default on first piece
    let lastPiecePosition = lastPiece?.position ?? sushiBasePiece.position
    newPiece.position = lastPiecePosition + CGPoint(x: 0, y: 55)
    
    // Increment Z to ensure it is on top of the last piece
    let lastPieceZPosition = lastPiece?.zPosition  ?? sushiBasePiece.zPosition
    newPiece.zPosition = lastPieceZPosition + 1
    
    // Set side
    newPiece.side = side
    
    // Add new piece to the scene
    addChild(newPiece)
    
    // Add new piece to the tower
    sushiTower.append(newPiece)
  }
  
  func addRandomPieces(total: Int) {
    // Add random sushi pieces to the tower
    
    for _ in 1...total {
      // Access last piece properties
      let lastPiece = sushiTower.last as SushiPiece!
      
      // Ensure we don't create impossible sushi structure
      if lastPiece?.side != Side.none {
        addTowerPiece(side: Side.none)
      } else {
        // Random number generator
        let rand = CGFloat.random(0, max: 1)
        
        if rand < 0.45 {
          // 45 % chance of a left piece
          addTowerPiece(side: .left)
        } else if rand < 0.90 {
          // 45 % chance of a right piece
          addTowerPiece(side: .right)
        } else {
          // 10 % chance of an empty piece
          addTowerPiece(side: .none)
        }
      }
    }
    
  }
  
  func gameOver() {
    // game over
    
    state = .gameOver
    
    // turn all sushi pieces into red
    for sushiPiece in sushiTower {
      sushiPiece.run(SKAction.colorize(with: UIColor.red, colorBlendFactor: 1.0, duration: 0.50))
    }
    
    // make player turn into red
    character.run(SKAction.colorize(with: UIColor.red, colorBlendFactor: 1.0, duration: 0.50))
    
    // change play button selected handler
    playButton.selectedHandler = {
      
      /* Grab reference to the SpriteKit view */
      let skView = self.view as SKView!
      
      // Load the SKScene from 'GameScene.sks'
      let scene = GameScene(fileNamed: "GameScene")
      
      /* Ensure correct aspect mode */
      scene?.scaleMode = .aspectFill
      
      /* Restart GameScene */
      skView?.presentScene(scene)
      
    }
  }
  
}
