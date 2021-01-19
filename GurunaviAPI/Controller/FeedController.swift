//
//  FeedController.swift
//  GurunaviAPI
//
//  Created by 白数叡司 on 2020/12/07.
//

import UIKit
import Alamofire
import SwiftyJSON


private let reuseIdentifier = "ShopInfoCell"
private let reuseHeaderIdentifier = "ShopInfoHeader"


final class FeedController: UICollectionViewController {
    
    // MARK: - Properties
    
    private var actionSheetLauncher: ActionSheetLauncher!
    
    var nameArray = [String]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var categoryArray = [String]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var opentimeArray = [String]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var mobileUrlArray = [String]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var shopsImageArray = [[String]]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var itemCount: Int = 2
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
        configureUI()
        configureRightBarButton()
        collectionView.reloadData()
        print("DEBUG: \(self.nameArray)")
    }
    
    // MARK: - API
    
    func fetchData() {
        
        var imageUrlArray = [String]()
        
        guard let apiKey = APIKeyManager().getValue(key: "apiKey") else {
            return
        }
        var text = "https://api.gnavi.co.jp/RestSearchAPI/v3/?keyid=\(apiKey)&name=&area=AREA120"
        let url = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        print("DEBUG: Into method fetching data..")
        
        AF.request(url as! URLConvertible, method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON { response in
            
            let fetchingDataMax = 0...9
            
            print("DEBUG: requesting .GET...")
            
            switch response.result {
            case .success:
                for order in fetchingDataMax {
                    
                    let json: JSON = JSON(response.data as Any)
                    
                    guard let shopName = json["rest"][order]["name"].string else { return }
                    guard let shopCategory = json["rest"][order]["category"].string else { return }
                    guard let shopOpentime = json["rest"][order]["opentime"].string else { return }
                    guard let mobileUrl = json["rest"][order]["url"].string else { return }
                    guard let imageUrl1 = json["rest"][order]["image_url"]["shop_image1"].string else { return }
                    guard let imageUrl2 = json["rest"][order]["image_url"]["shop_image2"].string else { return }
                    self.nameArray.append(shopName)
                    self.categoryArray.append(shopCategory)
                    self.opentimeArray.append(shopOpentime)
                    self.mobileUrlArray.append(mobileUrl)
                    imageUrlArray.append(imageUrl1)
                    if imageUrl2 != "" {
                        imageUrlArray.append(imageUrl2)
                    }
                    self.shopsImageArray.append(imageUrlArray)
                    imageUrlArray.removeAll()
                    print("\(self.mobileUrlArray)")
                }
            case .failure(let error):
                print(error)
                break
            }
            
        }
        
    }
    
    
    // MARK: - Helper
    
    func configureUI() {
        view.backgroundColor = .red
        
        collectionView.register(ShopInfoCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.register(ShopInfoHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: reuseHeaderIdentifier)
        
        collectionView.backgroundColor = .white
        collectionView.collectionViewLayout = layout()
        
        navigationController?.title = "Shop"
        navigationController?.navigationBar.barTintColor = .red
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        navigationItem.title = "Gurunavi API"
    }
    
    func configureRightBarButton() {
        let researchImageView = UIImageView()
        researchImageView.image = UIImage(systemName: "magnifyingglass")
        researchImageView.tintColor = .white
        researchImageView.setDimensions(width: 27, height: 27)
        researchImageView.layer.masksToBounds = true
        researchImageView.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(researchImageTapped))
        researchImageView.addGestureRecognizer(tap)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: researchImageView)
    }
    
    @objc func researchImageTapped() {
        utilizeActionSheetLauncher()
    }
    
    func layout() -> UICollectionViewCompositionalLayout {
        
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),heightDimension: .fractionalWidth(1.0))
            
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let containerGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1.0))
            
            let containerGroup = NSCollectionLayoutGroup.horizontal(layoutSize: containerGroupSize, subitem: item, count: 1)
            containerGroup.interItemSpacing = NSCollectionLayoutSpacing.fixed(10)
            
            let section = NSCollectionLayoutSection(group: containerGroup)
            section.orthogonalScrollingBehavior = .continuous
            section.interGroupSpacing = 10
            
            let sectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),heightDimension: .estimated(60))
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: sectionHeaderSize, elementKind: "header", alignment: .top)
            sectionHeader.pinToVisibleBounds = true
            
            section.boundarySupplementaryItems = [sectionHeader]
        
            return section
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 10
        
        let layout = UICollectionViewCompositionalLayout(sectionProvider: sectionProvider, configuration: config)
        
        return layout
    }
    
    fileprivate func utilizeActionSheetLauncher() {
        actionSheetLauncher = ActionSheetLauncher()
//        actionSheetLauncher.delegate = self
        actionSheetLauncher.show()
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 10
    }

}

// MARK: - UICollectionViewDelegate/DataSource

extension FeedController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemCount
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ShopInfoCell
        if shopsImageArray != [] {
            let shopImage = URL(string: shopsImageArray[indexPath.section][indexPath.row])
            cell.setUpImageView(imageUrl: shopImage!)
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: reuseHeaderIdentifier, for: indexPath) as! ShopInfoHeader
        if nameArray != [] {
            sectionHeader.setUpContents(name: self.nameArray[indexPath.section], category: self.categoryArray[indexPath.section], opentime: self.opentimeArray[indexPath.section])
        }
        
        return sectionHeader
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let webController = WebController()
        webController.mobileUrl = mobileUrlArray[indexPath.section]
        navigationController?.pushViewController(webController, animated: true)
    }
}

