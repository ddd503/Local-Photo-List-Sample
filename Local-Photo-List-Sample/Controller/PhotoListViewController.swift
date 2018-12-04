//
//  PhotoListViewController.swift
//  Local-Photo-List-Sample
//
//  Created by kawaharadai on 2018/12/02.
//  Copyright © 2018 kawaharadai. All rights reserved.
//

import UIKit
import Photos

final class PhotoListViewController: UIViewController, PhotoModelDataStore {
    
    // MARK: - Initiarize
    
    static func makePhotoListViewController() -> PhotoListViewController {
        // init時に何かする時をここで
        return PhotoListViewController()
    }
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        imageManager.stopCachingImagesForAllAssets()
    }
    
    // MARK: - Private
    
    @IBOutlet weak private var photoListView: UICollectionView! {
        didSet {
            photoListView.dataSource = self
            photoListView.delegate = self
            photoListView.register(PhotoListCell.nib(), forCellWithReuseIdentifier: PhotoListCell.identifier)
        }
    }
    
    private var model: PhotoModel?
    private let imageManager = PHCachingImageManager()
    private var thumbnailSize: CGSize!
    private let cacheImageThread = DispatchQueue(label: "cacheImage")
    // 画像キャッシュ関連の動作
    enum CachingImageAction {
        case start
        case stop
    }
    // 取得画像の画質管理
    enum ImageQuality {
        case high
        case low
        
        var options: PHImageRequestOptions {
            switch self {
            case .high:
                let options = PHImageRequestOptions()
                options.deliveryMode = .highQualityFormat
                options.resizeMode = .exact
                options.version = .original
                return options
            case .low:
                let options = PHImageRequestOptions()
                options.deliveryMode = .fastFormat
                options.resizeMode = .fast
                options.version = .current
                return options
            }
        }
    }
    
    // 初期設定
    private func setup() {
        adjustNaviBar()
        adjustThumbnailSize()
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            getPhotos()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ [weak self] (status) in
                switch status {
                case .authorized:
                    self?.getPhotos()
                default:
                    print("reject access library")
                }
            })
        default:
            print("reject access library")
        }
    }
    
    // ナビゲーションバーの設定
    private func adjustNaviBar() {
        navigationItem.title = "写真一覧"
    }
    
    // サムネイルのサイズ準備
    private func adjustThumbnailSize() {
        let size = UIScreen.main.bounds.width / 3 - 1
        let scale = UIScreen.main.scale
        thumbnailSize = CGSize(width: size * scale, height: size * scale)
    }
    
    // 画像データの取得
    private func getPhotos() {
        get { photoModel in
            model = photoModel
            cacheImageThread.async {
                self.imageManager.startCachingImages(for: photoModel.photos,
                                                     targetSize: self.thumbnailSize,
                                                     contentMode: .aspectFill,
                                                     options: ImageQuality.high.options)
            }
            reload()
        }
    }
    
    // 画面更新
    private func reload() {
        DispatchQueue.main.async {
            self.photoListView.reloadData()
        }
    }
    
    /// 表示画像のキャッシュアクションのハンドリング
    ///
    /// - Parameters:
    ///   - actionType: 行うアクション
    ///   - indexPaths: キャッシュ対象画像のindexPath
    private func cache(_ actionType: CachingImageAction, indexPaths: [IndexPath]) {
        guard let model = self.model else { return }
        let prefetchPhotos = indexPaths.map { model.photos[$0.row] }
        guard !prefetchPhotos.isEmpty else { return }
        switch actionType {
        case .start:
            self.imageManager.startCachingImages(for: prefetchPhotos, targetSize: self.thumbnailSize, contentMode: .aspectFill, options: nil)
        case .stop:
            self.imageManager.stopCachingImages(for: prefetchPhotos, targetSize: self.thumbnailSize, contentMode: .aspectFill, options: nil)
        }
    }
    
}

// MARK: - UICollectionViewDataSource
extension PhotoListViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model?.photos.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoListCell.identifier, for: indexPath) as? PhotoListCell else {
            fatalError("cell is nil")
        }
        cell.setImage(manager: imageManager, asset: model?.photos[indexPath.row], size: thumbnailSize, options: ImageQuality.high.options)
        return cell
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout
extension PhotoListViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // セルの縦通しのスペースはIB側で
        let length = UIScreen.main.bounds.width / 3 - 1
        return CGSize(width: length, height: length)
    }
    
}


