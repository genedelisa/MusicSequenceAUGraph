//
//  MTMusicSequence.swift
//  MidiToolbox
//
//  Created by Thom Jordan on 11/18/14.
//  Copyright (c) 2014 Thom Jordan. All rights reserved.
//

/*--------------------------------------------------------------------------------------------------------*
|                                      M U S I C   S E Q U E N C E                                        |
*---------------------------------------------------------------------------------------------------------*/

#if os(OSX)
    import Cocoa
    #elseif os(iOS)
    import UIKit
#endif
import AudioToolbox


typealias MusicSequenceType = UInt32


class MTMusicSequence: NSObject {
    
    var sequence:MusicSequence
    
    override init() {
        sequence = MusicSequence()
        (confirm)(NewMusicSequence(&sequence))
        super.init()
    }
    
    init(theSequence: MusicSequence) {
        sequence = theSequence
        super.init()
    }
    
    func newTrack() -> MTMusicTrack {
        var trk = MusicTrack()
        (confirm)(MusicSequenceNewTrack(sequence, &trk))
        return MTMusicTrack(theTrack: trk)
    }
    
    func disposeTrack(mtMusicTrack: MTMusicTrack) {
        (confirm)(MusicSequenceDisposeTrack(sequence, mtMusicTrack.track))
    }
    
    func setMIDIEndpoint(endpoint: MIDIEndpointRef?) {
        if let ep = endpoint {
            (confirm)(MusicSequenceSetMIDIEndpoint(sequence, ep))
        }
    }
    
    func setAUGraph(augraph: AUGraph?) {
        if let augr = augraph {
            (confirm)(MusicSequenceSetAUGraph(sequence, augr))
        }
    }
    
    func getAUGraph() -> AUGraph {
        var augr = AUGraph()
        (confirm)(MusicSequenceGetAUGraph(sequence, &augr))
        return augr
    }
    
    func reverse() {
        (confirm)(MusicSequenceReverse(sequence))
    }
    
    func getTrackIndex(mtMusicTrack: MTMusicTrack) -> UInt32 {
        var idx = UInt32()
        (confirm)(MusicSequenceGetTrackIndex(sequence, mtMusicTrack.track, &idx))
        return idx
    }
    
    func getTrackAtIndex(trackIndex: UInt32) -> MTMusicTrack {
        var trk = MusicTrack()
        (confirm)(MusicSequenceGetIndTrack(sequence, trackIndex, &trk))
        return MTMusicTrack(theTrack: trk)
    }
    
    func getTrackCount() -> UInt32 {
        var numtracks = UInt32()
        (confirm)(MusicSequenceGetTrackCount(sequence, &numtracks))
        return numtracks
    }
    
    func getTempoTrack() -> MTMusicTrack {
        var trk = MusicTrack()
        (confirm)(MusicSequenceGetTempoTrack(sequence, &trk))
        return MTMusicTrack(theTrack: trk)
    }
    
    func getSecondsForBeats(beats: MusicTimeStamp) -> Float64 {
        var numsecs = Float64()
        (confirm)(MusicSequenceGetSecondsForBeats(sequence, beats, &numsecs))
        return numsecs
    }
    
    func getBeatsForSeconds(seconds: Float64) -> MusicTimeStamp {
        var beats = MusicTimeStamp()
        (confirm)(MusicSequenceGetBeatsForSeconds(sequence, seconds, &beats))
        return beats
    }
    
    func getInfoDictionary() -> CFDictionary? {
        if let cfd = MusicSequenceGetInfoDictionary(sequence) as? CFDictionary{
            return cfd
        }
        return nil
    }
    
    func getSequenceType() -> MusicSequenceType {
        var mst = MusicSequenceType() as! UInt32
        //(confirm)(MusicSequenceGetSequenceType(sequence, mst))
        return mst
    }
    
    func setSequenceType(type: MusicSequenceType) {
        //(confirm)(MusicSequenceSetSequenceType(sequence, type))
    }
    
    // ----------------------------------------------------------------------
    
    // needs more work on the C <--> Swift interface
    
    func beatsToBarBeatTime(beats: MusicTimeStamp, subbeatDivisor: UInt32) -> CABarBeatTime {
        var bbt = CABarBeatTime(bar: Int32(), beat: UInt16(), subbeat: UInt16(), subbeatDivisor: UInt16(), reserved: UInt16())
        (confirm)(MusicSequenceBeatsToBarBeatTime(sequence, beats, subbeatDivisor, &bbt))
        return bbt
    }
    func barBeatTimeToBeats(bbTime: UnsafePointer<CABarBeatTime>) -> MusicTimeStamp {
        var beats = MusicTimeStamp()
        (confirm)(MusicSequenceBarBeatTimeToBeats(sequence, bbTime, &beats))
        return beats
    }
    
    /*
    
    remaining MusicSequence functions:
    
    fileCreate
    fileCreateData
    fileLoad
    fileLoadData
    
    func MusicSequenceSetUserCallback(_ inSequence: MusicSequence,
        _ inCallback: MusicSequenceUserCallback,
        _ inClientData: UnsafeMutablePointer<Void>) -> OSStatus
    */
    // -----------------------------------------------------------------------
    
}

    /*
    struct CABarBeatTime {
        bar            : UInt32;
        beat           : UInt16;
        subbeat        : UInt16;
        subbeatDivisor : UInt16;
        reserved       : UInt16;
    };
    */
