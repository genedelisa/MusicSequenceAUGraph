//
//  MTMusicTrack.swift
//  MidiToolbox
//
//  Created by Thom Jordan on 11/18/14.
//  Copyright (c) 2014 Thom Jordan. All rights reserved.
//

/*--------------------------------------------------------------------------------------------------------*
|                                       M U S I C   T R A C K                                             |
*---------------------------------------------------------------------------------------------------------*/

#if os(OSX)
    import Cocoa
#elseif os(iOS)
    import UIKit
#endif
import AudioToolbox


class MTMusicTrack: NSObject {
    
    var track         : MusicTrack
    var loopDuration  : MusicTimeStamp
    var numberOfLoops : Int32
    var trackLength   : MusicTimeStamp
    
    //  no specified track length means that it will use the timestamp of its current last element.
    
    override init() {
        track         = MusicTrack() //
        loopDuration  = MusicTimeStamp(0.0)
        numberOfLoops = Int32(0)
        trackLength   = MusicTimeStamp(0.0)
        super.init()
    }
    init(theTrack: MusicTrack) {
        track         = theTrack
        loopDuration  = MusicTimeStamp(0.0)
        numberOfLoops = Int32(0)
        trackLength   = MusicTimeStamp(0.0)
        super.init()
    }
    
    // Here's a collection of prototype events, some with common default values.
    // New events can conveniently be built from these with message chaining via functional composition and currying (partial application).
    
    struct Event {
        var note     = MIDINoteMessage(channel: 0, note: UInt8(36), velocity: UInt8(120), releaseVelocity: UInt8(0), duration: Float32(0.5))
        var cc       = MIDIChannelMessage(status: UInt8(0x00), data1: UInt8(0), data2: UInt8(0), reserved: UInt8(0))
        var auparam  = ParameterEvent(parameterID: AudioUnitParameterID(), scope: AudioUnitScope(), element: AudioUnitElement(), value: AudioUnitParameterValue())
        // var aupreset = AUPresetEvent(scope: AudioUnitScope(), element: AudioUnitElement(), preset: CFPropertyList!)
        var userdata = MusicEventUserData(length: UInt32(0), data: UInt8()) // for user-defined event data of n bytes (length = n)
        var meta     = MIDIMetaEvent(metaEventType: UInt8(), unused1: UInt8(), unused2: UInt8(), unused3: UInt8(), dataLength: UInt32(), data: UInt8())
        var sysex    = MIDIRawData(length: UInt32(0), data: UInt8())
        
   
    /*
        EVENT CREATORS (these should be wrapped) :
        
        MusicTrackNewAUPresetEvent
        MusicTrackNewUserEvent
        MusicTrackNewMetaEvent
        MusicTrackNewExtendedTempoEvent
        MusicTrackNewParameterEvent
        MusicTrackNewExtendedNoteEvent
        MusicTrackNewMIDIRawDataEvent
        MusicTrackNewMIDIChannelEvent
        MusicTrackNewMIDINoteEvent
        
        MusicTrackGetProperty
        MusicTrackSetProperty
    */
    }
    
    func changeNumberOfLoops(numloops:Int32) {
        numberOfLoops = numloops
        var loopInfo:MusicTrackLoopInfo = MusicTrackLoopInfo(loopDuration: loopDuration, numberOfLoops: numloops)
        (confirm)(MusicTrackSetProperty(track, UInt32(kSequenceTrackProperty_LoopInfo), &loopInfo, UInt32(sizeof(MusicTrackLoopInfo)) as UInt32))
    }
    
    func changeLoopDuration(duration:MusicTimeStamp) {
        loopDuration = duration
        var loopInfo:MusicTrackLoopInfo = MusicTrackLoopInfo(loopDuration: duration, numberOfLoops: numberOfLoops)
        (confirm)(MusicTrackSetProperty(track, UInt32(kSequenceTrackProperty_LoopInfo), &loopInfo, UInt32(sizeof(MusicTrackLoopInfo)) as UInt32))
    }
    
    func changeTrackLength(trklen: MusicTimeStamp) {
        trackLength = trklen
        (confirm)(MusicTrackSetProperty(track, UInt32(kSequenceTrackProperty_TrackLength), &trackLength, UInt32(sizeof(MusicTimeStamp))))
    }
    
    func newExtendedTempoEvent(location:MusicTimeStamp, bpm:Float64) {
        (confirm)(MusicTrackNewExtendedTempoEvent(track, location, bpm))
    }
    
    func setDestAUNode(node: AUNode?) {
        if let n = node {
            (confirm)(MusicTrackSetDestNode(track, n))
        }
    }
    
    func getDestAUNode() -> AUNode { // optionals required here?
        var node = AUNode()
        (confirm)(MusicTrackGetDestNode(track, &node))
        return node
    }
    
    func setDestMIDIEndpoint(endpoint: MIDIEndpointRef?) {
        if let ep = endpoint {
            (confirm)(MusicTrackSetDestMIDIEndpoint(track, ep))
        }
    }
    
    func getDestMIDIEndpoint() -> MIDIEndpointRef { // optionals required here?
        var endp = MIDIEndpointRef()
        (confirm)(MusicTrackGetDestMIDIEndpoint(track, &endp))
        return endp
    }
    
    func mergeFromTrack(sourceTrack: MTMusicTrack, sourceStart: MusicTimeStamp, sourceEnd: MusicTimeStamp, destInsertTime: MusicTimeStamp) {
        (confirm)(MusicTrackMerge(sourceTrack.track, sourceStart, sourceEnd, track, destInsertTime))
    }
    
    func mergeIntoTrack(destTrack: MTMusicTrack, sourceStart: MusicTimeStamp, sourceEnd: MusicTimeStamp, destInsertTime: MusicTimeStamp) {
        (confirm)(MusicTrackMerge(track, sourceStart, sourceEnd, destTrack.track, destInsertTime))
    }
    
    func copyInsertFrom(sourceTrack: MTMusicTrack, sourceStart: MusicTimeStamp, sourceEnd: MusicTimeStamp, destInsertTime: MusicTimeStamp) {
        (confirm)(MusicTrackCopyInsert(sourceTrack.track, sourceStart, sourceEnd, track, destInsertTime))
    }
    
    func copyInsertInto(destTrack: MTMusicTrack, sourceStart: MusicTimeStamp, sourceEnd: MusicTimeStamp, destInsertTime: MusicTimeStamp) {
        (confirm)(MusicTrackCopyInsert(track, sourceStart, sourceEnd, destTrack.track, destInsertTime))
    }
    
    func cut(startTime: MusicTimeStamp, endTime: MusicTimeStamp) {
        (confirm)(MusicTrackCut(track, startTime, endTime))
    }
    
    func clear(startTime: MusicTimeStamp, endTime: MusicTimeStamp) {
        (confirm)(MusicTrackClear(track, startTime, endTime))
    }
    
    func moveEvents(startTime: MusicTimeStamp, endTime: MusicTimeStamp, moveTime: MusicTimeStamp) {
        (confirm)(MusicTrackMoveEvents(track, startTime, endTime, moveTime))
    }
    
    func getSequence() -> MTMusicSequence {
        var seq = MusicSequence()
        (confirm)(MusicTrackGetSequence(track, &seq))
        return MTMusicSequence(theSequence: seq)
    }
    
}

