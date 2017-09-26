//
//  UIViewControllerImageViewer.swift
//  ShopClient
//
//  Created by Evgeniy Antonov on 9/19/17.
//  Copyright © 2017 Evgeniy Antonov. All rights reserved.
//

import UIKit
import SKPhotoBrowser

extension UIViewController {
    func pushImageViewer(with product: Product, initialIndex: Int) {
        var images = [SKPhoto]()
        if let items = product.images {
            for item in items {
                images.append(SKPhoto.photoWithImageURL(item.src))
            }
        }
        let browser = SKPhotoBrowser(photos: images)
        browser.initializePageIndex(initialIndex)
        present(browser, animated: true)
    }
}
