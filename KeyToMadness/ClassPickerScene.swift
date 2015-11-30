//
//  ClassPickerScene.swift
//  KeyToMadness
//
//  Created by Alexis Forbes on 11/13/15.
//  Copyright © 2015 Alexis Forbes. All rights reserved.
//

import SpriteKit


class ClassPickerScene: SKScene, UIPickerViewDelegate, UIPickerViewDataSource {
    var classes:Array<Array<AnyObject>> = Array<Array<AnyObject>>()
    var selectedClass:Int = 0
    var picker:UIPickerView = UIPickerView()
    
    override func didMoveToView(view: SKView) {
        let path = NSBundle.mainBundle().pathForResource("gameData", ofType: "plist")
        let properties = NSDictionary(contentsOfFile: path!)
        self.classes = properties!.objectForKey("Classes") as! Array<Array<AnyObject>>
        backgroundColor = UIColor.blackColor()
        
        let mainLBL:SKLabelNode = SKLabelNode(text: "Pick your class")
        mainLBL.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame)*0.8)
        mainLBL.fontSize = 75
        mainLBL.fontName = "AvenirNext-Bold"
        addChild(mainLBL)
        
        picker = UIPickerView(frame: CGRectMake(CGRectGetMidX(self.frame)-100, CGRectGetMaxY(self.frame)*0.2, 200, 400))
        picker.delegate = self
        picker.dataSource = self
        self.view?.addSubview(picker)
        
        let playBTN:SKLabelNode = SKLabelNode(text: "Start Game")
        playBTN.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame)*0.2)
        playBTN.fontSize = 65
        playBTN.name = "playBTN"
        playBTN.fontName = "AvenirNext-Bold"
        playBTN.fontColor = UIColor.greenColor()
        addChild(playBTN)
    }
    
    func numberOfComponentsInPickerView(colorPicker: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return classes.count
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("row selected: \(row)")
        selectedClass = row
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        var v:UIView
        if((view) != nil){
            v = view!
        }else{
            v = UIView()
            let classImage:UIImageView = UIImageView(frame: CGRectMake(0, 0, 50, 50))
            classImage.tag = 333
            classImage.backgroundColor = UIColor.orangeColor()
            let className:UILabel = UILabel(frame: CGRectMake(50,0,320,50))
            className.tag = 111
            className.textColor = UIColor.whiteColor()
            className.backgroundColor = UIColor.orangeColor()
            let line:UIView = UIView()
            line.frame = CGRectMake(0, 50, 200, 5)
            line.backgroundColor = UIColor.blackColor()
            let classStats:UILabel = UILabel(frame: CGRectMake(0,52,320,150))
            classStats.tag = 222
            classStats.numberOfLines = 6
            classStats.font = UIFont(name: "Courier New", size: 20)
            classStats.textColor = UIColor.whiteColor()
            v.addSubview(classImage)
            v.addSubview(className)
            v.addSubview(classStats)
            v.addSubview(line)
            v.translatesAutoresizingMaskIntoConstraints = true
            v.backgroundColor = UIColor.grayColor()
            v.layer.cornerRadius = 20;
            v.layer.masksToBounds = true;
        }
        let classImage:UIImageView = v.viewWithTag(333) as! UIImageView
        classImage.image = UIImage(named: "apple")
        
        let className:UILabel = v.viewWithTag(111) as! UILabel
        className.text = "  \(classes[row][0])"
        
        let classStats:UILabel = v.viewWithTag(222) as! UILabel
        classStats.text = "Strength: \(classes[row][1])\nDefense:  \(classes[row][2])\nStealth:  \(classes[row][3])\nEvasion:  \(classes[row][4])\nLuck:     \(classes[row][5])\nSanity:   \(classes[row][6])"
        
        v.sizeToFit()
        
        return v
    }
    
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 225
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first as UITouch!
        let location = touch.locationInNode(self)
        let touchedNode = self.nodeAtPoint(location)
        
        if touchedNode.name == "playBTN"{
            let transition = SKTransition.revealWithDirection(.Down, duration: 0.5)
            
            let nextScene = GameScene(fileNamed: "GameScene")
            nextScene!.scaleMode = .AspectFill
            nextScene?.playerClass = classes[selectedClass][0] as! String
            scene?.view?.presentScene(nextScene!, transition: transition)
            removeAllChildren()
            picker.removeFromSuperview()
        }
    }
    
    deinit {
        print("Class Picker Deleted")
    }
}