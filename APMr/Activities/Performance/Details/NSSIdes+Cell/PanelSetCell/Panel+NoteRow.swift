//
//  Panel+NoteRow.swift
//  APMr
//
//  Created by 任玉乾 on 2023/11/10.
//

import AppKit

extension IPerformanceView.ICharts.NSISides.PanelSetCell.Panel {
    class NoteRow: CALayer {
        fileprivate lazy var notes: [Note] = {
            layoutManager = CAConstraintLayoutManager()
            var relative: String? = nil
            return (0 ..< 3).compactMap { i in
                let note = Note()
                note.name = "note\(i)"
                note.addConstraint(CAConstraint(attribute: .minY, relativeTo: "superlayer", attribute: .minY))
                note.addConstraint(CAConstraint(attribute: .height, relativeTo: "superlayer", attribute: .height))
                note.addConstraint(CAConstraint(attribute: .width, relativeTo: "superlayer", attribute: .width, scale: 1 / 3, offset: 0))
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
        
        public func update() {
            notes.forEach { note in
                note.foregroundColor = NSColor.box.C1.cgColor
            }
        }
        
        public func load(_ mark: CPerformance.Chart.Mark) {
            notes[0].text(mark.label)
            notes[1].text(String(format: "%.1f", mark.source.value))
            notes[2].text(mark.source.unit.format)
        }
        
        public func load(_ values: [String]) {
            (0 ..< 3).forEach { i in
                notes[i].text(values[i])
            }
        }
    }
}

extension IPerformanceView.ICharts.NSISides.PanelSetCell.Panel {
    fileprivate class Note: CATextLayer {
        func text(_ string: String) {
            fontSize = 13
            font = NSFont.current.regular(13)
            alignmentMode = .left
            self.string = string
        }
    }
}
