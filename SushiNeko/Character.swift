//
//  Character.swift
//  SushiNeko
//
//  Created by Mehmet Sadıç on 23/11/2016.
//  Copyright © 2016 Mehmet Sadıç. All rights reserved.
//

import SpriteKit

class Character: SKSpriteNode {
  
  // Character side
  var side: Side = .left {
    didSet {
      if side == .left {
        xScale = 1
        position.x = -90
      } else {
        /* An easy way to flip an asset horizontally is to invert the X-axis scale */
        xScale = -1
        position.x = 90
      }
      let punch = SKAction(named: "Punch")!
      run(punch)
    }
  }
  
  /* You are required to implement this for your subclass to work */
  override init(texture: SKTexture?, color: UIColor, size: CGSize) {
    super.init(texture: texture, color: color, size: size)
  }
  
  /* You are required to implement this for your subclass to work */
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
}
