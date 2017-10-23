//
//  ScaleStoryboardSegue.swift
//  EventAggregator
//
//  Created by Egor Bryzgalov on 19.10.2017.
//  Copyright © 2017 Egor Bryzgalov. All rights reserved.
//

import UIKit

class ScaleStoryboardSegue: UIStoryboardSegue {

    override func perform() {
    scale()
    }
    
    func scale() {
        let toRootVC = self.destination
        let fromLoadVC = self.source
        let containerView = fromLoadVC.view.superview
        let originalCenter = fromLoadVC.view.center
        toRootVC.view.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
        toRootVC.view.center = originalCenter
        containerView?.addSubview(toRootVC.view)
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            toRootVC.view.transform = CGAffineTransform.identity
        }, completion: { success in
            fromLoadVC.present(toRootVC, animated: true, completion: nil)
        })
        
    }
}
