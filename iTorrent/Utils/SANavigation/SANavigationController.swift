//
//  SANavigationController.swift
//  iTorrent
//
//  Created by Daniil Vinogradov on 15.02.2020.
//  Copyright © 2020  XITRIX. All rights reserved.
//

import UIKit

/// Swipe Anywhere - to close view controller
public class SANavigationController: UINavigationController {
    var locker = true

    override public func viewDidLoad() {
        super.viewDidLoad()

        // Glitchy behaviour on iOS less than 11
        if #available(iOS 11, *) {
            self.view.addGestureRecognizer(self.fullScreenPanGestureRecognizer)
            fullScreenPanGestureRecognizer.delegate = self
            delegate = self
        }
    }

    private lazy var fullScreenPanGestureRecognizer: UIPanGestureRecognizer = {
        let gestureRecognizer = UIPanGestureRecognizer()

        if let cachedInteractionController = self.value(forKey: "_cachedInteractionController") as? NSObject {
            let selector = Selector(("handleNavigationTransition:"))
            if cachedInteractionController.responds(to: selector) {
                gestureRecognizer.addTarget(cachedInteractionController, action: selector)
            }
        }

        return gestureRecognizer
    }()

    override public func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
        locker = true
    }
}

extension SANavigationController: UINavigationControllerDelegate {
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        fullScreenPanGestureRecognizer.isEnabled = viewControllers.count > 1
    }
}

extension SANavigationController: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // Do not allow pop if navigation is process of transition
        guard transitionCoordinator == nil else { return false }

        // Do not allow to pop root controller
        guard viewControllers.count > 1 else { return false }

        // Do not allow pop if back button overriten
        guard viewControllers.last?.navigationItem.leftBarButtonItem == nil else { return false }

        // Do not allow pop if it locked
        guard !locker else { return false }

        var isLeftToRight = true
        if #available(iOS 10.0, *) {
            isLeftToRight = view.effectiveUserInterfaceLayoutDirection == .leftToRight
        }

        guard let pan = gestureRecognizer as? UIPanGestureRecognizer else { return false }

        let velocity = pan.velocity(in: view)

        // Do not allow vertical swipes
        guard abs(velocity.x) > abs(velocity.y) else { return false }

        if isLeftToRight {
            return velocity.x > 0
        } else {
            return velocity.x < 0
        }
    }
}
