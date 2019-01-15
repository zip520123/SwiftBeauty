//
//  ZoomablePhotoBrowser.swift
//  SwiftBeauty
//
//  Created by Woody on 2019/1/7.
//  Copyright © 2019 Nelson. All rights reserved.
//

import UIKit
import Lightbox
import Kingfisher
class ZoomablePhotoBrowser: LightboxController {
    override var shouldAutorotate: Bool {
        return true
    }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait, .landscape]
    }
    init(images: [URL], startIndex index: Int) {
        let images = images.map { LightboxImage(imageURL: $0) }
        LightboxConfig.CloseButton.text = "X"
        LightboxConfig.loadImage = {
            imageView, URL, completion in
            imageView.kf.indicatorType = .activity
            imageView.kf.setImage(with: URL,
                                  options: [.transition(.fade(0.2)),
                                            .cacheOriginalImage,
                ], completionHandler: { image, _, _, _ in
                    completion?(image)
            })
        }
        super.init(images: images, startIndex: index)
        dynamicBackground = true
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
class CustomPresentAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        let finalFrameForVC = transitionContext.finalFrame(for: toViewController)
        let containerView = transitionContext.containerView
        let bounds = UIScreen.main.bounds
        toViewController.view.frame = toViewController.view.frame.offsetBy(dx: 0,
                                               dy: bounds.size.height)
        containerView.addSubview(toViewController.view)
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.0, options: .curveLinear, animations: {
            fromViewController.view.alpha = 0.5
            toViewController.view.frame = finalFrameForVC
        }) { (finished) in
            transitionContext.completeTransition(true)
            fromViewController.view.alpha = 1.0
        }
    }
}
