//
//  MTMusicPlayer.swift
//  MidiToolbox
//
//  Created by Thom Jordan on 11/18/14.
//  Copyright (c) 2014 Thom Jordan. All rights reserved.
//

/*--------------------------------------------------------------------------------------------------------*
 |                                       M U S I C   P L A Y E R                                          |
 *--------------------------------------------------------------------------------------------------------*/


#if os(OSX)
    import Cocoa
    #elseif os(iOS)
    import UIKit
#endif
import AudioToolbox


class MTMusicPlayer: NSObject {
    
    var player:MusicPlayer
    
    override init() {
        player = MusicPlayer()
        (confirm)(NewMusicPlayer(&player))
        super.init()
    }
    
    func setSequence(mtMusicSequence: MTMusicSequence) {
        (confirm)(MusicPlayerSetSequence(player, mtMusicSequence.sequence))
    }
    
    func getSequence() -> MTMusicSequence {
        var seq = MusicSequence()
        (confirm)(MusicPlayerGetSequence(player, &seq))
        return MTMusicSequence(theSequence: seq)
    }
    
    func disposePlayer() {
        (confirm)(DisposeMusicPlayer(player))
    }
    
    func setTime(time: MusicTimeStamp) {
        (confirm)(MusicPlayerSetTime(player, time))
    }
    
    func getTime() -> MusicTimeStamp {
        var time = MusicTimeStamp()
        (confirm)(MusicPlayerGetTime(player, &time))
        return time
    }
    
    func preroll() {
        (confirm)(MusicPlayerPreroll(player))
    }
    
    func start() {
        (confirm)(MusicPlayerStart(player))
    }
    
    func stop() {
        (confirm)(MusicPlayerStop(player))
    }
    
    func isPlaying() -> DarwinBoolean {
        var playing:DarwinBoolean = false
        (confirm)(MusicPlayerIsPlaying(player, &playing))
        return playing
    }
    
    func setPlayRateScalar(rate: Float64) {
        (confirm)(MusicPlayerSetPlayRateScalar(player, rate))
    }
    
    func getPlayRateScalar() -> Float64 {
        var rate = Float64()
        (confirm)(MusicPlayerGetPlayRateScalar(player, &rate))
        return rate
    }
    
    func getHostTimeForBeats(beats: MusicTimeStamp) -> UInt64 {
        var time = UInt64()
        (confirm)(MusicPlayerGetHostTimeForBeats(player, beats, &time))
        return time
    }
    
    func getBeatsForHostTime(time: UInt64) -> MusicTimeStamp {
        var beats = MusicTimeStamp()
        (confirm)(MusicPlayerGetBeatsForHostTime(player, time, &beats))
        return beats
    }
    
    
}
