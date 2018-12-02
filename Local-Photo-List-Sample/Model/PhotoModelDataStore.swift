//
//  PhotoModelDataStore.swift
//  Local-Photo-List-Sample
//
//  Created by kawaharadai on 2018/12/02.
//  Copyright © 2018 kawaharadai. All rights reserved.
//

import Photos

protocol PhotoModelDataStore {
    func get(_ completionHandler: (PhotoModel) -> ())
}

extension PhotoModelDataStore {
    
    func get(_ completionHandler: (PhotoModel) -> ()) {
        guard case .authorized = PHPhotoLibrary.authorizationStatus() else { return }
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let assets = PHAsset.fetchAssets(with: .image, options: options)
        if assets.count > 0 {
            var photos = [PHAsset]()
            for i in 0..<assets.count {
                photos.append(assets[i])
            }
            completionHandler(PhotoModel(photos: photos))
        } else {
            completionHandler(PhotoModel(photos: []))
        }
    }
    
}
