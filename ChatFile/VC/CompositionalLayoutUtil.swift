//
//  CompositionalLayoutUtil.swift
//  TaoyuanCropCultivation
//
//  Created by 忠義 on 2021/8/9.
//

import UIKit

protocol Section {
    var numberOfItems: Int {get set}
    var strCellReuseIdentifier: String {get set}
    var strHeaderReuseIdentifier: String? {get set}
    var strFooterReuseIdentifier: String? {get set}
    var backgroundView: AnyClass? {get set}

    func layoutSection() -> NSCollectionLayoutSection
    func configureCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell
    //func configureHeaderFooter(collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView
}


extension Section {
    
    func configureCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: strCellReuseIdentifier, for: indexPath)
    }
    
}

extension UICollectionView {
    func setupLayoutAndRegisterCell(_ sections:[Section]) {
        let layout = UICollectionViewCompositionalLayout { (index, environment) -> NSCollectionLayoutSection? in
            return sections[index].layoutSection()
        }
        //register cell, header, footer
        for item in sections {
            
            // 客制BG
            if item.backgroundView != nil {
                layout.register(item.backgroundView, forDecorationViewOfKind: String(describing: item.backgroundView))
            }
            
            self.register(UINib(nibName: item.strCellReuseIdentifier, bundle: nil), forCellWithReuseIdentifier: item.strCellReuseIdentifier)
            if let str = item.strHeaderReuseIdentifier {
                self.register(UINib(nibName: str, bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: str)
            }
            if let str = item.strFooterReuseIdentifier {
                self.register(UINib(nibName: str, bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: str)
            }
        }

        self.collectionViewLayout = UICollectionViewLayout()
        if sections.count > 0 {
            self.collectionViewLayout = layout
        }
    }
    
}
