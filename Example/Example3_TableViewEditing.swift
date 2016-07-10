//
//  EditingExampleTableViewController.swift
//  RxDataSources
//
//  Created by Segii Shulga on 3/24/16.
//  Copyright © 2016 kzaher. All rights reserved.
//

import UIKit
import RxDataSources
import RxSwift
import RxCocoa

// redux like editing example
class EditingExampleViewController: UIViewController {
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    @IBOutlet weak var tableView: UITableView!
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dataSource = RxTableViewSectionedAnimatedDataSource<NumberSection>()
        let sections: [NumberSection] = [NumberSection(header: "Section 1", numbers: [], updated: Date()),
                                         NumberSection(header: "Section 2", numbers: [], updated: Date()),
                                         NumberSection(header: "Section 3", numbers: [], updated: Date())]

        let initialState = SectionedTableViewState(sections: sections)
        let add3ItemsAddStart = Observable.of((), (), ())
        let addCommand = Observable.of(addButton.rx_tap.asObservable(), add3ItemsAddStart)
            .merge()
            .map(TableViewEditingCommand.addRandomItem)

        let deleteCommand = tableView.rx_itemDeleted.asObservable()
            .map(TableViewEditingCommand.deleteItem)

        let movedCommand = tableView.rx_itemMoved
            .map(TableViewEditingCommand.moveItem)

        skinTableViewDataSource(dataSource)
        Observable.of(addCommand, deleteCommand, movedCommand)
            .merge()
            .scan(initialState) {
                return $0.executeCommand($1)
            }
            .startWith(initialState)
            .map {
                $0.sections
            }
            .shareReplay(1)
            .bindTo(tableView.rx_itemsWithDataSource(dataSource))
            .addDisposableTo(disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.setEditing(true, animated: true)
    }
    
    func skinTableViewDataSource(_ dataSource: RxTableViewSectionedAnimatedDataSource<NumberSection>) {
        
        dataSource.animationConfiguration = AnimationConfiguration(insertAnimation: .top,
                                                                   reloadAnimation: .fade,
                                                                   deleteAnimation: .left)
        
        dataSource.configureCell = { (dataSource, table, idxPath, item) in
            let cell = table.dequeueReusableCell(withIdentifier: "Cell", for: idxPath)
            
            cell.textLabel?.text = "\(item)"
            
            return cell
        }
        
        dataSource.titleForHeaderInSection = { (ds, section) -> String? in
            return ds.sectionAtIndex(section).header
        }
        
        dataSource.canEditRowAtIndexPath = { _ in
            return true
        }
        dataSource.canMoveRowAtIndexPath = { _ in
            return true
        }
    }
}

enum TableViewEditingCommand {
    case appendItem(item: IntItem, section: Int)
    case moveItem(sourceIndex: IndexPath, destinationIndex: IndexPath)
    case deleteItem(IndexPath)
}

// This is the part

struct SectionedTableViewState {
    private var sections: [NumberSection]
    
    init(sections: [NumberSection]) {
        self.sections = sections
    }
    
    func executeCommand(_ command: TableViewEditingCommand) -> SectionedTableViewState {
        switch command {
        case .appendItem(let appendEvent):
            var sections = self.sections
            let items = sections[appendEvent.section].items + appendEvent.item
            sections[appendEvent.section] = NumberSection(original: sections[appendEvent.section], items: items)
            return SectionedTableViewState(sections: sections)
        case .deleteItem(let indexPath):
            var sections = self.sections
            var items = sections[(indexPath as NSIndexPath).section].items
            items.remove(at: (indexPath as NSIndexPath).row)
            sections[(indexPath as NSIndexPath).section] = NumberSection(original: sections[(indexPath as NSIndexPath).section], items: items)
            return SectionedTableViewState(sections: sections)
        case .moveItem(let moveEvent):
            var sections = self.sections
            var sourceItems = sections[(moveEvent.sourceIndex as NSIndexPath).section].items
            var destinationItems = sections[(moveEvent.destinationIndex as NSIndexPath).section].items
            
            if (moveEvent.sourceIndex as NSIndexPath).section == (moveEvent.destinationIndex as NSIndexPath).section {
                destinationItems.insert(destinationItems.remove(at: (moveEvent.sourceIndex as NSIndexPath).row),
                                        at: (moveEvent.destinationIndex as NSIndexPath).row)
                let destinationSection = NumberSection(original: sections[(moveEvent.destinationIndex as NSIndexPath).section], items: destinationItems)
                sections[(moveEvent.sourceIndex as NSIndexPath).section] = destinationSection
                
                return SectionedTableViewState(sections: sections)
            } else {
                let item = sourceItems.remove(at: (moveEvent.sourceIndex as NSIndexPath).row)
                destinationItems.insert(item, at: (moveEvent.destinationIndex as NSIndexPath).row)
                let sourceSection = NumberSection(original: sections[(moveEvent.sourceIndex as NSIndexPath).section], items: sourceItems)
                let destinationSection = NumberSection(original: sections[(moveEvent.destinationIndex as NSIndexPath).section], items: destinationItems)
                sections[(moveEvent.sourceIndex as NSIndexPath).section] = sourceSection
                sections[(moveEvent.destinationIndex as NSIndexPath).section] = destinationSection
                
                return SectionedTableViewState(sections: sections)
            }
        }
    }
}

extension TableViewEditingCommand {
    static func addRandomItem() -> TableViewEditingCommand {
        let randSection = Int(arc4random_uniform(UInt32(3)))
        let number = Int(arc4random_uniform(UInt32(10000)))
        let item = IntItem(number: number, date: Date())
        return TableViewEditingCommand.appendItem(item: item, section: randSection)
    }
}

func + <T>(lhs: [T], rhs: T) -> [T] {
    var copy = lhs
    copy.append(rhs)
    return copy
}
