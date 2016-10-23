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
    var samplerUnit:AudioUnit
    var musicPlayer:MusicPlayer
    var musicSequence:MusicSequence?
    
    init() {
        self.processingGraph = nil
        self.samplerUnit = nil
        self.musicPlayer = nil
        
        augraphSetup()
        graphStart()
        
        // after the graph starts
        loadSF2Preset(0)
        //or loadDLSPreset(0)
        

        
        self.musicSequence = loadMIDIFile("sibeliusGMajor", ext: "mid")
        self.musicPlayer = createPlayer(musicSequence!)
        
        let mSequence = MTMusicSequence(theSequence:self.musicSequence!)
        
        for var i:UInt32 = 0; i < mSequence.getTrackCount(); i++ {
            print("i:",i)
             let t =   mSequence.getTrackAtIndex(i)
            let myIterator = MTMusicEventIterator(track:t)
         
            
    
            while (myIterator.hasCurrentEvent()) {
                // do work here
                myIterator.nextEvent()
                print("event Info:",myIterator.getEventInfo())
            }
            
            
        }
     
        
        
        
        
        
        CAShow(UnsafeMutablePointer<MusicSequence>(self.processingGraph))
        CAShow(UnsafeMutablePointer<MusicSequence>(musicSequence!))
    }
    
    func getTrackLength() -> MusicTimeStamp {
        var track:MusicTrack = nil
        let status = MusicSequenceGetIndTrack(musicSequence!, 0, &track)
        CheckError(status)
        return getTrackLength(track)
    }
    
    
    func augraphSetup() {
        var status = OSStatus(noErr)
        status = NewAUGraph(&self.processingGraph)
        CheckError(status)
        
        // create the sampler
        
        //https://developer.apple.com/library/prerelease/ios/documentation/AudioUnit/Reference/AudioComponentServicesReference/index.html#//apple_ref/swift/struct/AudioComponentDescription
        
        var samplerNode = AUNode()
        var cd = AudioComponentDescription(
            componentType:         OSType(kAudioUnitType_MusicDevice),
            componentSubType:      OSType(kAudioUnitSubType_Sampler),
            componentManufacturer: OSType(kAudioUnitManufacturer_Apple),
            componentFlags:        0,
            componentFlagsMask:    0)
        status = AUGraphAddNode(self.processingGraph, &cd, &samplerNode)
        CheckError(status)
        
        // create the ionode
        var ioNode = AUNode()
        var ioUnitDescription = AudioComponentDescription(
            componentType:         OSType(kAudioUnitType_Output),
            componentSubType:      OSType(kAudioUnitSubType_RemoteIO),
            componentManufacturer: OSType(kAudioUnitManufacturer_Apple),
            componentFlags:        0,
            componentFlagsMask:    0)
        status = AUGraphAddNode(self.processingGraph, &ioUnitDescription, &ioNode)
        CheckError(status)
        
        // now do the wiring. The graph needs to be open before you call AUGraphNodeInfo
        status = AUGraphOpen(self.processingGraph)
        CheckError(status)
        
        status = AUGraphNodeInfo(self.processingGraph, samplerNode, nil, &self.samplerUnit)
        CheckError(status)
        
        var ioUnit:AudioUnit = nil
        status = AUGraphNodeInfo(self.processingGraph, ioNode, nil, &ioUnit)
        CheckError(status)
        
        let ioUnitOutputElement = AudioUnitElement(0)
        let samplerOutputElement = AudioUnitElement(0)
        status = AUGraphConnectNodeInput(self.processingGraph,
                                         samplerNode, samplerOutputElement, // srcnode, inSourceOutputNumber
            ioNode, ioUnitOutputElement) // destnode, inDestInputNumber
        CheckError(status)
    }
    
    
    func graphStart() {
        //https://developer.apple.com/library/prerelease/ios/documentation/AudioToolbox/Reference/AUGraphServicesReference/index.html#//apple_ref/c/func/AUGraphIsInitialized
        
        var status = OSStatus(noErr)
        var outIsInitialized:DarwinBoolean = false
        status = AUGraphIsInitialized(self.processingGraph, &outIsInitialized)
        print("isinit status is \(status)")
        print("bool is \(outIsInitialized)")
        if outIsInitialized == false {
            status = AUGraphInitialize(self.processingGraph)
            CheckError(status)
        }
        
        var isRunning = DarwinBoolean(false)
        status = AUGraphIsRunning(self.processingGraph, &isRunning)
        print("running bool is \(isRunning) status \(status)")
        if isRunning == false {
            print("graph is not running, starting now")
            status = AUGraphStart(self.processingGraph)
            CheckError(status)
        }
        
    }
    
    func playNoteOn(noteNum:UInt32, velocity:UInt32)    {
        // or with channel. channel is 0 in this example
        let noteCommand = UInt32(0x90 | 0)
        var status  = OSStatus(noErr)
        status = MusicDeviceMIDIEvent(self.samplerUnit, noteCommand, noteNum, velocity, 0)
        CheckError(status)
        print("noteon status is \(status)")
    }
    
    func playNoteOff(noteNum:UInt32)    {
        let noteCommand = UInt32(0x80 | 0)
        var status : OSStatus = OSStatus(noErr)
        status = MusicDeviceMIDIEvent(self.samplerUnit, noteCommand, noteNum, 0, 0)
        CheckError(status)
        print("noteoff status is \(status)")
    }
    
    
    /// loads preset into self.samplerUnit
    func loadSF2Preset(preset:UInt8)  {
        
        guard let bankURL = NSBundle.mainBundle().URLForResource("GeneralUser GS MuseScore v1.442", withExtension: "sf2") else {
            fatalError("\"GeneralUser GS MuseScore v1.442.sf2\" file not found.")
        }
        
        var instdata = AUSamplerInstrumentData(fileURL: Unmanaged.passUnretained(bankURL),
                                               instrumentType: UInt8(kInstrumentType_SF2Preset),
                                               bankMSB:        UInt8(kAUSampler_DefaultMelodicBankMSB),
                                               bankLSB:        UInt8(kAUSampler_DefaultBankLSB),
                                               presetID:       preset)
        
        let status = AudioUnitSetProperty(
            self.samplerUnit,
            AudioUnitPropertyID(kAUSamplerProperty_LoadInstrument),
            AudioUnitScope(kAudioUnitScope_Global),
            0,
            &instdata,
            UInt32(sizeof(AUSamplerInstrumentData)))
        CheckError(status)
    }
    
    
    func loadDLSPreset(pn:UInt8) {
        
        guard let bankURL = NSBundle.mainBundle().URLForResource("gs_instruments", withExtension: "dls") else {
            fatalError("\"gs_instruments.dls\" file not found.")
        }
        
        var instdata = AUSamplerInstrumentData(fileURL: Unmanaged.passUnretained(bankURL),
                                               instrumentType: UInt8(kInstrumentType_DLSPreset),
                                               bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB),
                                               bankLSB: UInt8(kAUSampler_DefaultBankLSB),
                                               presetID: pn)
        let status = AudioUnitSetProperty(
            self.samplerUnit,
            UInt32(kAUSamplerProperty_LoadInstrument),
            UInt32(kAudioUnitScope_Global),
            0,
            &instdata,
            UInt32(sizeof(AUSamplerInstrumentData)))
        CheckError(status)
    }
    
    /**
     Not as detailed as Adamson's CheckError, but adequate.
     For other projects you can uncomment the Core MIDI constants.
     */
    func CheckError(error:OSStatus) {
        if error == 0 {return}
        
        switch(error) {
        // AudioToolbox
        case kAUGraphErr_NodeNotFound:
            print("Error:kAUGraphErr_NodeNotFound \n");
            
        case kAUGraphErr_OutputNodeErr:
            print( "Error:kAUGraphErr_OutputNodeErr \n");
            
        case kAUGraphErr_InvalidConnection:
            print("Error:kAUGraphErr_InvalidConnection \n");
            
        case kAUGraphErr_CannotDoInCurrentContext:
            print( "Error:kAUGraphErr_CannotDoInCurrentContext \n");
            
        case kAUGraphErr_InvalidAudioUnit:
            print( "Error:kAUGraphErr_InvalidAudioUnit \n");
            
            // Core MIDI constants. Not using them here.
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
            print( " kAudioToolboxErr_InvalidSequenceType ");
            
        case kAudioToolboxErr_TrackIndexError :
            print( " kAudioToolboxErr_TrackIndexError ");
            
        case kAudioToolboxErr_TrackNotFound :
            print( " kAudioToolboxErr_TrackNotFound ");
            
        case kAudioToolboxErr_EndOfTrack :
            print( " kAudioToolboxErr_EndOfTrack ");
            
        case kAudioToolboxErr_StartOfTrack :
            print( " kAudioToolboxErr_StartOfTrack ");
            
        case kAudioToolboxErr_IllegalTrackDestination	:
            print( " kAudioToolboxErr_IllegalTrackDestination");
            
        case kAudioToolboxErr_NoSequence 		:
            print( " kAudioToolboxErr_NoSequence ");
            
        case kAudioToolboxErr_InvalidEventType		:
            print( " kAudioToolboxErr_InvalidEventType");
            
        case kAudioToolboxErr_InvalidPlayerState	:
            print( " kAudioToolboxErr_InvalidPlayerState");
            
        case kAudioUnitErr_InvalidProperty		:
            print( " kAudioUnitErr_InvalidProperty");
            
        case kAudioUnitErr_InvalidParameter		:
            print( " kAudioUnitErr_InvalidParameter");
            
        case kAudioUnitErr_InvalidElement		:
            print( " kAudioUnitErr_InvalidElement");
            
        case kAudioUnitErr_NoConnection			:
            print( " kAudioUnitErr_NoConnection");
            
        case kAudioUnitErr_FailedInitialization		:
            print( " kAudioUnitErr_FailedInitialization");
            
        case kAudioUnitErr_TooManyFramesToProcess	:
            print( " kAudioUnitErr_TooManyFramesToProcess");
            
        case kAudioUnitErr_InvalidFile			:
            print( " kAudioUnitErr_InvalidFile");
            
        case kAudioUnitErr_FormatNotSupported		:
            print( " kAudioUnitErr_FormatNotSupported");
            
        case kAudioUnitErr_Uninitialized		:
            print( " kAudioUnitErr_Uninitialized");
            
        case kAudioUnitErr_InvalidScope			:
            print( " kAudioUnitErr_InvalidScope");
            
        case kAudioUnitErr_PropertyNotWritable		:
            print( " kAudioUnitErr_PropertyNotWritable");
            
        case kAudioUnitErr_InvalidPropertyValue		:
            print( " kAudioUnitErr_InvalidPropertyValue");
            
        case kAudioUnitErr_PropertyNotInUse		:
            print( " kAudioUnitErr_PropertyNotInUse");
            
        case kAudioUnitErr_Initialized			:
            print( " kAudioUnitErr_Initialized");
            
        case kAudioUnitErr_InvalidOfflineRender		:
            print( " kAudioUnitErr_InvalidOfflineRender");
            
        case kAudioUnitErr_Unauthorized			:
            print( " kAudioUnitErr_Unauthorized");
            
        default:
            print("huh?")
        }
    }
    
    
    func loadMIDIFile(filename:CFString, ext:CFString) -> MusicSequence {
        
        var status = OSStatus(noErr)
        
        var _musicSequence:MusicSequence = nil
        status = NewMusicSequence(&_musicSequence)
        if status != OSStatus(noErr) {
            CheckError(status)
            return nil
        }
        
        let midiFileURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), filename, ext, nil)
        let flags:MusicSequenceLoadFlags = MusicSequenceLoadFlags.SMF_ChannelsToTracks
        let typeid = MusicSequenceFileTypeID.MIDIType
        status = MusicSequenceFileLoad(_musicSequence,
            midiFileURL,
            typeid,
            flags)
        if status != OSStatus(noErr) {
            print("\(__LINE__) bad status \(status)")
            CheckError(status)
            print("loading file")
            return nil
        }
        
        // if you set up an AUGraph. Otherwise it will be played with a sine wave.
        //        status = MusicSequenceSetAUGraph(musicSequence, self.processingGraph)
        
        musicSequence = _musicSequence
        
        // debugging using C(ore) A(udio) show.
        CAShow(UnsafeMutablePointer<MusicSequence>(_musicSequence))
        return _musicSequence
    }
    
    func createMusicSequence() -> MusicSequence {
        // create the sequence
        var musicSequence:MusicSequence = nil
        var status = NewMusicSequence(&musicSequence)
        if status != OSStatus(noErr) {
            print("\(#line) bad status \(status) creating sequence")
            CheckError(status)
        }
        
        // add a track
        var track:MusicTrack = nil
        status = MusicSequenceNewTrack(musicSequence, &track)
        if status != OSStatus(noErr) {
            print("error creating track \(status)")
            CheckError(status)
        }
        
        // now make some notes and put them on the track
        var beat = MusicTimeStamp(1.0)
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
            beat += 1
        }
        
        loopTrack(track)
        
        // associate the AUGraph with the sequence.
        MusicSequenceSetAUGraph(musicSequence, self.processingGraph)
        
        return musicSequence
    }
    
    func createPlayer(musicSequence:MusicSequence) -> MusicPlayer {
        var musicPlayer:MusicPlayer = nil
        
        var status = NewMusicPlayer(&musicPlayer)
        if status != noErr {
            print("bad status \(status) creating player")
            CheckError(status)
        }
        status = MusicPlayerSetSequence(musicPlayer, musicSequence)
        if status != noErr {
            print("setting sequence \(status)")
            CheckError(status)
        }
        status = MusicPlayerPreroll(musicPlayer)
        if status != noErr {
            print("prerolling player \(status)")
            CheckError(status)
        }
        return musicPlayer
    }
    
    // called fron the button's action
    func play() {
        var playing = DarwinBoolean(false)
        var status = MusicPlayerIsPlaying(musicPlayer, &playing)
        if playing != false {
            print("music player is playing. stopping")
            status = MusicPlayerStop(musicPlayer)
            if status != noErr {
                print("Error stopping \(status)")
                CheckError(status)
                return
            }
        } else {
            print("music player is not playing.")
        }
        
        status = MusicPlayerSetTime(musicPlayer, 0)
        if status != noErr {
            print("setting time \(status)")
            CheckError(status)
            return
        }
        
        status = MusicPlayerStart(musicPlayer)
        if status != noErr {
            print("Error starting \(status)")
            CheckError(status)
            return
        }
    }
    
    func stop() {
        let status = MusicPlayerStop(musicPlayer)
        if status != noErr {
            print("Error stopping \(status)")
            CheckError(status)
            return
        }
    }
    
    func getTrackLength(musicTrack:MusicTrack) -> MusicTimeStamp {
        
        //The time of the last music event in a music track, plus time required for note fade-outs and so on.
        var trackLength = MusicTimeStamp(0)
        var tracklengthSize = UInt32(0)
        let status = MusicTrackGetProperty(musicTrack,
                                           UInt32(kSequenceTrackProperty_TrackLength),
                                           &trackLength,
                                           &tracklengthSize)
        if status != noErr {
            print("Error getting track length \(status)")
            CheckError(status)
            return 0
        }
        print("track length is \(trackLength)")
        return trackLength
    }
    
    func loopTrack(musicTrack:MusicTrack)   {
        
        let trackLength = getTrackLength(musicTrack)
        print("track length is \(trackLength)")
        setTrackLoopDuration(musicTrack, duration: trackLength)
        
        //        status = MusicTrackGetProperty(musicTrack, UInt32(kSequenceTrackProperty_LoopInfo), &loopInfo, &lisize )
        //        if status != OSStatus(noErr) {
        //            println("Error getting loopinfo on track \(status)")
        //            CheckError(status)
        //            return
        //        }
        
        
    }
    
    /*
     
     The default looping behaviour is off (track plays once)
     Looping is set by specifying the length of the loop. It loops from
     (TrackLength - loop length) to Track Length
     If numLoops is set to zero, it will loop forever.
     To turn looping off, you set this with loop length equal to zero.
     */
    
    func setTrackLoopDuration(duration:Float)   {
        var track:MusicTrack = nil
        let status = MusicSequenceGetIndTrack(musicSequence!, 0, &track)
        CheckError(status)
        setTrackLoopDuration(track, duration: MusicTimeStamp(duration))
    }
    
    
    func setTrackLoopDuration(musicTrack:MusicTrack, duration:MusicTimeStamp)   {
        print("loop duration to \(duration)")
        
        //To loop forever, set numberOfLoops to 0. To explicitly turn off looping, specify a loopDuration of 0.
        var loopInfo = MusicTrackLoopInfo(loopDuration: duration, numberOfLoops: 0)
        let lisize = UInt32(0)
        let status = MusicTrackSetProperty(musicTrack, UInt32(kSequenceTrackProperty_LoopInfo), &loopInfo, lisize )
        if status != OSStatus(noErr) {
            print("Error setting loopinfo on track \(status)")
            CheckError(status)
            return
        }
    }
    
    
}

