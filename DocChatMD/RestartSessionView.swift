//
//  RestartSessionView.swift
//  DocChatMD
//
//  Created by Carla Alexander on 2016-04-03.
//  Copyright © 2016 MagicNoodles. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

protocol RestartSessionViewDelegate: class {
    
    func restartSession()
}

class RestartSessionView: UIView {
    
    weak var delegate: RestartSessionViewDelegate?
    let resetButton = UIButton(frame: CGRectZero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .whiteColor()
        
        displayResetButton()
        layoutConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func displayResetButton() {
        
        resetButton.setImage(UIImage(named: "restart.png"), forState: .Normal)
        resetButton.setImage(UIImage(named: "restartHighlighted.png"), forState: .Highlighted)
        resetButton.addTarget(self, action: #selector(restartSession), forControlEvents: .TouchUpInside)
        self.addSubview(resetButton)
    }
    
    private func layoutConstraints() {
        
        resetButton.snp_makeConstraints { make in
            
            make.width.height.equalTo(80)
            make.centerX.centerY.equalTo(self)
        }
    }
    
    
    // MARK: Actions
    
    func restartSession() {

        // restart the OpenTok session
        delegate?.restartSession()
    }
}