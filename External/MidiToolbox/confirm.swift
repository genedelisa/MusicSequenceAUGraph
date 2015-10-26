//
//  utils.swift
//  InteractiveMusicAgentObjC
//
//  Created by Thom Jordan on 10/13/14.
//  Copyright (c) 2014 Thom Jordan. All rights reserved.
//

import Foundation
import AudioToolbox


func confirm(err: OSStatus) {
    if err == 0 { return }
    
    switch(OSStatus(err)) {
        
    case kMIDIInvalidClient     :
        NSLog( "OSStatus error:  kMIDIInvalidClient ");
        
    case kMIDIInvalidPort       :
        NSLog( "OSStatus error:  kMIDIInvalidPort ");
        
    case kMIDIWrongEndpointType :
        NSLog( "OSStatus error:  kMIDIWrongEndpointType");
        
    case kMIDINoConnection      :
        NSLog( "OSStatus error:  kMIDINoConnection ");
        
    case kMIDIUnknownEndpoint   :
        NSLog( "OSStatus error:  kMIDIUnknownEndpoint ");
        
    case kMIDIUnknownProperty   :
        NSLog( "OSStatus error:  kMIDIUnknownProperty ");
        
    case kMIDIWrongPropertyType :
        NSLog( "OSStatus error:  kMIDIWrongPropertyType ");
        
    case kMIDINoCurrentSetup    :
        NSLog( "OSStatus error:  kMIDINoCurrentSetup ");
        
    case kMIDIMessageSendErr    :
        NSLog( "OSStatus error:  kMIDIMessageSendErr ");
        
    case kMIDIServerStartErr    :
        NSLog( "OSStatus error:  kMIDIServerStartErr ");
        
    case kMIDISetupFormatErr    :
        NSLog( "OSStatus error:  kMIDISetupFormatErr ");
        
    case kMIDIWrongThread       :
        NSLog( "OSStatus error:  kMIDIWrongThread ");
        
    case kMIDIObjectNotFound    :
        NSLog( "OSStatus error:  kMIDIObjectNotFound ");
        
    case kMIDIIDNotUnique       :
        NSLog( "OSStatus error:  kMIDIIDNotUnique ");

    case kAUGraphErr_NodeNotFound             :
        NSLog( "OSStatus error:  kAUGraphErr_NodeNotFound \n");
        
    case kAUGraphErr_OutputNodeErr            :
        NSLog( "OSStatus error:  kAUGraphErr_OutputNodeErr \n");
        
    case kAUGraphErr_InvalidConnection        :
        NSLog( "OSStatus error:  kAUGraphErr_InvalidConnection \n");
        
    case kAUGraphErr_CannotDoInCurrentContext :
        NSLog( "OSStatus error:  kAUGraphErr_CannotDoInCurrentContext \n");
        
    case kAUGraphErr_InvalidAudioUnit         :
        NSLog( "OSStatus error:  kAUGraphErr_InvalidAudioUnit \n");
        
    case kAudioToolboxErr_InvalidSequenceType :
        NSLog( "OSStatus error:  kAudioToolboxErr_InvalidSequenceType ");
        
    case kAudioToolboxErr_TrackIndexError     :
        NSLog( "OSStatus error:  kAudioToolboxErr_TrackIndexError ");
        
    case kAudioToolboxErr_TrackNotFound       :
        NSLog( "OSStatus error:  kAudioToolboxErr_TrackNotFound ");
        
    case kAudioToolboxErr_EndOfTrack          :
        NSLog( "OSStatus error:  kAudioToolboxErr_EndOfTrack ");
        
    case kAudioToolboxErr_StartOfTrack        :
        NSLog( "OSStatus error:  kAudioToolboxErr_StartOfTrack ");
        
    case kAudioToolboxErr_IllegalTrackDestination :
        NSLog( "OSStatus error:  kAudioToolboxErr_IllegalTrackDestination");
        
    case kAudioToolboxErr_NoSequence 		  :
        NSLog( "OSStatus error:  kAudioToolboxErr_NoSequence ");
        
    case kAudioToolboxErr_InvalidEventType	  :
        NSLog( "OSStatus error:  kAudioToolboxErr_InvalidEventType");
        
    case kAudioToolboxErr_InvalidPlayerState  :
        NSLog( "OSStatus error:  kAudioToolboxErr_InvalidPlayerState");
        
    case kAudioUnitErr_InvalidProperty		  :
        NSLog( "OSStatus error:  kAudioUnitErr_InvalidProperty");
        
    case kAudioUnitErr_InvalidParameter		  :
        NSLog( "OSStatus error:  kAudioUnitErr_InvalidParameter");
        
    case kAudioUnitErr_InvalidElement		  :
        NSLog( "OSStatus error:  kAudioUnitErr_InvalidElement");
        
    case kAudioUnitErr_NoConnection			  :
        NSLog( "OSStatus error:  kAudioUnitErr_NoConnection");
        
    case kAudioUnitErr_FailedInitialization	  :
        NSLog( "OSStatus error:  kAudioUnitErr_FailedInitialization");
        
    case kAudioUnitErr_TooManyFramesToProcess :
        NSLog( "OSStatus error:  kAudioUnitErr_TooManyFramesToProcess");
        
    case kAudioUnitErr_InvalidFile			  :
        NSLog( "OSStatus error:  kAudioUnitErr_InvalidFile");
        
    case kAudioUnitErr_FormatNotSupported	  :
        NSLog( "OSStatus error:  kAudioUnitErr_FormatNotSupported");
        
    case kAudioUnitErr_Uninitialized		  :
        NSLog( "OSStatus error:  kAudioUnitErr_Uninitialized");
        
    case kAudioUnitErr_InvalidScope           :
        NSLog( "OSStatus error:  kAudioUnitErr_InvalidScope");
        
    case kAudioUnitErr_PropertyNotWritable	  :
        NSLog( "OSStatus error:  kAudioUnitErr_PropertyNotWritable");
        
    case kAudioUnitErr_InvalidPropertyValue	  :
        NSLog( "OSStatus error:  kAudioUnitErr_InvalidPropertyValue");
        
    case kAudioUnitErr_PropertyNotInUse		  :
        NSLog( "OSStatus error:  kAudioUnitErr_PropertyNotInUse");
        
    case kAudioUnitErr_Initialized			  :
        NSLog( "OSStatus error:  kAudioUnitErr_Initialized");
        
    case kAudioUnitErr_InvalidOfflineRender	  :
        NSLog( "OSStatus error:  kAudioUnitErr_InvalidOfflineRender");
        
    case kAudioUnitErr_Unauthorized			  :
        NSLog( "OSStatus error:  kAudioUnitErr_Unauthorized");
        
    default :
        NSLog("OSStatus error:  unrecognized type: %d", err)
    }
}