//
//  MultipleSectionModelViewController.swift
//  RxDataSources
//
//  Created by Segii Shulga on 4/26/16.
//  Copyright © 2016 kzaher. All rights reserved.
//

import UIKit
import RxDataSources
import RxCocoa
import RxSwift

// the trick is to just use enum for different section types
class MultipleSectionModelViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sections: [MultipleSectionModel] = [
            .imageProvidableSection(title: "Section 1",
                items: [.imageSectionItem(image: UIImage(named: "settings")!, title: "General")]),
            .toggleableSection(title: "Section 2",
                items: [.toggleableSectionItem(title: "On", enabled: true)]),
            .stepperableSection(title: "Section 3",
                items: [.stepperSectionItem(title: "1")])
        ]
        
        let dataSource = RxTableViewSectionedReloadDataSource<MultipleSectionModel>()

        skinTableView(dataSource)
        
        Observable.just(sections)
            .bindTo(tableView.rx_itemsWithDataSource(dataSource))
            .addDisposableTo(disposeBag)
    }
    
    func skinTableView(_ dataSource: RxTableViewSectionedReloadDataSource<MultipleSectionModel>) {
        dataSource.configureCell = { (dataSource, table, idxPath, _) in
            switch dataSource.itemAtIndexPath(idxPath) {
            case let .imageSectionItem(image, title):
                let cell: ImageTitleTableViewCell = table.dequeueReusableCell(forIndexPath: idxPath)
                cell.titleLabel.text = title
                cell.cellImageView.image = image
                
                return cell
            case let .stepperSectionItem(title):
                let cell: TitleSteperTableViewCell = table.dequeueReusableCell(forIndexPath: idxPath)
                cell.titleLabel.text = title
                
                return cell
            case let .toggleableSectionItem(title, enabled):
                let cell: TitleSwitchTableViewCell = table.dequeueReusableCell(forIndexPath: idxPath)
                cell.switchControl.isOn = enabled
                cell.titleLabel.text = title
                
                return cell
            }
        }

        dataSource.titleForHeaderInSection = { dataSource, index in
            let section = dataSource.sectionAtIndex(index)
            
            return section.title
        }
    }
}

enum MultipleSectionModel {
    case imageProvidableSection(title: String, items: [SectionItem])
    case toggleableSection(title: String, items: [SectionItem])
    case stepperableSection(title: String, items: [SectionItem])
}

enum SectionItem {
    case imageSectionItem(image: UIImage, title: String)
    case toggleableSectionItem(title: String, enabled: Bool)
    case stepperSectionItem(title: String)
}

extension MultipleSectionModel: SectionModelType {
    typealias Item = SectionItem
    
    var items: [SectionItem] {
        switch  self {
        case .imageProvidableSection(title: _, items: let items):
            return items.map {$0}
        case .stepperableSection(title: _, items: let items):
            return items.map {$0}
        case .toggleableSection(title: _, items: let items):
            return items.map {$0}
        }
    }
    
    init(original: MultipleSectionModel, items: [Item]) {
        switch original {
        case let .imageProvidableSection(title: title, items: _):
            self = .imageProvidableSection(title: title, items: items)
        case let .stepperableSection(title, _):
            self = .stepperableSection(title: title, items: items)
        case let .toggleableSection(title, _):
            self = .toggleableSection(title: title, items: items)
        }
    }
}

extension MultipleSectionModel {
    var title: String {
        switch self {
        case .imageProvidableSection(title: let title, items: _):
            return title
        case .stepperableSection(title: let title, items: _):
            return title
        case .toggleableSection(title: let title, items: _):
            return title
        }
    }
}
