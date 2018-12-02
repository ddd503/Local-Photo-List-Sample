//
//  PhotoListCell.swift
//  Local-Photo-List-Sample
//
//  Created by kawaharadai on 2018/12/02.
//  Copyright © 2018 kawaharadai. All rights reserved.
//

import UIKit
import Photos

final class PhotoListCell: UICollectionViewCell {
    
    @IBOutlet weak private var imageView: UIImageView!
    
    static var identifier: String {
        return String(describing: self)
    }
    
    static func nib() -> UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    /// 画像データの表示
    ///
    /// - Parameters:
    ///   - manager: キャッシュを持ったPHCachingImageManager
    ///   - asset: 表示する画像データ
    ///   - size: 画像サイズ
    func setImage(manager: PHCachingImageManager, asset: PHAsset?, size: CGSize) {
        if let asset = asset {
            manager.getImage(asset: asset, quality: .high, size: size, mode: .aspectFill) { (image) in
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
            }
        }
    }
}
