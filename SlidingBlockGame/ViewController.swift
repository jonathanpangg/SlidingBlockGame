//
//  ViewController.swift
//  sliding_blocks_game
//
//  Created by Jonathan Pang on 11/3/20.
//

import UIKit
class ViewController: UIViewController {
    var touched = status.no // sees if the user touches the screen
    var button  = UIButton() // randomize button
    let test    = sliding_game() // the game
    
    // enum for the status of the user pressing the screen
    enum status {
        case yes, no
    }
    
    // user touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // allows one touch per action
        if (touched == status.no) {
            for touch in (touches) {
                let location = touch.location(in: self.view)
                touched = status.yes
                
                // determines the direction
                if (location.x < UIScreen.main.bounds.width/2 - 12.5 && location.x > UIScreen.main.bounds.width/2 - 62.5 && location.y < UIScreen.main.bounds.height/8 * 7 + 12.5 && location.y > UIScreen.main.bounds.height/8 * 7 - 12.5) {
                    test.move_blocks(direction: "left")
                    helper_for_touch()
                    
                }
                else if (location.x > UIScreen.main.bounds.width/2 + 12.5 && location.x < UIScreen.main.bounds.width/2 + 62.5 && location.y < UIScreen.main.bounds.height/8 * 7 + 12.5 && location.y > UIScreen.main.bounds.height/8 * 7 - 12.5) {
                    test.move_blocks(direction: "right")
                    helper_for_touch()
                }
                else if (location.x > UIScreen.main.bounds.width/2 - 12.5 && location.x < UIScreen.main.bounds.width/2 + 12.5 && location.y < UIScreen.main.bounds.height/8 * 7 - 12.5 && location.y > UIScreen.main.bounds.height/8 * 7 - 62.5) {
                    test.move_blocks(direction: "up")
                    helper_for_touch()
                }
                else if (location.x > UIScreen.main.bounds.width/2 - 12.5 && location.x < UIScreen.main.bounds.width/2 + 12.5 && location.y < UIScreen.main.bounds.height/8 * 7 + 62.5 && location.y > UIScreen.main.bounds.height/8 * 7 + 12.5) {
                    test.move_blocks(direction: "down")
                    helper_for_touch()
                }
            }
        }
        else {
            touched = status.no
        }
    }
    
    // helper function for the touch function
    func helper_for_touch() {
        if let view_with_tag = self.view.viewWithTag(1) {
            view_with_tag.removeFromSuperview()
        }
        test.add_everything()
        let temp             = test.get_under_view()
        temp.tag             = 1
        view.addSubview(temp)
        touched              = status.no
        test.openpop(nil)
    }
    
    // sets up the randomize button
    func setup_button() {
        button                    = UIButton(frame: CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 4 * 3, width: 150, height: 30))
        button.center             = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 16 * 11)
        button.setTitle("Randomize", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.borderWidth  = 1.5
        button.layer.cornerRadius = CGFloat(150 * (sin (Double.pi / 16) / 2))
        button.tag                = 0
        button.addTarget(self, action: #selector(randomize), for: .touchUpInside)
    }
    
    // randomizes the blocks
    @objc func randomize() {
        // removes the randomize button to update the view later
        if let view_with_tag = self.view.viewWithTag(1) {
            view_with_tag.removeFromSuperview()
        }
        
        // disables the randomize button
        button.isEnabled     = false
        
        // fields for the randomize function
        var values: [Int]    = [0, 0, 0, 0, 0, 0, 0, 0, 0] // the picture files
        var i                = 0 // index of values when random is not in values
        
        // gets random numbers for values
        while i < 9 {
            let random    = Int.random(in: 1...9)
            if values.contains(random) {
                i -= 1
            }
            else {
                values[i] = random
            }
            i += 1
        }
        
        // counts inversions
        var inversions = 0
        var y          = 0
        while y < values.count-1 {
            if values[y] != 9 {
                var z  = y + 1
                while z < values.count {
                    if values[y] > values[z] && values[z] != 9 {
                        inversions+=1
                    }
                    z+=1
                }
            }
            y+=1
        }
        
        // if inversions is even, passes through
        if inversions % 2 == 0 {
            for i in 0..<test.list_of_layers.count {
                let layer              = CALayer()
                layer.contents         = UIImage(named: "Number\(values[i])")?.cgImage
                layer.frame            = CGRect(x: test.pos_of_blocks[i].x, y: test.pos_of_blocks[i].y, width: 75, height: 75)
                layer.position         = CGPoint(x: test.pos_of_blocks[i].x, y: test.pos_of_blocks[i].y)
                layer.borderWidth      = 1.5
                test.list_of_layers[i] = layer
            }
            test.add_everything()
            let temp                   = test.get_under_view()
            temp.tag                   = 1
            view.addSubview(temp)
            button.isEnabled           = true
        }
        
        // if inversions is odd, goes to recursion
        else {
            randomize()
        }
    }
    
    // overload
    override func viewDidLoad() {
        super.viewDidLoad()
        // sets up the randomize button
        setup_button()
        view.addSubview(button)
        
        // sets up the inital screen
        test.input_pos_of_blocks()
        test.create_blocks()
        test.create_controllers()
        let temp = test.get_under_view()
        temp.tag = 1
        view.addSubview(temp)
    }
}

// class for the game
class sliding_game {
    var under_view         : UIView // UIView of the blocks
    var pos_of_blocks      : [CGPoint] // list of positions of the blocks
    var list_of_layers     : [CALayer] // list of layers
    var list_of_controllers: [CALayer] // list of controllers
    
    // initializer
    init () {
        under_view          = UIView()
        pos_of_blocks       = []
        list_of_layers      = []
        list_of_controllers = []
    }

