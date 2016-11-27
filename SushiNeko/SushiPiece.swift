//
//  SushiPiece.swift
//  SushiNeko
//
//  Created by Mehmet Sadıç on 23/11/2016.
//  Copyright © 2016 Mehmet Sadıç. All rights reserved.
//

import SpriteKit

class SushiPiece: SKSpriteNode {
  
  // Sushi type
  var side: Side = .none {
    didSet {
      switch side {
      case .left:
        // Show left chopstick
        leftChopstick.isHidden = false
      case .right:
        // Show right chopstick
        rightChopstick.isHidden = false
      case .none:
        // Hide all chopsticks
        leftChopstick.isHidden = true
        rightChopstick.isHidden = true
      }
    }
  }
  
  // chopsticks objects
  var leftChopstick: SKSpriteNode!
  var rightChopstick: SKSpriteNode!
  
  /* You are required to implement this for your subclass to work */
  override init(texture: SKTexture?, color: UIColor, size: CGSize) {
    super.init(texture: texture, color: color, size: size)
  }
  
  /* You are required to implement this for your subclass to work */
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  // connect our child chopstick nodes
  func connectChopsticks() {
    leftChopstick = childNode(withName: "leftChopstick") as! SKSpriteNode!
    rightChopstick = childNode(withName: "rightChopstick") as! SKSpriteNode!
    
    // Set the default side
    side = .none
  }
  
  func flip(_ side: Side) {
    // flip sushi out of the screen
    
    var actionName = ""
    
    // assign actions according to side
    if side == .left {
      actionName = "FlipRight"
    } else if side == .right {
      actionName = "FlipLeft"
    }
    
    // load appropriate action
    let flip = SKAction(named: actionName)!
    
    // create a nodal removal action
    let remove = SKAction.removeFromParent()
    
    // build a sequence of actions. flip then remove
    let sequence = SKAction.sequence([flip, remove])
    run(sequence)
  }
}
