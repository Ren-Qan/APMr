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
            layout.sectionInset.top = 0
            layout.sectionInset.left = 1
            
            let collection = NSICollection()
            collection.collectionViewLayout = layout
            collection.delegate = self
            collection.dataSource = self
            collection.isSelectable = true
            collection.backgroundColors = [.box.BG1]
            collection.register(cells: [HeadlineCell.self, PanelCell.self])

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
    
    fileprivate func shot(_ section: Int) -> S? {
        guard let shots, shots.count > section else { return nil }
        return shots[section]
    }
}

extension IPerformanceView.ICharts.NSISides: NSCollectionViewDelegateFlowLayout,
                                             NSCollectionViewDataSource {
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return shots?.count ?? 0
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        if let shot = shot(section) {
            return 1 + (shot.expand ? shot.values.count : 0)
        }
        return 0
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        if indexPath.item == 0 {
            let cell: HeadlineCell = collectionView.reuse(indexPath)
            if let shot = shot(indexPath.section) {
                cell.render(shot)
            }
            return cell
        }
        
        let cell: PanelCell = collectionView.reuse(indexPath)
        if let shot = shot(indexPath.section), shot.values.count > indexPath.item - 1 {
            cell.render(shot.values[indexPath.item - 1])
        }
        return cell
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        guard let shot = shot(indexPath.section) else {
            return .zero
        }
        let w: CGFloat = collectionView.bounds.width - 1
        if indexPath.item == 0 {
            return NSSize(width: w, height: 40)
        }
        var h: CGFloat = 0
        if shot.values.count > indexPath.item - 1 {
            h = CGFloat(shot.values[indexPath.item - 1].marks.count) * 30 + 35
        }
        return NSSize(width: w, height: h)
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard let indexPath = indexPaths.first else { return }
        
        if indexPath.item == 0, let shot = shot(indexPath.section) {
            shot.expand.toggle()
            collectionView.reloadData()
            return
        }
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, insetForSectionAt section: Int) -> NSEdgeInsets {
        var edge = NSEdgeInsets()
        edge.top = section == 0 ? 10 : 0
        return edge
    }
}

extension IPerformanceView.ICharts.NSISides {
    class Separator: CALayer {
        override func action(forKey event: String) -> CAAction? {
            return nil
        }
    }
}
