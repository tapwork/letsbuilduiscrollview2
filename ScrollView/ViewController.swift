//
//  ViewController.swift
//  ScrollView
//
//  Created by Christian Menschel on 23.09.19.
//  Copyright © 2019 Breuninger GmbH. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    lazy var scrollView = ScrollView()

    override func loadView() {
        view = scrollView
        //scrollView.delegate = self
        view.backgroundColor = .yellow
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        var y: CGFloat = 0
        (0...50).forEach { index in
            y = addLabel(y: y, index: index)
        }
        scrollView.contentSize = CGSize(width: view.bounds.size.width, height: y)
    }

    func addLabel(y:  CGFloat, index: Int) -> CGFloat {
        let label1 = UILabel()
        let width: CGFloat = 200.0
        let height: CGFloat = 100.0
        let top = y + 10
        label1.backgroundColor = .red
        label1.text = "index \(index)"
        label1.frame = CGRect(x: 0, y: top, width: width, height: height)
        scrollView.addSubview(label1)
        return top + height
    }
}


class ScrollView: UIView {

    let gesture = UIPanGestureRecognizer()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addGestureRecognizer(gesture)
        gesture.addTarget(self, action: #selector(ScrollView.panGesture(_:)))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    var contentSize: CGSize = .zero
    private var gestureContentOffset: CGPoint = .zero
    var contentOffset: CGPoint = .zero {
        didSet {
            bounds.origin = contentOffset
        }
    }

    // MARK: Gesture Action
    @objc func panGesture(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self)
        let velocity = sender.velocity(in: self)
        var x = contentSize.width > bounds.size.width ? translation.x : 0.0
        x = min(bounds.size.width, x)
        var y = contentSize.height > bounds.size.height ? translation.y : 0.0
        y = min(bounds.size.height, y)

        switch sender.state {
        case .possible, .began:
            gestureContentOffset = contentOffset
        case .changed:
            contentOffset = CGPoint(x: gestureContentOffset.x - x, y: gestureContentOffset.y - y)
        case .ended:
            if bounds.origin.y < 0 {
                bounceToTop()
            } else if bounds.origin.y > (contentSize.height - bounds.size.height) {
                bounceToBottom()
            } else if translation.y != 0.0 {
                dragY(velocity: velocity)
            }
        default: break
        }
    }

    func dragY(velocity: CGPoint) {
        let dragDuration: TimeInterval = 2.5
        let draggedOffset = velocity.y / CGFloat(dragDuration)
        let y = max(0, min(contentSize.height-bounds.size.height, bounds.origin.y - draggedOffset))
        var targetBounds = bounds
        targetBounds.origin.y = y
        CATransaction.begin()
        let animation = CABasicAnimation(keyPath: "bounds")
        animation.timingFunction = CAMediaTimingFunction(controlPoints: 0.215, 0.61, 0.355, 1)
        animation.fromValue = NSValue(cgRect: bounds)
        animation.toValue = NSValue(cgRect: targetBounds)
        animation.duration = dragDuration
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.forwards
        layer.add(animation, forKey: "bounds")
        CATransaction.setCompletionBlock {
            self.contentOffset = targetBounds.origin
        }
        CATransaction.commit()
    }

    func bounceToTop() {
        UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.2, options: .curveEaseOut, animations: {
            self.contentOffset = CGPoint(x: self.contentOffset.x, y: 0)
        }, completion: nil)
    }

    func bounceToBottom() {
        UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.2, options: .curveEaseOut, animations: {
            let y = self.bounds.size.height - self.contentSize.height
            self.contentOffset = CGPoint(x: self.contentOffset.x, y: -y)
        }, completion: nil)
    }

    private func stopDragAnimation() {
        layer.removeAnimation(forKey: "bounds")
    }

    // MARK: TOuches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        stopDragAnimation()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
    }
}
