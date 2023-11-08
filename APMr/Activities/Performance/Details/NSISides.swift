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
        
        fileprivate lazy var collection: NSICollection = {
            let layout = NSCollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            layout.minimumLineSpacing = 0
            layout.sectionInset.top = 10
            layout.sectionInset.left = 1
            
            let collection = NSICollection()
            collection.register(cell: Cell.self)
            collection.collectionViewLayout = layout
            collection.delegate = self
            collection.dataSource = self
            collection.isSelectable = true
            collection.backgroundColors = [.box.BG1]
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
            self.collection.reloadData()
        }
    }
}

extension IPerformanceView.ICharts.NSISides {
    typealias S = CPerformance.Chart.Actor.Highlighter.Snap.Shot
    
    fileprivate var shots: [S]? {
        return target?.snap.items
    }
    
    fileprivate func shot(_ indexPath: IndexPath) -> S? {
        guard let shots, shots.count > indexPath.item else { return nil }
        return shots[indexPath.item]
    }
}

extension IPerformanceView.ICharts.NSISides: NSCollectionViewDelegateFlowLayout,
                                             NSCollectionViewDataSource {
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return shots?.count ?? 0
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let cell: Cell = collectionView.reuse(indexPath)
        
        if let shot = shot(indexPath) {
            cell.sync(shot)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        if let shots, shots.count > indexPath.item {
            return .init(width: collectionView.bounds.width - 1, height: shots[indexPath.item].expand ? 300 : 40)
        }
        return .init(width: collectionView.bounds.width, height: 30)
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        if let shots, let indexPath = indexPaths.first, shots.count > indexPath.section {
            let shot = shots[indexPath.item]
            shot.expand.toggle()
            collectionView.reloadItems(at: [indexPath])
        }
    }
}


