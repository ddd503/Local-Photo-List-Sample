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
    
    var representedAssetIdentifier: String!
    
    static var identifier: String {
        return String(describing: self)
    }
    
    static func nib() -> UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    /// 画像データの表示
    ///
    /// - Parameters:
    ///   - manager: キャッシュを持ったPHCachingImageManager
    ///   - asset: 表示する画像データ
    ///   - size: 画像サイズ
    func setImage(manager: PHCachingImageManager, asset: PHAsset?, size: CGSize) {
        if let asset = asset {
            representedAssetIdentifier = asset.localIdentifier
            manager.getImage(asset: asset, quality: .high, size: size, mode: .aspectFill) { [weak self] image in
                if self?.representedAssetIdentifier == asset.localIdentifier {
                    DispatchQueue.main.async {
                        self?.imageView.image = image
                    }
                }
            }
        }
    }
}
