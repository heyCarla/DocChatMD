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
    
    func buttonOneAction()
    func buttonTwoAction()
    func buttonThreeAction()
}

final class SettingsControl: UIView {
    
    private var controlView: UIView?
    weak var delegate: SettingsControlDelegate?
    
    // settings UI
    let mainButton              = UIButton(frame: CGRectZero)
    let buttonOne               = UIButton(frame: CGRectZero)   // publisher buttonOne/mute
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
    
    func displaySettingsButtonsInView(view: UIView?) {
        
        guard let currentView = view else {
            print("view does not exist")
            return
        }
        
        controlView = currentView
        
        buttonOne.setImage(UIImage(named: "mute.png"), forState: .Normal)
        buttonOne.setImage(UIImage(named: "muteHighlighted.pnt"), forState: .Highlighted)
        buttonOne.alpha = 0
        buttonOne.addTarget(self, action: #selector(buttonOneAction), forControlEvents: .TouchUpInside)
        controlView!.addSubview(buttonOne)
        
        buttonTwo.setImage(UIImage(named: "rotate.png"), forState: .Normal)
        buttonTwo.setImage(UIImage(named: "rotateHighlighted.png"), forState: .Highlighted)
        buttonTwo.alpha = 0
        buttonTwo.addTarget(self, action: #selector(buttonTwoAction), forControlEvents: .TouchUpInside)
        controlView!.addSubview(buttonTwo)
        
        buttonThree.setImage(UIImage(named: "endChat.png"), forState: .Normal)
        buttonThree.setImage(UIImage(named: "endChatHighlighted.png"), forState: .Highlighted)
        buttonThree.alpha = 0
        buttonThree.addTarget(self, action: #selector(buttonThreeAction), forControlEvents: .TouchUpInside)
        controlView!.addSubview(buttonThree)
        
        mainButton.setImage(UIImage(named: "settings.png"), forState: .Normal)
        mainButton.setImage(UIImage(named: "settingsHighlighted.png"), forState: .Highlighted)
        mainButton.addTarget(self, action: #selector(revealSettingsButtons), forControlEvents: .TouchUpInside)
        controlView!.addSubview(mainButton)
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
            
            make.top.bottom.width.equalTo(mainButton)
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
        
        delegate?.buttonOneAction()        
    }
    
    func buttonTwoAction(sender: UIButton) {
        
        delegate?.buttonTwoAction()
    }
    
    func buttonThreeAction(sender: UIButton) {
        
        delegate?.buttonThreeAction()
    }
}