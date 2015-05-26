//
//  ViewController.swift
//  MusicSequenceAUGraph
//
//  Created by Gene De Lisa on 9/9/14.
//  Copyright (c) 2014 Gene De Lisa. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var picker: UIPickerView!
    
    @IBOutlet var loopSlider: UISlider!
    
    var gen = SoundGenerator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        picker.dataSource = self
        
        var len = gen.getTrackLength()
        loopSlider.maximumValue = Float(len)
        loopSlider.value = Float(len)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }

    @IBAction func play(sender: AnyObject) {
        gen.play()
    }
    
    @IBAction func stopPlaying(sender: AnyObject) {
        gen.stop()
    }
    
    @IBAction func loopSliderChanged(sender: AnyObject) {
        println("slider vlaue \(loopSlider.value)")
        gen.setTrackLoopDuration(loopSlider.value)
        
    }
    
    var GMDict:[String:UInt8] = [
        "Acoustic Grand Piano" : 0,
        "Bright Acoustic Piano" : 1,
        "Electric Grand Piano" : 2,
        "Honky-tonk Piano" : 3,
        "Electric Piano 1" : 4,
        "Electric Piano 2" : 5,
        "Harpsichord" : 6,
        "Clavi" : 7,
        "Celesta" : 8,
        "Glockenspiel" : 9,
        "Music Box" : 10,
        "Vibraphone" : 11,
        "Marimba" : 12,
        "Xylophone" : 13,
        "Tubular Bells" : 14,
        "Dulcimer" : 15,
        "Drawbar Organ" : 16,
        "Percussive Organ" : 17,
        "Rock Organ" : 18,
        "ChurchPipe" : 19,
        "Positive" : 20,
        "Accordion" : 21,
        "Harmonica" : 22,
        "Tango Accordion" : 23,
        "Classic Guitar" : 24,
        "Acoustic Guitar" : 25,
        "Jazz Guitar" : 26,
        "Clean Guitar" : 27,
        "Muted Guitar" : 28,
        "Overdriven Guitar" : 29,
        "Distortion Guitar" : 30,
        "Guitar harmonics" : 31,
        "JazzBass" : 32,
        "DeepBass" : 33,
        "PickBass" : 34,
        "FretLess" : 35,
        "SlapBass1" : 36,
        "SlapBass2" : 37,
        "SynthBass1" : 38,
        "SynthBass2" : 39,
        "Violin" : 40,
        "Viola" : 41,
        "Cello" : 42,
        "ContraBass" : 43,
        "TremoloStr" : 44,
        "Pizzicato" : 45,
        "Harp" : 46,
        "Timpani" : 47,
        "String Ensemble 1" : 48,
        "String Ensemble 2" : 49,
        "SynthStrings 1" : 50,
        "SynthStrings 2" : 51,
        "Choir" : 52,
        "DooVoice" : 53,
        "Voices" : 54,
        "OrchHit" : 55,
        "Trumpet" : 56,
        "Trombone" : 57,
        "Tuba" : 58,
        "MutedTrumpet" : 59,
        "FrenchHorn" : 60,
        "Brass" : 61,
        "SynBrass1" : 62,
        "SynBrass2" : 63,
        "SopranoSax" : 64,
        "AltoSax" : 65,
        "TenorSax" : 66,
        "BariSax" : 67,
        "Oboe" : 68,
        "EnglishHorn" : 69,
        "Bassoon" : 70,
        "Clarinet" : 71,
        "Piccolo" : 72,
        "Flute" : 73,
        "Recorder" : 74,
        "PanFlute" : 75,
        "Bottle" : 76,
        "Shakuhachi" : 77,
        "Whistle" : 78,
        "Ocarina" : 79,
        "SquareWave" : 80,
        "SawWave" : 81,
        "Calliope" : 82,
        "SynChiff" : 83,
        "Charang" : 84,
        "AirChorus" : 85,
        "fifths" : 86,
        "BassLead" : 87,
        "New Age" : 88,
        "WarmPad" : 89,
        "PolyPad" : 90,
        "GhostPad" : 91,
        "BowedGlas" : 92,
        "MetalPad" : 93,
        "HaloPad" : 94,
        "Sweep" : 95,
        "IceRain" : 96,
        "SoundTrack" : 97,
        "Crystal" : 98,
        "Atmosphere" : 99,
        "Brightness" : 100,
        "Goblin" : 101,
        "EchoDrop" : 102,
        "SciFi effect" : 103,
        "Sitar" : 104,
        "Banjo" : 105,
        "Shamisen" : 106,
        "Koto" : 107,
        "Kalimba" : 108,
        "Scotland" : 109,
        "Fiddle" : 110,
        "Shanai" : 111,
        "MetalBell" : 112,
        "Agogo" : 113,
        "SteelDrums" : 114,
        "Woodblock" : 115,
        "Taiko" : 116,
        "Tom" : 117,
        "SynthTom" : 118,
        "RevCymbal" : 119,
        "FretNoise" : 120,
        "NoiseChiff" : 121,
        "Seashore" : 122,
        "Birds" : 123,
        "Telephone" : 124,
        "Helicopter" : 125,
        "Stadium" : 126,
        "GunShot" : 127
    ]


}

extension ViewController: UIPickerViewDataSource {
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 128
    }
}

extension ViewController: UIPickerViewDelegate {
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {

        var u = UInt8(row)
        for (k,v) in GMDict {
            if v == UInt8(row) {
                return k
            }
        }
        return nil
    }

    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        gen.loadSF2Preset(UInt8(row))
    }
    
}
