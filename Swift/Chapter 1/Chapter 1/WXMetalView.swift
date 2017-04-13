//
//  WXMetalView.swift
//  Chapter 1
//
//  Created by williamxie on 12/04/2017.
//  Copyright © 2017 williamxie. All rights reserved.
//

import UIKit
import MetalKit

class WXMetalView: UIView {
    
    
    //http://stackoverflow.com/questions/39081027/how-do-you-override-layerclass-in-swift-3
    //
    override class var layerClass: AnyClass {
        return CAMetalLayer.self
    }
    
    
    func redraw(){
        
        
        
        
    }
    
    
    
}
