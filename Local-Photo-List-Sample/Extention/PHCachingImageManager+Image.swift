//
//  PHCachingImageManager+Image.swift
//  Local-Photo-List-Sample
//
//  Created by kawaharadai on 2018/12/02.
//  Copyright © 2018 kawaharadai. All rights reserved.
//

import Photos

extension PHCachingImageManager {
    
    enum Quality {
        case high
        case low
    }
    
    func getImage(asset: PHAsset, quality: Quality, size: CGSize, mode: PHImageContentMode, completionHandler: @escaping (UIImage) -> Void) {
        let options = PHImageRequestOptions()
        switch quality {
        case .high:
            options.deliveryMode = .highQualityFormat
            options.resizeMode = .exact
            options.version = .original
        case .low:
            options.deliveryMode = .fastFormat
            options.resizeMode = .fast
            options.version = .current
        }
        self.requestImage(for: asset, targetSize: size, contentMode: mode, options: options) { (image, dict) in
            if let image = image {
                completionHandler(image)
            }
        }
    }
    
}
