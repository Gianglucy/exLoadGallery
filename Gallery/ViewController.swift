//
//  ViewController.swift
//  Gallery
//
//  Created by Apple on 7/13/20.
//  Copyright © 2020 NguyenDucLuu. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate {
    
    var myCollectionView: UICollectionView!
    var imageArray=[UIImage]()
    var deviceWidth:CGFloat!
    let spacing:CGFloat = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        deviceWidth = view.bounds.width
        let layout = UICollectionViewFlowLayout()
        
        layout.sectionInset = UIEdgeInsets(top: 0, left: spacing, bottom: spacing, right: spacing)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = spacing
        
        myCollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        myCollectionView.delegate=self
        myCollectionView.dataSource=self
        myCollectionView.register(PhotoItemCell.self, forCellWithReuseIdentifier: "Cell")
        myCollectionView.backgroundColor=UIColor.white
        myCollectionView!.collectionViewLayout = layout
        self.view.addSubview(myCollectionView)
        
        //            myCollectionView.autoresizingMask = UIView.AutoresizingMask(rawValue: UIView.AutoresizingMask.RawValue(UInt8(UIView.AutoresizingMask.flexibleWidth.rawValue) | UInt8(UIView.AutoresizingMask.flexibleHeight.rawValue)))
        
        grabPhotos()
    }
    
    //MARK: CollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell=collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PhotoItemCell
        cell.img.image=imageArray[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(self.imageArray)
        let vc=ImagePreviewVC()
        vc.imgArray = self.imageArray
        vc.passedContentOffset = indexPath
        self.present(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //            let width = collectionView.frame.width
        //
        //            if DeviceInfo.Orientation.isPortrait {
        //                return CGSize(width: width/4 - 1, height: width/4 - 1)
        //            } else {
        //                return CGSize(width: width/6 - 1, height: width/6 - 1)
        //            }
        let width:CGFloat = (deviceWidth - 4 * spacing)/3
        let height:CGFloat = (deviceWidth - 3 * spacing)/3
        let size  = CGSize(width: width, height: height)
        return size
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        myCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    //MARK: grab photos
    func grabPhotos(){
        imageArray = []
        
        DispatchQueue.global(qos: .userInteractive).async {
            print("This is run on the background queue")
            let imgManager=PHImageManager.default()
            
            let requestOptions=PHImageRequestOptions()
            requestOptions.isSynchronous=true
            requestOptions.deliveryMode = .highQualityFormat
            
            let fetchOptions=PHFetchOptions()
            fetchOptions.sortDescriptors=[NSSortDescriptor(key:"creationDate", ascending: false)]
            
            let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
            print(fetchResult)
            print(fetchResult.count)
            if fetchResult.count > 0 {
                for i in 0..<fetchResult.count{
                    imgManager.requestImage(for: fetchResult.object(at: i) as PHAsset, targetSize: CGSize(width:500, height: 500),contentMode: .aspectFill, options: requestOptions, resultHandler: { (image, error) in
                        self.imageArray.append(image!)
                    })
                }
            } else {
                print("You got no photos.")
            }
            print("imageArray count: \(self.imageArray.count)")
            
            DispatchQueue.main.async {
                print("This is run on the main queue, after the previous code in outer block")
                self.myCollectionView.reloadData()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}


class PhotoItemCell: UICollectionViewCell {
    
    var img = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        img.contentMode = .scaleAspectFill
        img.clipsToBounds=true
        self.addSubview(img)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        img.frame = self.bounds
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//struct DeviceInfo {
//    struct Orientation {
//        // indicate current device is in the LandScape orientation
//        static var isLandscape: Bool {
//            get {
//                return UIDevice.current.orientation.isValidInterfaceOrientation
//                    ? UIDevice.current.orientation.isLandscape
//                    : UIApplication.shared.statusBarOrientation.isLandscape
//            }
//        }
//        // indicate current device is in the Portrait orientation
//        static var isPortrait: Bool {
//            get {
//                return UIDevice.current.orientation.isValidInterfaceOrientation
//                    ? UIDevice.current.orientation.isPortrait
//                    : UIApplication.shared.statusBarOrientation.isPortrait
//            }
//        }
//    }
//}

