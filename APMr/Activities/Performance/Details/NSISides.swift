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
        public var baseX = 0
        public var count = 0
                
        fileprivate var indexPath: IndexPath? = nil
        
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
        cell.label.stringValue = "\(indexPath.item + baseX)"
        cell.closure = { [weak self] in
            if let row = self?.indexPath?.item, row == indexPath.item {
                self?.indexPath = nil
            } else {
                self?.indexPath = indexPath
            }
        
            self?.collection.animator().reloadItems(at: [indexPath])
            
        }
        return cell
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        if let i = self.indexPath, i.item == indexPath.item {
            return .init(width: bounds.width, height: 100)
        }
        return .init(width: bounds.width, height: 50)
    }
}


