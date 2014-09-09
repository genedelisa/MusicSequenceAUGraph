//
//  SoundGenerator.swift
//  SwiftSimpleAUGraph
//
//  Created by Gene De Lisa on 6/8/14.
//  Copyright (c) 2014 Gene De Lisa. All rights reserved.
//

import Foundation
import AudioToolbox
import CoreAudio
import AVFoundation

class SoundGenerator  {
    
    var processingGraph:AUGraph
    var samplerNode:AUNode
    var ioNode:AUNode
    var samplerUnit:AudioUnit
    var ioUnit:AudioUnit
    var isPlaying:Bool
    var musicPlayer:MusicPlayer
    
    init() {
        self.processingGraph = AUGraph()
        self.samplerNode = AUNode()
        self.ioNode = AUNode()
        self.samplerUnit  = AudioUnit()
        self.ioUnit  = AudioUnit()
        self.isPlaying = false
        self.musicPlayer = nil
        
        
        augraphSetup()
        graphStart()
        // after the graph starts
        loadSF2Preset(1)
        
        var musicSequence = createMusicSequence()
        self.musicPlayer = createPlayer(musicSequence)
        
        CAShow(UnsafeMutablePointer<MusicSequence>(self.processingGraph))
        CAShow(UnsafeMutablePointer<MusicSequence>(musicSequence))
    }
    
    
    func augraphSetup() {
        var status : OSStatus = 0
        status = NewAUGraph(&processingGraph)
        CheckError(status)
        
        // create the sampler
        
        //https://developer.apple.com/library/prerelease/ios/documentation/AudioUnit/Reference/AudioComponentServicesReference/index.html#//apple_ref/swift/struct/AudioComponentDescription
        
        
        var cd:AudioComponentDescription = AudioComponentDescription(
            componentType: OSType(kAudioUnitType_MusicDevice),
            componentSubType: OSType(kAudioUnitSubType_Sampler),
            componentManufacturer: OSType(kAudioUnitManufacturer_Apple),
            componentFlags: 0,
            componentFlagsMask: 0)
        status = AUGraphAddNode(self.processingGraph, &cd, &samplerNode)
        CheckError(status)
        
        // create the ionode
        
        var ioUnitDescription:AudioComponentDescription = AudioComponentDescription(
            componentType: OSType(kAudioUnitType_Output),
            componentSubType: OSType(kAudioUnitSubType_RemoteIO),
            componentManufacturer: OSType(kAudioUnitManufacturer_Apple),
            componentFlags: 0,
            componentFlagsMask: 0)
        status = AUGraphAddNode(self.processingGraph, &ioUnitDescription, &ioNode)
        CheckError(status)
        
        // now do the wiring. The graph needs to be open before you call AUGraphNodeInfo
        status = AUGraphOpen(self.processingGraph)
        CheckError(status)
        
        status = AUGraphNodeInfo(self.processingGraph, self.samplerNode, nil, &samplerUnit)
        CheckError(status)
        
        status = AUGraphNodeInfo(self.processingGraph, self.ioNode, nil, &ioUnit)
        CheckError(status)
        
        var ioUnitOutputElement:AudioUnitElement = 0
        var samplerOutputElement:AudioUnitElement = 0
        status = AUGraphConnectNodeInput(self.processingGraph,
            self.samplerNode, samplerOutputElement, // srcnode, inSourceOutputNumber
            self.ioNode, ioUnitOutputElement) // destnode, inDestInputNumber
        CheckError(status)
    }
    
    
    
    
    func graphStart() {
        //https://developer.apple.com/library/prerelease/ios/documentation/AudioToolbox/Reference/AUGraphServicesReference/index.html#//apple_ref/c/func/AUGraphIsInitialized
        
        var status : OSStatus = OSStatus(noErr)
        var outIsInitialized:Boolean = 0
        status = AUGraphIsInitialized(self.processingGraph, &outIsInitialized)
        println("isinit status is \(status)")
        println("bool is \(outIsInitialized)")
        if outIsInitialized == 0 {
            status = AUGraphInitialize(self.processingGraph)
            CheckError(status)
        }
        
        var isRunning:Boolean = 0
        AUGraphIsRunning(self.processingGraph, &isRunning)
        println("running bool is \(isRunning)")
        if isRunning == 0 {
            status = AUGraphStart(self.processingGraph)
            CheckError(status)
        }
        
        self.isPlaying = true;
    }
    
    func playNoteOn(noteNum:UInt32, velocity:UInt32)    {
        var noteCommand:UInt32 = 0x90 | 0;
        var status : OSStatus = OSStatus(noErr)
        status = MusicDeviceMIDIEvent(self.samplerUnit, noteCommand, noteNum, velocity, 0)
        CheckError(status)
        println("noteon status is \(status)")
    }
    
