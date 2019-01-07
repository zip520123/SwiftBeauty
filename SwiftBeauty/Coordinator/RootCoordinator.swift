//
//  RootCoordinator.swift
//  SwiftBeauty
//
//  Created by Nelson on 2018/8/12.
//  Copyright © 2018年 Nelson. All rights reserved.
//

import UIKit
import Lightbox
final class RootCoordinator: NSObject, CoordinatorProtocol {
    private var navigation: UINavigationController
    private var source: SourceFetchable.Type = TimLiaoFetcher.self

    required init(navigationController: UINavigationController) {
        self.navigation = navigationController
    }

    func start() {
        let vc = createSourcesViewController()
        navigation.setViewControllers([vc], animated: true)
    }
}

// MARK: - Source Related Methods
extension RootCoordinator: SourcesViewControllerDelegate {
    private func createSourcesViewController() -> SourcesViewController {
        let typeName = "\(SourcesViewController.self)"
        let storyboard = UIStoryboard(name: typeName, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: typeName) as! SourcesViewController
        viewController.delegate = self
        return viewController
    }

    func sourcesViewController(_ controller: SourcesViewController, didSelect source: SourceFetchable.Type) {
        self.source = source
        let vc = createPostsViewController()
        navigation.pushViewController(vc, animated: true)
    }
}

// MARK: - Post Related Methods
extension RootCoordinator: PostsViewModelDelegate {
    private func createPostsViewController() -> PostsViewController {
        let typeName = "\(PostsViewController.self)"
        let storyboard = UIStoryboard(name: typeName, bundle: nil)
        let viewModel = PostsViewModel(source.init())
        let viewController = storyboard.instantiateViewController(withIdentifier: typeName) as! PostsViewController
        viewController.viewModel = viewModel
        viewModel.delegate = self
        return viewController
    }

    func viewModel(_ viewModel: PostsViewModel, show post: Post) {
        let vc = createPhotosViewController(for: post)
        navigation.pushViewController(vc, animated: true)
    }
}

// MARK: - Photo Related Methods
extension RootCoordinator: PhotosViewModelDelegate {
    private func createPhotosViewController(for post: Post) -> PhotosViewController {
        let typeName = "\(PhotosViewController.self)"
        let storyboard = UIStoryboard(name: typeName, bundle: nil)
        let viewModel = PhotosViewModel(source.init(), post: post)
        let viewController = storyboard.instantiateViewController(withIdentifier: typeName) as! PhotosViewController
        viewController.viewModel = viewModel
        viewModel.delegate = self
        return viewController
    }
    func viewModel(_ viewModel: PhotosViewModel, didSelect index: Int, for data: [URL]) {
//        let vc = createPhotoBrowserViewController()
//        navigation.present(vc, animated: true) {
//            vc.load(data, scrollTo: index)
//        }
        let controller = ZoomablePhotoBrowser(images: data, startIndex: index)
        controller.dismissalDelegate = self
        navigation.present(controller, animated: true, completion: nil)
    }
}
// MARK: - Photo Browser Related Methods
extension RootCoordinator: PhotoBrowserViewControllerDelegate {
    private func createPhotoBrowserViewController() -> PhotoBrowserViewController {
        let typeName = "\(PhotoBrowserViewController.self)"
        let storyboard = UIStoryboard(name: typeName, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: typeName) as! PhotoBrowserViewController
        viewController.delegate = self
        return viewController
    }

    func photoBrowserViewController(_ viewController: PhotoBrowserViewController, closeAt index: Int) {
        let vc = navigation.topViewController as! PhotosViewController
        vc.scrollToData(at: index, animated: false)
        navigation.dismiss(animated: true, completion: nil)
    }
}
// MARK: - LightboxController Delegate
extension RootCoordinator: LightboxControllerDismissalDelegate {
    func lightboxControllerWillDismiss(_ controller: LightboxController) {
        
    }
    
}

