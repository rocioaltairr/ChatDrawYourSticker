//
//  SensorMainSection.swift
//  TaoyuanCropCultivation
//
//  Created by 2008007NB01 on 2021/8/12.
//

import UIKit


struct SensorMainSection: Section {
    var numberOfItems: Int = 3
    var strCellReuseIdentifier = String(describing: SensorMainCVCell.self)
    var strHeaderReuseIdentifier: String?
    var strFooterReuseIdentifier: String?
    var backgroundView: AnyClass?
    
    func layoutSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.33), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(128))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 3)
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        return section
    }
    
    
}
