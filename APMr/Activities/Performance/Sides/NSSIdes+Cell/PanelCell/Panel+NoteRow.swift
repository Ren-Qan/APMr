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
            layoutManager = CAConstraintLayoutManager()
            var relative: String? = nil
            return (0 ..< 2).compactMap { i in
                let note = Note()
                note.name = "note\(i)"
                note.addConstraint(CAConstraint(attribute: .minY, relativeTo: "superlayer", attribute: .minY))
                note.addConstraint(CAConstraint(attribute: .height, relativeTo: "superlayer", attribute: .height))
                note.addConstraint(CAConstraint(attribute: .width, relativeTo: "superlayer", attribute: .width, scale: 1 / 2, offset: 0))
                if let relative {
                    note.addConstraint(CAConstraint(attribute: .minX, relativeTo: relative, attribute: .maxX))
                } else {
                    note.addConstraint(CAConstraint(attribute: .minX, relativeTo: "superlayer", attribute: .minX))
                }
                relative = note.name
                self.add(note)
                return note
            }
        }()
        
        override func action(forKey event: String) -> CAAction? {
            return nil
        }
        
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
}

extension IPerformanceView.ICharts.NSISides.PanelCell.Panel {
    fileprivate class Note: CATextLayer {
        func string(_ string: String) {
            contentsScale = NSScreen.scale
            fontSize = 13
            font = NSFont.current.regular(13)
            alignmentMode = .left
            self.string = string
        }
    }
}
