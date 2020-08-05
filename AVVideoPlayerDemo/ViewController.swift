//
//  ViewController.swift
//  AVVideoPlayerDemo
//
//  Created by mac on 05/08/20.
//  Copyright © 2020 mac. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit


class ViewController: UIViewController {
    //MARK:- Variables
    var filterPlayers : [AVPlayer?] = []
    var currentPage: Int = 0
    var player: AVPlayer?
    var playerController : AVPlayerViewController?
    var avPlayerLayer : AVPlayerLayer!
    var arrayItems = [ "http://clips.vorwaerts-gmbh.de/VfE_html5.mp4",
        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4",
        "http://clips.vorwaerts-gmbh.de/VfE_html5.mp4",
        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",
        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4",
        "http://clips.vorwaerts-gmbh.de/VfE_html5.mp4",
        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4"]
    //MARK:- Outlets
    @IBOutlet weak var tblPlayerContainer: UITableView!
    //MARK:- ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
}
//MARK:- TableViewDelegate&Datasource Extension
extension ViewController:UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayItems.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblPlayerContainer.dequeueReusableCell(withIdentifier: "PlayerCell", for: indexPath) as! PlayerCell
        let getVideoLink = arrayItems[indexPath.row]
        filterPlayers.removeAll()
        //Adding image to cell
        let imgViewThumbnail: UIImageView = UIImageView.init(frame: cell.vwPlayer.bounds)
        imgViewThumbnail.image = getThumbnailImage(forUrl: URL(string: getVideoLink)!)
        imgViewThumbnail.contentMode = .scaleAspectFit
        cell.vwPlayer.backgroundColor = .clear
        cell.vwPlayer.addSubview(imgViewThumbnail)
        //For Multiple player
        let player = AVPlayer(url: URL(string: getVideoLink)!)
        let avPlayerLayer = AVPlayerLayer(player: player)
        avPlayerLayer.videoGravity = .resizeAspect
        avPlayerLayer.masksToBounds = true
        avPlayerLayer.cornerRadius = 5
        avPlayerLayer.frame = cell.vwPlayer.layer.bounds
        cell.vwPlayer.layer.addSublayer(avPlayerLayer)
        filterPlayers.append(player)
        playVideos()
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
}
extension ViewController {
    func getThumbnailImage(forUrl url: URL) -> UIImage? {
        let asset: AVAsset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        do {
            let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60) , actualTime: nil)
            return UIImage(cgImage: thumbnailImage)
        } catch let error {
            print(error)
        }
        return nil
    }
    
    func playVideos() {
        for i in 0...filterPlayers.count - 1 {
            playVideoWithPlayer((filterPlayers[i])!)
        }
        for i in 0...filterPlayers.count - 1 {
            if i != currentPage {
                (filterPlayers[i])!.pause()
            }
        }
    }
    func playVideoWithPlayer(_ player: AVPlayer) {
        player.play()
    }
    
    func playVideoWithPlayer(_ player: AVPlayer, video:AVURLAsset, filterName:String) {
        let  avPlayerItem = AVPlayerItem(asset: video)
        if (filterName != "NoFilter") {
            let avVideoComposition = AVVideoComposition(asset: video, applyingCIFiltersWithHandler: { request in
                let source = request.sourceImage.clampedToExtent()
                let filter = CIFilter(name:filterName)!
                filter.setDefaults()
                filter.setValue(source, forKey: kCIInputImageKey)
                let output = filter.outputImage!
                request.finish(with:output, context: nil)
            })
            avPlayerItem.videoComposition = avVideoComposition
        }
        player.replaceCurrentItem(with: avPlayerItem)
        player.play()
    }
    
    @objc func playerItemDidReachEnd(_ notification: Notification) {
        //For Single player
        //   player!.seek(to: CMTime.zero)
        //   player!.play()
        //   For Multiple player
        for i in 0...filterPlayers.count - 1 {
            if i == currentPage {
                (filterPlayers[i])!.seek(to: CMTime.zero)
                (filterPlayers[i])!.play()
            }
        }
    }
}
