//
//  PlayerCell.swift
//  AVVideoPlayerDemo
//
//  Created by mac on 05/08/20.
//  Copyright © 2020 mac. All rights reserved.
//

import UIKit
import AVKit
class PlayerCell: UITableViewCell {
    @IBOutlet weak var vwPlayer: UIView!
    
    var player: AVPlayer? {
        get {
            return playerLayer.player
        }
        set {
            playerLayer.videoGravity = .resizeAspect
            playerLayer.player = newValue
        }
    }
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    override static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
}
