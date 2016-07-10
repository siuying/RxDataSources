//
//  UI+SectionedViewType.swift
//  RxDataSources
//
//  Created by Krunoslav Zaher on 6/27/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import UIKit

func indexSet(_ values: [Int]) -> IndexSet {
    let indexSet = NSMutableIndexSet()
    for i in values {
        indexSet.add(i)
    }
    return indexSet as IndexSet
}

extension UITableView : SectionedViewType {
  
    public func insertItems(at paths: [IndexPath], animationStyle: UITableViewRowAnimation) {
        self.insertRows(at: paths, with: animationStyle)
    }
    
    public func deleteItems(at paths: [IndexPath], animationStyle: UITableViewRowAnimation) {
        self.deleteRows(at: paths, with: animationStyle)
    }
    
    public func moveItem(at from: IndexPath, to: IndexPath) {
        self.moveRow(at: from, to: to)
    }
    
    public func reloadItems(at paths: [IndexPath], animationStyle: UITableViewRowAnimation) {
        self.reloadRows(at: paths, with: animationStyle)
    }
    
    public func insertSections(_ sections: [Int], animationStyle: UITableViewRowAnimation) {
        self.insertSections(indexSet(sections), with: animationStyle)
    }
    
    public func deleteSections(_ sections: [Int], animationStyle: UITableViewRowAnimation) {
        self.deleteSections(indexSet(sections), with: animationStyle)
    }
    
    public func reloadSections(_ sections: [Int], animationStyle: UITableViewRowAnimation) {
        self.reloadSections(indexSet(sections), with: animationStyle)
    }

    public func performBatchUpdates<S: SectionModelType>(_ changes: Changeset<S>, animationConfiguration: AnimationConfiguration) {
        self.beginUpdates()
        _performBatchUpdates(self, changes: changes, animationConfiguration: animationConfiguration)
        self.endUpdates()
    }
}

extension UICollectionView : SectionedViewType {
    public func insertItems(at paths: [IndexPath], animationStyle: UITableViewRowAnimation) {
        self.insertItems(at: paths)
    }
    
    public func deleteItems(at paths: [IndexPath], animationStyle: UITableViewRowAnimation) {
        self.deleteItems(at: paths)
    }

    public func reloadItems(at paths: [IndexPath], animationStyle: UITableViewRowAnimation) {
        self.reloadItems(at: paths)
    }
    
    public func insertSections(_ sections: [Int], animationStyle: UITableViewRowAnimation) {
        self.insertSections(indexSet(sections))
    }
    
    public func deleteSections(_ sections: [Int], animationStyle: UITableViewRowAnimation) {
        self.deleteSections(indexSet(sections))
    }

    public func reloadSections(_ sections: [Int], animationStyle: UITableViewRowAnimation) {
        self.reloadSections(indexSet(sections))
    }
    
    public func performBatchUpdates<S: SectionModelType>(_ changes: Changeset<S>, animationConfiguration: AnimationConfiguration) {
        self.performBatchUpdates({ () -> Void in
            _performBatchUpdates(self, changes: changes, animationConfiguration: animationConfiguration)
        }, completion: { (completed: Bool) -> Void in
        })
    }
}

public protocol SectionedViewType {
    func insertItems(at paths: [IndexPath], animationStyle: UITableViewRowAnimation)
    func deleteItems(at paths: [IndexPath], animationStyle: UITableViewRowAnimation)
    func moveItem(at from: IndexPath, to: IndexPath)
    func reloadItems(at paths: [IndexPath], animationStyle: UITableViewRowAnimation)
    
    func insertSections(_ sections: [Int], animationStyle: UITableViewRowAnimation)
    func deleteSections(_ sections: [Int], animationStyle: UITableViewRowAnimation)
    func moveSection(_ from: Int, toSection newSection: Int)
    func reloadSections(_ sections: [Int], animationStyle: UITableViewRowAnimation)

    func performBatchUpdates<S>(_ changes: Changeset<S>, animationConfiguration: AnimationConfiguration)
}

func _performBatchUpdates<V: SectionedViewType, S: SectionModelType>(_ view: V, changes: Changeset<S>, animationConfiguration:AnimationConfiguration) {
    typealias I = S.Item
  
    view.deleteSections(changes.deletedSections, animationStyle: animationConfiguration.deleteAnimation)
    // Updated sections doesn't mean reload entire section, somebody needs to update the section view manually
    // otherwise all cells will be reloaded for nothing.
    //view.reloadSections(changes.updatedSections, animationStyle: rowAnimation)
    view.insertSections(changes.insertedSections, animationStyle: animationConfiguration.insertAnimation)
    for (from, to) in changes.movedSections {
        view.moveSection(from, toSection: to)
    }
    
    view.deleteItems(
        at: changes.deletedItems.map { IndexPath(item: $0.itemIndex, section: $0.sectionIndex) },
        animationStyle: animationConfiguration.deleteAnimation
    )
    view.insertItems(
        at: changes.insertedItems.map { IndexPath(item: $0.itemIndex, section: $0.sectionIndex) },
        animationStyle: animationConfiguration.insertAnimation
    )
    view.reloadItems(
        at: changes.updatedItems.map { IndexPath(item: $0.itemIndex, section: $0.sectionIndex) },
        animationStyle: animationConfiguration.reloadAnimation
    )
    
    for (from, to) in changes.movedItems {
        view.moveItem(
            at: IndexPath(item: from.itemIndex, section: from.sectionIndex),
            to: IndexPath(item: to.itemIndex, section: to.sectionIndex)
        )
    }
}
