//
//  SettingsControl.swift
//  DocChatMD
//
//  Created by Carla Alexander on 2016-03-31.
//  Copyright © 2016 MagicNoodles. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

protocol SettingsControlDelegate: class {
    
    func didSelectButtonOne()
    func didSelectButtonTwo()
    func didSelectButtonThree()
}

enum SettingsControlButtonPosition {
    
    case Main
    case TopRight
    case BottomLeft
    case TopLeft
}

final class SettingsControl: UIView {
    
    private var controlView: UIView?
    weak var delegate: SettingsControlDelegate?
    
    // settings UI
    let mainButton              = UIButton(frame: CGRectZero)
    private let buttonOne       = UIButton(frame: CGRectZero)   // publisher audio/mute
    private let buttonTwo       = UIButton(frame: CGRectZero)   // front/back camera
    private let buttonThree     = UIButton(frame: CGRectZero)   // end video/chat session
    private var buttonsHidden   = true
    
    private var buttonOneTopConstraint: Constraint?
    private var buttonTwoLeftConstraint: Constraint?
    private var buttonTwoTopConstraint: Constraint?
    private var buttonThreeLeftConstraint: Constraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func displaySettingsButtonsInView(view: UIView) {
        
        controlView = view
        
        buttonOne.alpha = 0
        buttonOne.addTarget(self, action: #selector(buttonOneAction), forControlEvents: .TouchUpInside)
        controlView!.addSubview(buttonOne)
        
        buttonTwo.alpha = 0
        buttonTwo.addTarget(self, action: #selector(buttonTwoAction), forControlEvents: .TouchUpInside)
        controlView!.addSubview(buttonTwo)
        
        buttonThree.alpha = 0
        buttonThree.addTarget(self, action: #selector(buttonThreeAction), forControlEvents: .TouchUpInside)
        controlView!.addSubview(buttonThree)
        
        mainButton.addTarget(self, action: #selector(revealSettingsButtons), forControlEvents: .TouchUpInside)
        mainButton.hidden = false
        controlView!.addSubview(mainButton)
    }
    
    func setButtonImageForPosition(image: UIImage, buttonPosition: SettingsControlButtonPosition, state: UIControlState) {
        
        switch buttonPosition {
            
        case .Main:
            self.mainButton.setImage(image, forState: state)
        case .TopRight:
            self.buttonOne.setImage(image, forState: state)
        case .BottomLeft:
            self.buttonTwo.setImage(image, forState: state)
        case .TopLeft:
            self.buttonThree.setImage(image, forState: state)
        }
    }
    
    func resetButtonConstraints() {
        
        buttonOne.snp_removeConstraints()
        buttonTwo.snp_removeConstraints()
        buttonThree.snp_removeConstraints()
        
        buttonOne.snp_makeConstraints { make in
            
            make.left.right.width.height.equalTo(mainButton)
            self.buttonOneTopConstraint = make.top.equalTo(mainButton).offset(0).constraint
        }
        
        buttonTwo.snp_makeConstraints { make in
            
            make.bottom.width.equalTo(mainButton)
            self.buttonTwoLeftConstraint    = make.left.equalTo(mainButton).offset(0).constraint
            self.buttonTwoTopConstraint     = make.top.equalTo(mainButton).offset(0).constraint
        }
        
        buttonThree.snp_makeConstraints { make in
            
            make.top.bottom.width.equalTo(mainButton)
            self.buttonThreeLeftConstraint = make.left.equalTo(mainButton).offset(0).constraint
        }
        
        buttonsHidden = true
    }

    private func animateButtonConstraintsInView(areButtonsHidden: Bool, view: UIView) {
        
        let buttonOffset: CGFloat   = 10
        let leftOffset              = self.mainButton.frame.size.width + buttonOffset

        if areButtonsHidden == true {
            
            // update constraints
            self.buttonOneTopConstraint!.updateOffset(-leftOffset)
            self.buttonTwoLeftConstraint!.updateOffset(-leftOffset)
            self.buttonTwoTopConstraint!.updateOffset(-(leftOffset*2))
            self.buttonThreeLeftConstraint!.updateOffset(-leftOffset)
            view.setNeedsUpdateConstraints()
            
            UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
                
                view.layoutIfNeeded()
                self.buttonTwo.alpha    = 1
                self.buttonOne.alpha    = 1
                self.buttonThree.alpha  = 1
                self.buttonsHidden      = false
                
                }, completion: nil)
            
        } else {
            
            resetButtonConstraints()
            view.setNeedsUpdateConstraints()
            
            UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
                
                view.layoutIfNeeded()

                self.buttonTwo.alpha    = 0
                self.buttonOne.alpha    = 0
                self.buttonThree.alpha  = 0
                
            }, completion: nil)
        }
    }
    
    
    // MARK: Actions
    
    func revealSettingsButtons() {
        
        mainButton.removeTarget(self, action: #selector(revealSettingsButtons), forControlEvents: .TouchUpInside)
        mainButton.addTarget(self, action: #selector(hideSettingsButtons), forControlEvents: .TouchUpInside)
        animateButtonConstraintsInView(buttonsHidden, view: controlView!)
    }
    
    func hideSettingsButtons() {
        
        animateButtonConstraintsInView(buttonsHidden, view: controlView!)
        mainButton.removeTarget(self, action: #selector(hideSettingsButtons), forControlEvents: .TouchUpInside)
        mainButton.addTarget(self, action: #selector(revealSettingsButtons), forControlEvents: .TouchUpInside)
    }
    
    func buttonOneAction(sender: UIButton) {
        
        delegate?.didSelectButtonOne()
    }
    
    func buttonTwoAction(sender: UIButton) {
        
        delegate?.didSelectButtonTwo()
    }
    
    func buttonThreeAction(sender: UIButton) {
        
        delegate?.didSelectButtonThree()
    }
}