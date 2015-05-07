//
//  KSRFilterBar.swift
//  Kosher GPS
//
//  Created by Moshe Berman on 1/28/15.
//  Copyright (c) 2015 Moshe. All rights reserved.
//

import UIKit

@IBDesignable class FilterBar : UIControl {
    
    //  MARK: - Selected Segment Index
    
    @IBInspectable var selectedSegmentIndex : NSInteger = 0 {
        didSet {
            
            //
            //  Ensure that we can't go out of bounds
            //
            
            if selectedSegmentIndex >= self.titles.count {
                selectedSegmentIndex = self.titles.count - 1
            }
            
            if selectedSegmentIndex < 0 {
                selectedSegmentIndex = 0
            }
        }
    }
    
    //  MARK: - Border Color
    
    @IBInspectable var primaryColor : UIColor = UIColor.whiteColor()
    
    
    //  MARK: - Buttons and Titles
    
    var buttons : Array<UIButton> = Array()
    
    var titles : Array<String> = [] {
        didSet {
            self.layoutButtons()
        }
    }
    
    //  MARK: - Fonts
    
    let buttonFont : UIFont? = UIFont(name: "Avenir-Light", size: 14)
    let buttonSelectedFont : UIFont? = UIFont(name: "Avenir-Heavy", size: 16)
    
    //
    //  MARK: - Initializers
    //
    
    init() {
        
        self.titles = ["Button A", "Button B", "Button C"]
        super.init(frame: CGRectZero)
    }
    
    required init(coder aDecoder: NSCoder) {
        self.titles = ["Button A", "Button B", "Button C"]
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        self.titles = ["Button A", "Button B", "Button C"]
        super.init(frame: CGRectZero)
    }
    
    //
    //  MARK: - Intrinsic Content Size
    //
    
    override func intrinsicContentSize() -> CGSize {
        
        var intrinsicWidth : CGFloat = CGRectGetWidth(UIScreen.mainScreen().bounds) + 2.0
        
        if let width : CGFloat = self.superview?.bounds.width {
            intrinsicWidth = width + 2.0
        }
        
        return CGSizeMake(intrinsicWidth, 44.0)
    }
    
    //
    //  MARK: - Lay out the buttons
    //
    
    //
    //  This function handles the layout of the buttons
    //
    
    func layoutButtons() {
        
        if self.superview == nil {
            return
        }
        
        //  Clean up the old buttons
        
        self.buttons.map { $0.removeFromSuperview() }
        self.buttons.removeAll(keepCapacity: false)
        
        //  If there are titles, create buttons and display them.
        
        for title in self.titles {
            
            //  Cast the title...
            let buttonTitle : String = title as String
            
            //  Create a button
            let button : UIButton = UIButton.buttonWithType(.Custom) as! UIButton
            
            //  Set the button title & colors
            button.setTitle(buttonTitle, forState: .Normal)
            button.setTitleColor(self.primaryColor, forState: .Normal)
            button.backgroundColor = UIColor.clearColor()
            button.titleLabel?.font = self.buttonFont
            
            //  Wire up the button to an action
            button.addTarget(self, action: "buttonWasTapped:", forControlEvents: .TouchUpInside)
            
            //  Prepare the button for constraints
            button.setTranslatesAutoresizingMaskIntoConstraints(false)
            
            //  Grab the previous button to anchor the new button against.
            var leftItem : AnyObject? = self.buttons.last;
            var attribute : NSLayoutAttribute = .Right
            
            if leftItem == nil {
                leftItem = self
                attribute = .Left
            }
            
            //  Create constraints
            let x : NSLayoutConstraint = NSLayoutConstraint(item: button, attribute: .Left, relatedBy: .Equal, toItem: leftItem, attribute: attribute, multiplier: 1.0, constant: 0)
            let y : NSLayoutConstraint = NSLayoutConstraint(item: button, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0)
            let h : NSLayoutConstraint = NSLayoutConstraint(item: button, attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: 1.0, constant: 0)
            let w : NSLayoutConstraint = NSLayoutConstraint(item: button, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: self.buttonWidth())
            
            //  Now add the button to the array and view hierarchy.
            self.buttons.append(button)
            self.addSubview(button)
            
            //  Install the constraints
            self.addConstraints([h, w, x, y])
        }

        
        //  Style the appropriate button.
        
        let newButton : UIButton = self.buttons[self.selectedSegmentIndex]
        
        newButton.titleLabel?.font = self.buttonSelectedFont
    }
    
