//
//  MainMenuViewController.swift
//  KeyToMadness
//
//  Created by Alexis Forbes on 10/8/15.
//  Copyright © 2015 Alexis Forbes. All rights reserved.
//

import UIKit
import SpriteKit

class MainMenuViewController: UIViewController {
    
    @IBOutlet weak var playMusic: UISwitch!
    @IBOutlet weak var playSounds: UISwitch!
    @IBOutlet weak var leftyMode: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(false, forKey: "Music")
        playMusic.on = defaults.boolForKey("Music")
        
        defaults.setBool(false, forKey: "Sounds")
        playSounds.on = defaults.boolForKey("Sounds")
        
        defaults.setBool(false, forKey: "Lefty")
        leftyMode.on = defaults.boolForKey("Lefty")
    }
    
    @IBAction func playMusicChange(sender: AnyObject) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(playMusic.on, forKey: "Music")
    }
    
    @IBAction func playSoundsChange(sender: AnyObject) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(playSounds.on, forKey: "Sounds")
    }
    
    @IBAction func leftyModeChange(sender: AnyObject) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(leftyMode.on, forKey: "Lefty")
    }
}
