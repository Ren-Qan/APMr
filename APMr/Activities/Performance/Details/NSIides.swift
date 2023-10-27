//
//  NSISideView.swift
//  APMr
//
//  Created by 任玉乾 on 2023/10/24.
//

import AppKit

extension IPerformanceView.ICharts {
    class NSISides: NSView  {
        public var target: ISides? = nil
        public var count = 0
                
        fileprivate lazy var collection: NSICollection = {
            let layout = NSCollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            
            let collection = NSICollection()
            collection.register(cell: Cell.self)
            collection.collectionViewLayout = layout
            collection.delegate = self
            collection.dataSource = self            
            return collection
        }()
        
        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            self.wantsLayer = true
            addSubview(collection.view)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layout() {
            collection.view.frame = bounds
        }
            
        public func refresh() {
            DispatchQueue.mainAsync {
                self.collection.reloadData()
            }
        }
    }
}

extension IPerformanceView.ICharts.NSISides: NSCollectionViewDelegateFlowLayout,
                                             NSCollectionViewDataSource {
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let cell: Cell = collectionView.reuse(indexPath)
        cell.label.stringValue = "\(indexPath.item)"
        return cell
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        return .init(width: bounds.width, height: 50)
    }
}

extension IPerformanceView.ICharts.NSISides {
    class Cell: NSCollectionView.Cell {
        fileprivate lazy var label: NSTextField = {
            let textField = NSTextField()
            textField.wantsLayer = true
            textField.isBordered = false
            textField.isEditable = false
            textField.textColor = .random
            textField.alignment = .center
            textField.backgroundColor = .random.withAlphaComponent(0.1)
            return textField
        }()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            view.addSubview(label)
        }
        
        override func viewDidLayout() {
            super.viewDidLayout()
            label.frame = view.bounds
        }
    }
}
