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
            photoListView.prefetchDataSource = self
            photoListView.register(PhotoListCell.nib(), forCellWithReuseIdentifier: PhotoListCell.identifier)
        }
    }
    
    private var model: PhotoModel?
    private let imageManager = PHCachingImageManager()
    private var thumbnailSize: CGSize!
    
    // 初期設定
    private func setup() {
        adjustNaviBar()
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
    
    // 画像データの取得
    private func getPhotos() {
        get { (photoModel) in
            model = photoModel
            reload()
        }
    }
    
    // 画面更新
    private func reload() {
        DispatchQueue.main.async {
            self.photoListView.reloadData()
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
        cell.setImage(manager: imageManager, asset: model?.photos[indexPath.row], size: thumbnailSize)
        return cell
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout
extension PhotoListViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // セルの縦通しのスペースはIB側で
        let cellSpacing: CGFloat = 1
        let size = view.frame.width / 3 - cellSpacing
        let scale = UIScreen.main.scale
        thumbnailSize = CGSize(width: size * scale, height: size * scale)
        return CGSize(width: size, height: size)
    }
    
}

extension PhotoListViewController: UICollectionViewDelegate {}

// MARK: - UICollectionViewDataSourcePrefetching
extension PhotoListViewController: UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        guard let model = model else { return }
        let prefetchPhotos = indexPaths.map { model.photos[$0.row] }
        guard !prefetchPhotos.isEmpty else { return }
        imageManager.startCachingImages(for: prefetchPhotos, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        guard let model = model else { return }
        let prefetchPhotos = indexPaths.map { model.photos[$0.row] }
        guard !prefetchPhotos.isEmpty else { return }
        imageManager.stopCachingImages(for: prefetchPhotos, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
    }
    
}
