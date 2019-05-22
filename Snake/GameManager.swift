//
//  GameManager.swift
//  Snake
//
//  Created by Alice Gamarnik on 5/13/19.
//  Copyright © 2019 Alice Gamarnik. All rights reserved.
//

import Foundation
import SpriteKit

class GameManager {
    var scene: GameScene!
    
    var nextTime: Double?
    var timeExtension: Double = 0.5
    var playerDirection: Int = 1 // 1 == left, 2 == up, 3 == right, 4 == down
    var currentScore: Int = 0
    
    init(scene: GameScene) {
        self.scene = scene
    }
    
    //init game view and player position
    func initGame() {
        //starting player position
        scene.playerPositions.append((10, 10))
        scene.playerPositions.append((10, 11))
        scene.playerPositions.append((10, 12))
        renderChange()
        
        generateNewPoint()
    }
    
    //generate new food point within bounds of board array (20x40)
    private func generateNewPoint() {
        var randomX = CGFloat(arc4random_uniform(19))
        var randomY = CGFloat(arc4random_uniform(39))
        //ensure new pint is not inside snake body
        while contains(a: scene.playerPositions, v: (Int(randomX), Int(randomY))) {
            randomX = CGFloat(arc4random_uniform(19))
            randomY = CGFloat(arc4random_uniform(39))
        }
        scene.scorePos = CGPoint(x: randomX, y: randomY)
    }
    
    /* We now have a function that runs once per second, if you want to increase the speed of your game simply lower timeExtension to a value that is greater than 0, if you want to slow down your game then increase the value of timeExtension. (Note: “1” == 1 second for timeExtension). */
    
    //update -- called every frame
    func update(time: Double) {
        if nextTime == nil {
            nextTime = time + timeExtension
        } else {
            if time >= nextTime! {
                nextTime = time + timeExtension
                //print(time)
                updatePlayerPosition()
                checkForScore()
                checkForDeath()
                snakeDied()
            }
        }
    }
    
    private func snakeDied() {
        if playerDirection == 0 && scene.playerPositions.count > 0 {
            var hasFinished = true
            let headOfSnake = scene.playerPositions[0]
            for position in scene.playerPositions {
                if headOfSnake != position {
                    hasFinished = false
                }
            }
            if hasFinished {
                print("end game")
                updateScore()
                playerDirection = 4
                //animation has completed
                scene.scorePos = nil
                scene.playerPositions.removeAll()
                renderChange()
                //return to menu
                //scene.currentScore.run(SKAction.scale(to: 0, duration: 0.4) {
                    //self.scene.currentScore.isHidden = true
                //}
                    scene.gameBG.run(SKAction.scale(to: 0, duration: 0.4)) {
                        self.scene.gameBG.isHidden = true
                        self.scene.gameLogo.isHidden = false
                        self.scene.gameLogo.run(SKAction.move(to: CGPoint(x: 0, y: (self.scene.frame.size.height / 2) - 200), duration: 0.5)) {
                            self.scene.playButton.isHidden = false
                            self.scene.playButton.run(SKAction.scale(to: 1, duration: 0.3))
                            self.scene.bestScore.run(SKAction.move(to: CGPoint(x: 0, y: self.scene.gameLogo.position.y - 50), duration: 0.3))
                        }
                }
            }
        }
    }
    
    private func updateScore() {
        if currentScore > UserDefaults.standard.integer(forKey: "bestScore") {
            UserDefaults.standard.set(currentScore, forKey: "bestScore")
        }
        currentScore = 0
        scene.currentScore.text = "Score: 0"
        scene.bestScore.text = "Best Score: \(UserDefaults.standard.integer(forKey: "bestScore"))"
    }
    
    private func checkForDeath() {
        if scene.playerPositions.count > 0 {
            var arrayOfPositions = scene.playerPositions
            let headOfSnake = arrayOfPositions[0]
            arrayOfPositions.remove(at: 0)
            if contains(a: arrayOfPositions, v: headOfSnake) {
                playerDirection = 0
            }
        }
    }
    
    private func checkForScore() {
        if scene.scorePos != nil {
            let x = scene.playerPositions[0].0
            let y = scene.playerPositions[0].1
            if Int((scene.scorePos?.x)!) == y && Int((scene.scorePos?.y)!) == x {
                currentScore += 1
                scene.currentScore.text = "Score: \(currentScore)"
                generateNewPoint()
                //snake grow
                scene.playerPositions.append(scene.playerPositions.last!)
                scene.playerPositions.append(scene.playerPositions.last!)
                scene.playerPositions.append(scene.playerPositions.last!)
            }
        }
    }
    
    func renderChange() {
        for (node, x, y) in scene.gameArray {
            if contains(a: scene.playerPositions, v: (x,y)) {
                node.fillColor = SKColor.cyan
            } else {
                node.fillColor = SKColor.clear
                if scene.scorePos != nil {
                    if Int((scene.scorePos?.x)!) == y && Int((scene.scorePos?.y)!) == x {
                        node.fillColor = SKColor.yellow
                    }
                }
            }
        }
    }
    
    func contains(a:[(Int, Int)], v:(Int,Int)) -> Bool {
        let (c1, c2) = v
        for (v1, v2) in a { if v1 == c1 && v2 == c2 { return true } }
        return false
    }
    
    func swipe(ID: Int) {
        //swipe can't conflict with current direction
        //cant move up -> down, down -> up, left -> right, right -> left
        if !(ID == 2 && playerDirection == 4) && !(ID == 4 && playerDirection == 2) {
            if !(ID == 1 && playerDirection == 3) && !(ID == 3 && playerDirection == 1) {
                if playerDirection != 0 { //if not dead
                    playerDirection = ID
                }
            }
        }
    }
    
    private func updatePlayerPosition() {
        var xChange = -1
        var yChange = 0
        switch playerDirection {
        case 1:
            //left
            xChange = -1
            yChange = 0
            break
        case 2:
            //up
            xChange = 0
            yChange = -1
            break
        case 3:
            //right
            xChange = 1
            yChange = 0
            break
        case 4:
            //down
            xChange = 0
            yChange = 1
            break
        case 0:
            //dead
            xChange = 0
            yChange = 0
            break
        default:
            break
        }
        if scene.playerPositions.count > 0 {
            var start = scene.playerPositions.count - 1
            while start > 0 {
                scene.playerPositions[start] = scene.playerPositions[start - 1]
                start -= 1
            }
            scene.playerPositions[0] = (scene.playerPositions[0].0 + yChange, scene.playerPositions[0].1 + xChange)
        }
        //wrap snake around screen
        if scene.playerPositions.count > 0 {
            let x = scene.playerPositions[0].1
            let y = scene.playerPositions[0].0
            if y > 40 {
                scene.playerPositions[0].0 = 0
            } else if y < 0 {
                scene.playerPositions[0].0 = 40
            } else if x > 20 {
                scene.playerPositions[0].1 = 0
            } else if x < 0 {
                scene.playerPositions[0].1 = 20
            }
        }
        //render new array of player positions
        renderChange()
    }
}
