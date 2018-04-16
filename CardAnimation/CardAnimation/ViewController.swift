//
//  ViewController.swift
//
//
//  Created by Sridhar iOS on 14/04/18.
//  Copyright © 2018 . All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var cardView:UIView!
    @IBOutlet weak var firstView:UIView!
    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var bgImageView: UIImageView!
    
    var isDragStarted = false
    var isDraggingUp = false
    
    var cardHeight:CGFloat = 0
    var imageHeight:CGFloat = 0
    
    var currentImageHeight:CGFloat = 0
    
    var startTouchPoint:CGPoint = CGPoint.init()
    var maximumCardViewY:CGFloat = 0
    var minimumCardViewY:CGFloat = 0
    
    var totalDistanceMoved:CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        cardHeight = cardView.frame.height
        imageHeight = bgImageView.frame.height
        
        currentImageHeight = imageHeight
        
        minimumCardViewY = view.frame.height - cardHeight - CGFloat(100.0)
        maximumCardViewY = view.frame.height - firstView.frame.height - 100
        
       
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func closeCardPressed(_ sender: Any) {
        closeCard()
    }
    
}

extension ViewController{
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchPoint = touch.location(in: view)
            if let touchedView = view.hitTest(touchPoint, with: event), touchedView.tag == 2{
                isDragStarted = true
                startTouchPoint = touchPoint
            }else {
                next?.becomeFirstResponder()
                isDragStarted = false
            }
        }else {
            isDragStarted = false
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isDragStarted {
            
            if let touch = touches.first {
                let touchPoint = touch.location(in: view)
                let diffY = (touchPoint.y - startTouchPoint.y) / 100
               
                isDraggingUp = diffY < 0
                
                var y = cardView.frame.origin.y + diffY
                
                currentImageHeight = currentImageHeight + diffY

                
                if y > maximumCardViewY {
                    y = maximumCardViewY
                    currentImageHeight = imageHeight
                }
                if y < minimumCardViewY {
                    y = minimumCardViewY
                    currentImageHeight = imageHeight - 200
                }
                
                var cardMovement = (y - startTouchPoint.y) / 2
                
                if !isDraggingUp{
                    cardMovement = 0
                }else {
                    changeAllSubviewsFrame(myView: secondView, movement: diffY)
                }
                
                
                cardView.frame = CGRect.init(x: cardView.frame.origin.x, y: y, width: view.frame.width, height: cardHeight)
                firstView.bounds = CGRect.init(x: 0, y: cardMovement, width: firstView.frame.width, height: firstView.frame.height)
                
                bgImageView.frame = CGRect.init(x: bgImageView.frame.origin.x, y: bgImageView.frame.origin.y, width: bgImageView.frame.width, height:currentImageHeight)
            }
            
            
            
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if isDragStarted {
            isDragStarted = false
            
            UIView.beginAnimations("move", context: nil)
            UIView.setAnimationDuration(0.5)
            if isDraggingUp {
                cardView.frame = CGRect.init(x: 0, y: (view.frame.height - 100 - cardHeight), width: view.frame.width, height: cardHeight)
                bgImageView.frame = CGRect.init(x: bgImageView.frame.origin.x, y: bgImageView.frame.origin.y, width: bgImageView.frame.width, height: imageHeight - 200)
                currentImageHeight = imageHeight - 200
                
            }else {
                cardView.frame = CGRect.init(x: 0, y: (view.frame.height - 100 - firstView.frame.height), width: view.frame.width, height: cardHeight)
               bgImageView.frame = CGRect.init(x: bgImageView.frame.origin.x, y: bgImageView.frame.origin.y, width: bgImageView.frame.width, height: imageHeight)
                currentImageHeight = imageHeight
            }
            
            firstView.bounds = CGRect.init(x: 0, y: 0, width: firstView.frame.width, height: firstView.frame.height)
            
            UIView.commitAnimations()
            
            if isDraggingUp {
                animateDetailSubviews()
            }
            
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        isDragStarted = false
    }
    
    func changeAllSubviewsFrame(myView:UIView,movement:CGFloat) {
        totalDistanceMoved = totalDistanceMoved - movement
        for sub in myView.subviews {
            sub.isHidden = true
            let subBounds = sub.frame.origin
           sub.frame = CGRect.init(x: subBounds.x, y: subBounds.y - movement, width: sub.frame.width, height: sub.frame.height)
        }
    }
    
    func animateDetailSubviews(){
        secondView.alpha = 1
        animateView(index: 0)
    }
    
    func animateView(index:Int){
        
        let delayTime = (index == 0) ? 0.4 : 0.0
        if index >= secondView.subviews.count {
            totalDistanceMoved = 0
            return
        }
        let currentSubview = self.secondView.subviews[index]
        currentSubview.isHidden = false
        UIView.animate(withDuration: 0.3, delay: delayTime, options: .transitionCrossDissolve, animations: {
            let myframeOrigin = currentSubview.frame.origin
            currentSubview.frame = CGRect.init(x: myframeOrigin.x, y: myframeOrigin.y - self.totalDistanceMoved, width: currentSubview.frame.width, height: currentSubview.frame.height)
        }) { (animated) in
            self.animateView(index: index + 1)
        }
    }
    
    

    func closeCard(){
        UIView.beginAnimations("move", context: nil)
        UIView.setAnimationDuration(0.5)
        cardView.frame = CGRect.init(x: 0, y: (view.frame.height - 100 - firstView.frame.height), width: view.frame.width, height: cardHeight)
        bgImageView.frame = CGRect.init(x: bgImageView.frame.origin.x, y: bgImageView.frame.origin.y, width: bgImageView.frame.width, height: imageHeight)
        currentImageHeight = imageHeight
        totalDistanceMoved = 0
        firstView.bounds = CGRect.init(x: 0, y: 0, width: firstView.frame.width, height: firstView.frame.height)
        UIView.commitAnimations()

    }
}
