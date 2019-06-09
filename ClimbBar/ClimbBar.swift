//
//  ClimbBar.swift
//  ClimbBar
//
//  Created by Shichimitoucarashi on 5/8/19.
//  Copyright © 2019 Shichimitoucarashi. All rights reserved.
//

import UIKit.UIGestureRecognizer

public class ClimbBar: NSObject {
    
    var configurations: Configuration!
    var scrollable: UIScrollView!
    var stateReducer: ((State) -> Void)!
    var beginDrag: CGFloat = 0
    var isEndDrag: Bool  = false
    var previousState: CGFloat!

    public var defaultContentOffset: CGPoint = .zero
    public var defaultInset:UIEdgeInsets = .zero

    public struct State {
        public var originY: CGFloat
        public var alpha: CGFloat
        public var distance: CGFloat
        
        init(originY: CGFloat,
             alpha: CGFloat,
             distance: CGFloat) {
            self.originY = originY
            self.alpha = alpha
            self.distance = distance
        }
    }
    
    public init(configurations: Configuration,
         scrollable: UIScrollView,
         state: @escaping (State) -> Void) {
        
        super.init()
        
        self.configurations = configurations
        self.scrollable = scrollable
        self.stateReducer = state
        
        scrollable.panGestureRecognizer.addTarget(self, action: #selector(handleGesture(_:)))

        self.setConfiguration(conf: configurations)
    }
    
    private func setConfiguration (conf: Configuration) {
        self.previousState = conf.compact
        self.defaultContentOffset = CGPoint(x: 0, y: -conf.topDistance)
        self.defaultInset = UIEdgeInsets(top: conf.topDistance,
                                         left: self.scrollable.contentInset.left,
                                         bottom: self.scrollable.contentInset.bottom,
                                         right: self.scrollable.contentInset.right)
        
        if self.scrollable.contentInsetAdjustmentBehavior == .never {
            self.setScrollable(contentInset: self.defaultInset, contentOffset: self.defaultContentOffset)
        }
    }
    
    private func setScrollable(contentInset: UIEdgeInsets,
                               contentOffset: CGPoint) {
        scrollable.contentInset = contentInset
        scrollable.contentOffset = contentOffset
    }

    func adjustOffset(contentOffset: CGPoint) {
        
        let calculate = Calculate(conf: self.configurations,
                                 begin: beginDrag,
                                 offset: self.scrollable.contentOffset,
                                 origin: self.scrollable.frame.origin)
        
        if contentOffset.y <= -self.configurations.normal {
            guard !self.isEndDrag == false else { return }
            self.scrollable.setContentOffset(self.defaultContentOffset, animated: true)
            self.scrollable.contentInset = self.defaultInset
            self.stateReducer(State(originY: calculate.originY, alpha: calculate.alpha, distance: calculate.distance))
            self.scrollable.contentInset.top = calculate.height
        }
    }
    
    @objc private func handleGesture (_ state: UIGestureRecognizer) {
        
        switch state.state {
        case .began:
            self.isEndDrag = false
            self.beginDrag = self.scrollable.contentOffset.y
            self.configurations.currentStatus = previousState
            break
        case .changed:
            
            if !self.isEndDrag {
                
                let calculate = Calculate(conf: self.configurations,
                                           begin: beginDrag,
                                           offset: self.scrollable.contentOffset,
                                           origin: self.scrollable.frame.origin)
                
                
                stateReducer(State(originY: calculate.originY,
                                   alpha: calculate.alpha,
                                   distance: calculate.distance))
                
                self.previousState = calculate.originY
            }
            
            break
        case .ended:
            self.isEndDrag = true
            self.adjustOffset(contentOffset: scrollable.contentOffset)
            break
        default: break
            
        }
    }
}