    // returns under_view
    func get_under_view() -> UIView {
        return under_view
    }
    
    // puts points of the blocks
    func input_pos_of_blocks() {
        for x in 0...2 {
            for y in 0...2 {
                pos_of_blocks.append(CGPoint(x: UIScreen.main.bounds.width / 2 - 75 + (75 * CGFloat(y)), y: UIScreen.main.bounds.height / 2 - 75 + (75 * CGFloat(x))))
            }
        }
    }
    
    // puts the blocks on the screen
    func create_blocks() {
        for i in 1...9 {
            // creates image
            let picture_file  = "Number\(i)"
            let image         = UIImage(named: picture_file)?.cgImage
            let layer         = CALayer()
            layer.contents    = image
            layer.frame       = CGRect(x: pos_of_blocks[i - 1].x, y: pos_of_blocks[i - 1].y, width: 75, height: 75)
            layer.position    = CGPoint(x: pos_of_blocks[i - 1].x, y: pos_of_blocks[i - 1].y)
            layer.borderWidth = 1.5
            
            // adds to list_of_layers
            list_of_layers.append(layer)
            
            // adds to under_view
            add_layers()
        }
    }
    
    // adds to under_view
    func add_layers() {
        under_view = UIView()
        for layer in list_of_layers {
            under_view.layer.addSublayer(layer)
        }
    }
    
    // puts the controllers on the screen
    func create_controllers() {
        // creates left and right controllers
        let left_and_right             = CALayer()
        left_and_right.frame           = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 8 * 7, width: 135, height: 35)
        left_and_right.position        = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 8 * 7)
        left_and_right.backgroundColor = UIColor.darkBlue.cgColor
        
        // creates up and down controllers
        let up_and_down                = CALayer()
        up_and_down.frame              = CGRect(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/8 * 7, width: 35, height: 135)
        up_and_down.position           = CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/8 * 7)
        up_and_down.backgroundColor    = UIColor.darkBlue.cgColor
        
        // adds to list_of_controllers
        list_of_controllers.append(left_and_right)
        list_of_controllers.append(up_and_down)
        
        // adds to under_view
        add_controllers()
    }
    
    // adds to under_view
    func add_controllers() {
        for controller in list_of_controllers {
            under_view.layer.addSublayer(controller)
        }
    }
    
    // adds layers and controllers
    func add_everything() {
        add_layers()
        add_controllers()
    }
    
    // finds the white block
    func find_white_space() -> Int {
        var spacepos = 0
        outer:
            for layer in list_of_layers {
            if(layer.contents as! CGImage == (UIImage(named: "Number9")?.cgImage)!){
                    break outer
                }
                spacepos+=1
            }
        return spacepos
    }
    
    // moves the blocks
    func move_blocks(direction: String) {
        switch direction {
        // makes the block go up
        case "up":
            let pos                              = find_white_space()
            if(pos < 6) {
                let temp_layer                   = list_of_layers[pos]
                list_of_layers[pos]              = list_of_layers[pos + 3]
                list_of_layers[pos + 3]          = temp_layer
                
                let temp_pos                     = list_of_layers[pos].position
                list_of_layers[pos].position     = list_of_layers[pos + 3].position
                list_of_layers[pos + 3].position = temp_pos
            }
            add_everything()
            openpop(nil)
            break
        
        // makes the block go down
        case "down":
            let pos                              = find_white_space()
            if(pos >= 3) {
                let temp_layer                   = list_of_layers[pos]
                list_of_layers[pos]              = list_of_layers[pos - 3]
                list_of_layers[pos - 3]          = temp_layer
                
                let temp_pos                     = list_of_layers[pos].position
                list_of_layers[pos].position     = list_of_layers[pos - 3].position
                list_of_layers[pos - 3].position = temp_pos
            }
            add_everything()
            openpop(nil)
            break
        
        // makes the block go left
        case "left":
            let pos                              = find_white_space()
            if(pos % 3 != 2) {
                let temp_layer                   = list_of_layers[pos]
                list_of_layers[pos]              = list_of_layers[pos + 1]
                list_of_layers[pos + 1]          = temp_layer
                
                let temp_pos                     = list_of_layers[pos].position
                list_of_layers[pos].position     = list_of_layers[pos + 1].position
                list_of_layers[pos + 1].position = temp_pos
            }
            add_everything()
            openpop(nil)
            break
            
        // makes the block go right
        case "right":
            let pos                              = find_white_space()
            if(pos % 3 != 0) {
                let temp_layer                   = list_of_layers[pos]
                list_of_layers[pos]              = list_of_layers[pos - 1]
                list_of_layers[pos - 1]          = temp_layer
                
                let temp_pos                     = list_of_layers[pos].position
                list_of_layers[pos].position     = list_of_layers[pos - 1].position
                list_of_layers[pos - 1].position = temp_pos
            }
            add_everything()
            openpop(nil)
            break
            
        default:
            break
        }
    }
    
    // determines if the game is won
    func if_won() -> Bool {
        for i in 1...9 {
            if (list_of_layers[i - 1].contents as! CGImage != (UIImage(named: "Number\(i)")?.cgImage)!) {
                return false
            }
        }
        return true
    }
    
    // sets the win message
    func openpop(_ sender: Any?){
        if (if_won()) {
            let label       = UILabel(frame: CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 4, width: 100, height: 50))
            label.center    = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 16 * 5)
            label.text      = "You Won"
            label.font      = UIFont(name: label.font.fontName, size: 25)
            label.textColor = UIColor.black
            under_view.addSubview(label)
        }
    }
}

// extension for more colors
extension UIColor {
    class var darkBlue: UIColor {
        return #colorLiteral(red: 0, green: 0.2982482612, blue: 0.5693374872, alpha: 1)
    }
}