    func playNoteOff(noteNum:UInt32)    {
        var noteCommand:UInt32 = 0x80 | 0;
        var status : OSStatus = OSStatus(noErr)
        status = MusicDeviceMIDIEvent(self.samplerUnit, noteCommand, noteNum, 0, 0)
        CheckError(status)
        println("noteoff status is \(status)")
    }
    
    
    /// loads preset into self.samplerUnit
    func loadSF2Preset(preset:UInt8)  {
        
        if let bankURL = NSBundle.mainBundle().URLForResource("GeneralUser GS MuseScore v1.442", withExtension: "sf2") {
            var instdata = AUSamplerInstrumentData(fileURL: Unmanaged.passUnretained(bankURL),
                instrumentType: UInt8(kInstrumentType_DLSPreset),
                bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB),
                bankLSB: UInt8(kAUSampler_DefaultBankLSB),
                presetID: preset)
            
            var status = AudioUnitSetProperty(
                self.samplerUnit,
                UInt32(kAUSamplerProperty_LoadInstrument),
                UInt32(kAudioUnitScope_Global),
                0,
                &instdata,
                UInt32(sizeof(AUSamplerInstrumentData)))
            CheckError(status)
        }
    }
    
    
    func loadDLSPreset(pn:UInt8) {
        if let bankURL = NSBundle.mainBundle().URLForResource("gs_instruments", withExtension: "dls") {
            var instdata = AUSamplerInstrumentData(fileURL: Unmanaged.passUnretained(bankURL),
                instrumentType: UInt8(kInstrumentType_DLSPreset),
                bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB),
                bankLSB: UInt8(kAUSampler_DefaultBankLSB),
                presetID: pn)
            var status = AudioUnitSetProperty(
                self.samplerUnit,
                UInt32(kAUSamplerProperty_LoadInstrument),
                UInt32(kAudioUnitScope_Global),
                0,
                &instdata,
                UInt32(sizeof(AUSamplerInstrumentData)))
            CheckError(status)
            
        }
    }
    
    
    func CheckError(error:OSStatus) {
        if error == 0 {return}
        
        switch(Int(error)) {
            // AudioToolbox
        case kAUGraphErr_NodeNotFound:
            println("Error:kAUGraphErr_NodeNotFound \n");
            
        case kAUGraphErr_OutputNodeErr:
            println( "Error:kAUGraphErr_OutputNodeErr \n");
            
        case kAUGraphErr_InvalidConnection:
            println("Error:kAUGraphErr_InvalidConnection \n");
            
        case kAUGraphErr_CannotDoInCurrentContext:
            println( "Error:kAUGraphErr_CannotDoInCurrentContext \n");
            
        case kAUGraphErr_InvalidAudioUnit:
            println( "Error:kAUGraphErr_InvalidAudioUnit \n");
            
            //    case kMIDIInvalidClient :
            //        println( "kMIDIInvalidClient ");
            //
            //
            //    case kMIDIInvalidPort :
            //        println( "kMIDIInvalidPort ");
            //
            //
            //    case kMIDIWrongEndpointType :
            //        println( "kMIDIWrongEndpointType");
            //
            //
            //    case kMIDINoConnection :
            //        println( "kMIDINoConnection ");
            //
            //
            //    case kMIDIUnknownEndpoint :
            //        println( "kMIDIUnknownEndpoint ");
            //
            //
            //    case kMIDIUnknownProperty :
            //        println( "kMIDIUnknownProperty ");
            //
            //
            //    case kMIDIWrongPropertyType :
            //        println( "kMIDIWrongPropertyType ");
            //
            //
            //    case kMIDINoCurrentSetup :
            //        println( "kMIDINoCurrentSetup ");
            //
            //
            //    case kMIDIMessageSendErr :
            //        println( "kMIDIMessageSendErr ");
            //
            //
            //    case kMIDIServerStartErr :
            //        println( "kMIDIServerStartErr ");
            //
            //
            //    case kMIDISetupFormatErr :
            //        println( "kMIDISetupFormatErr ");
            //
            //
            //    case kMIDIWrongThread :
            //        println( "kMIDIWrongThread ");
            //
            //
            //    case kMIDIObjectNotFound :
            //        println( "kMIDIObjectNotFound ");
            //
            //
            //    case kMIDIIDNotUnique :
            //        println( "kMIDIIDNotUnique ");
            
            
        case kAudioToolboxErr_InvalidSequenceType :
            println( " kAudioToolboxErr_InvalidSequenceType ");
            
        case kAudioToolboxErr_TrackIndexError :
            println( " kAudioToolboxErr_TrackIndexError ");
            
        case kAudioToolboxErr_TrackNotFound :
            println( " kAudioToolboxErr_TrackNotFound ");
            
        case kAudioToolboxErr_EndOfTrack :
            println( " kAudioToolboxErr_EndOfTrack ");
            
        case kAudioToolboxErr_StartOfTrack :
            println( " kAudioToolboxErr_StartOfTrack ");
            
        case kAudioToolboxErr_IllegalTrackDestination	:
            println( " kAudioToolboxErr_IllegalTrackDestination");
            
        case kAudioToolboxErr_NoSequence 		:
            println( " kAudioToolboxErr_NoSequence ");
            
        case kAudioToolboxErr_InvalidEventType		:
            println( " kAudioToolboxErr_InvalidEventType");
            
        case kAudioToolboxErr_InvalidPlayerState	:
            println( " kAudioToolboxErr_InvalidPlayerState");
            
        case kAudioUnitErr_InvalidProperty		:
            println( " kAudioUnitErr_InvalidProperty");
            
        case kAudioUnitErr_InvalidParameter		:
            println( " kAudioUnitErr_InvalidParameter");
            
        case kAudioUnitErr_InvalidElement		:
            println( " kAudioUnitErr_InvalidElement");
            
        case kAudioUnitErr_NoConnection			:
            println( " kAudioUnitErr_NoConnection");
            
        case kAudioUnitErr_FailedInitialization		:
            println( " kAudioUnitErr_FailedInitialization");
            
        case kAudioUnitErr_TooManyFramesToProcess	:
            println( " kAudioUnitErr_TooManyFramesToProcess");
            
        case kAudioUnitErr_InvalidFile			:
            println( " kAudioUnitErr_InvalidFile");
            
        case kAudioUnitErr_FormatNotSupported		:
            println( " kAudioUnitErr_FormatNotSupported");
            
        case kAudioUnitErr_Uninitialized		:
            println( " kAudioUnitErr_Uninitialized");
            
        case kAudioUnitErr_InvalidScope			:
            println( " kAudioUnitErr_InvalidScope");
            
        case kAudioUnitErr_PropertyNotWritable		:
            println( " kAudioUnitErr_PropertyNotWritable");
            
        case kAudioUnitErr_InvalidPropertyValue		:
            println( " kAudioUnitErr_InvalidPropertyValue");
            
        case kAudioUnitErr_PropertyNotInUse		:
            println( " kAudioUnitErr_PropertyNotInUse");
            
        case kAudioUnitErr_Initialized			:
            println( " kAudioUnitErr_Initialized");
            
        case kAudioUnitErr_InvalidOfflineRender		:
            println( " kAudioUnitErr_InvalidOfflineRender");
            
        case kAudioUnitErr_Unauthorized			:
            println( " kAudioUnitErr_Unauthorized");
            
        default:
            println("huh?")
        }
    }
    
    
    func createMusicSequence() -> MusicSequence {
        // create the sequence
        var musicSequence:MusicSequence = MusicSequence()
        var status = NewMusicSequence(&musicSequence)
        if status != OSStatus(noErr) {
            println("\(__LINE__) bad status \(status) creating sequence")
            CheckError(status)
        }
        
        // add a track
        var track:MusicTrack = MusicTrack()
        status = MusicSequenceNewTrack(musicSequence, &track)
        if status != OSStatus(noErr) {
            println("error creating track \(status)")
            CheckError(status)
        }
        
        // now make some notes and put them on the track
        var beat:MusicTimeStamp = 1.0
        for i:UInt8 in 60...72 {
            var mess = MIDINoteMessage(channel: 0,
                note: i,
                velocity: 64,
                releaseVelocity: 0,
                duration: 1.0 )
            status = MusicTrackNewMIDINoteEvent(track, beat, &mess)
            if status != OSStatus(noErr) {
                CheckError(status)
            }
            beat++
        }
        
        // associate the AUGraph with the sequence.
        MusicSequenceSetAUGraph(musicSequence, self.processingGraph)
        
        return musicSequence
    }
    
    func createPlayer(musicSequence:MusicSequence) -> MusicPlayer {
        var musicPlayer:MusicPlayer = MusicPlayer()
        var status = OSStatus(noErr)
        status = NewMusicPlayer(&musicPlayer)
        if status != OSStatus(noErr) {
            println("bad status \(status) creating player")
            CheckError(status)
        }
        status = MusicPlayerSetSequence(musicPlayer, musicSequence)
        if status != OSStatus(noErr) {
            println("setting sequence \(status)")
            CheckError(status)
        }
        status = MusicPlayerPreroll(musicPlayer)
        if status != OSStatus(noErr) {
            println("prerolling player \(status)")
            CheckError(status)
        }
        return musicPlayer
    }
    
    func play() {
        var status = OSStatus(noErr)
        var playing:Boolean = 0
        status = MusicPlayerIsPlaying(musicPlayer, &playing)
        if playing != 0 {
            println("music player is playing. stopping")
            status = MusicPlayerStop(musicPlayer)
            if status != OSStatus(noErr) {
                println("Error stopping \(status)")
                CheckError(status)
                return
            }
        } else {
            println("music player is not playing.")
        }
        
        status = MusicPlayerSetTime(musicPlayer, 0)
        if status != OSStatus(noErr) {
            println("setting time \(status)")
            CheckError(status)
            return
        }
        
        status = MusicPlayerStart(musicPlayer)
        if status != OSStatus(noErr) {
            println("Error starting \(status)")
            CheckError(status)
            return
        }
    }
}

