//
//  Panel+NoteRow.swift
//  APMr
//
//  Created by 任玉乾 on 2023/11/10.
//

import AppKit

extension IPerformanceView.ICharts.NSISides.PanelCell.Panel {
    class NoteRow: CALayer {
        fileprivate lazy var notes: [Note] = {
            return (0 ..< 2).compactMap { i in
                let note = Note()
                self.add(note)
                return note
            }
        }()
        
        override func action(forKey event: String) -> CAAction? {
            return nil
        }
        
        override func layoutSublayers() {
            var left: CGFloat = 0
            notes.forEach { note in
                note.iLayout.make(bounds) { maker in
                    maker.top(0).bottom(0).left(left).width(bounds.width / CGFloat(notes.count))
                }
                left = note.frame.maxX
            }
        }
    }
}

extension IPerformanceView.ICharts.NSISides.PanelCell.Panel.NoteRow {
    public func update() {
        notes.forEach { note in
            note.foregroundColor = NSColor.box.C1.cgColor
        }
    }
    
    public func load(_ mark: CPerformance.Chart.Mark) {
        notes[0].string(mark.label)
        notes[1].string(String(format: "%.1f \(mark.source.unit.format)", mark.source.value))
    }
    
    public func load(_ values: [String]) {
        (0 ..< 2).forEach { i in
            notes[i].string(values[i])
        }
    }
}

extension IPerformanceView.ICharts.NSISides.PanelCell.Panel {
    fileprivate class Note: CATextLayer {
        override func action(forKey event: String) -> CAAction? {
            return nil
        }
        
        func string(_ string: String) {
            contentsScale = NSScreen.scale
            fontSize = 13
            font = NSFont.current.regular(13)
            alignmentMode = .left
            self.string = string
        }
    }
}