    //
    //  MARK: - Button Taps
    //
    
    func buttonWasTapped(button:UIButton) {
        
        //  Grab the button's title label
        
        if let titleLabel = button.titleLabel {
            
            //  Read out the title text and use it to get the segment
            let title : String = titleLabel.text!
            self.selectedSegmentIndex = self.indexForButtonTitle(title)
            
            for b : UIButton in self.buttons {
                if b.titleLabel?.text! == title {
                    b.titleLabel?.font = self.buttonSelectedFont
                }
                else
                {
                    b.titleLabel?.font = self.buttonFont
                }
            }
        }
        
        //  Send the control event to listeners
        self.sendActionsForControlEvents(.TouchUpInside)
    }
    
    //
    //  MARK: - Helpers
    //
    
    //
    //  Find the index of the button that was tapped
    //
    //  :param: title The title that we want to convert into an index.
    //
    //  :returns: An integer representing the index.
    //
    
    func indexForButtonTitle(title: String) -> NSInteger {
        
        var index : NSInteger = -1
        
        for var i = 0; i < self.titles.count; ++i {
            if title == self.titles[i] {
                index = i
                break
            }
        }
        
        return index
    }
    
    //
    //  Calculate the appropriate width for the buttons.
    //
    //  :return: A CGFloat that's the width of a button.
    //
    
    func buttonWidth() -> CGFloat {
        
        var width = CGRectGetWidth(UIScreen.mainScreen().bounds) / CGFloat(self.titles.count)
        
        if self.titles.count == 0 {
            width = CGRectGetWidth(self.bounds)
        }
        
        return width
    }
    
    //
    //  Returns the constraint matching the identifier.
    //
    //  :param: identifier The identifier to search for.
    //
    //  :return; The first layout constraint whose identifier is equal to the supplied identifier.
    //
    
    func layoutConstraintWithIdentifier(identifier: String) -> NSLayoutConstraint? {
        
        var constraint : NSLayoutConstraint? = nil
        
        let constraints : Array = self.constraints() as Array
        
        for c in constraints {
            if let testConstraint = c as? NSLayoutConstraint {
                if testConstraint.identifier == identifier {
                    constraint = testConstraint
                }
            }
        }
        
        return constraint
    }
    
    //
    //
    //
    
    override func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview)
        
        self.backgroundColor = self.primaryColor.colorWithAlphaComponent(0.1)
        
        self.layer.borderColor = self.primaryColor.CGColor
        self.layer.borderWidth = 0.5
    }
    
    //
    //  MARK: - View Lifecycle
    //
    
    override func didMoveToSuperview() {
        
        super.didMoveToSuperview()
        
        if let superview = self.superview
        {
        
            let centerX : NSLayoutConstraint = NSLayoutConstraint(item: self, attribute: .CenterX, relatedBy: .Equal, toItem: superview, attribute: .CenterX, multiplier: 1.0, constant: 0);
            let width : NSLayoutConstraint = NSLayoutConstraint(item: self, attribute: .Width, relatedBy: .Equal, toItem: superview, attribute: .Width, multiplier: 1.0, constant: 2)
            
            superview.addConstraints([centerX, width])
        }
        else
        {
            NSLog("Failed to find a superview. Weird.")
        }
        
        //  Lay out the buttons
        self.setNeedsLayout()
    }
    
    //
    //  MARK: - Layout Subviews
    //
    
    override func layoutSubviews() {
        
        self.layoutButtons()
        
        super.layoutSubviews()
    }
}