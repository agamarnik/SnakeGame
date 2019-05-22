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
            }
        }
    }
    
    func renderChange() {
        for (node, x, y) in scene.gameArray {
            if contains(a: scene.playerPositions, v: (x,y)) {
                node.fillColor = SKColor.cyan
            } else {
                node.fillColor = SKColor.clear
            }
        }
    }
    
    func contains(a:[(Int, Int)], v:(Int,Int)) -> Bool {
        let (c1, c2) = v
        for (v1, v2) in a { if v1 == c1 && v2 == c2 { return true } }
        return false
    }
    
    private func updatePlayerPosition() {
        //4
        var xChange = -1
        var yChange = 0
        //5
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
        default:
            break
        }
        //6
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
