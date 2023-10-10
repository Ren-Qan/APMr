//
//  Cell+Checker.swift
//  APMr
//
//  Created by 任玉乾 on 2023/10/10.
//

import Foundation

extension IPerformanceView.ITableView.Cell {
    class Checker {
        fileprivate var chart_l: Int = 0
        fileprivate var chart_r: Int = 0
        fileprivate var chart_offset: CGFloat = 0
        
        fileprivate var axis_offset: CGFloat = 0
        fileprivate var axis_content_width: CGFloat = 0
        fileprivate var axis_count: Int = 0
        fileprivate var axis_upper: CGFloat = 0
        
        fileprivate var hint = IPerformanceView.NSITableView.Hint()
        fileprivate var hint_offsetX: CGFloat = 0
        fileprivate var hint_contentW: CGFloat = 0
        
        public func reset() {
            self.axis_offset = 0
            self.axis_content_width = 0
            self.axis_upper = 0
            self.axis_count = 0
            
            self.chart_offset = 0
            self.chart_r = 0
            self.chart_l = 0
            
            self.hint = .init()
            self.hint_offsetX = 0
        }
    }
}

// MARK: - Chart
extension IPerformanceView.ITableView.Cell.Checker {
    func chart(_ l: Int,
               _ r: Int,
               _ offset: CGFloat) -> Bool {
        if chart_l == l,
           chart_r == r,
           chart_offset == offset {
            return false
        }
        chart_l = l
        chart_r = r
        chart_offset = offset
        return true
    }
}

// MARK: - Axis
extension IPerformanceView.ITableView.Cell.Checker {
    func axis(_ contentWidth: CGFloat,
              _ offset: CGFloat,
              _ count: Int,
              _ upper: CGFloat) -> Bool {
        if axis_content_width == contentWidth,
           axis_offset == offset,
           axis_count == count,
           axis_upper == upper{
            return false
        }
        axis_content_width = contentWidth
        axis_offset = offset
        axis_count = count
        axis_upper = upper
        return true
    }
}

// MARK: - Hint
extension IPerformanceView.ITableView.Cell.Checker {
    func hint(_ hint: IPerformanceView.NSITableView.Hint,
              _ offset: CGFloat,
              _ contentW: CGFloat) -> Bool {
        if self.hint.action == hint.action,
           self.hint.offsetX == hint.offsetX,
           self.hint.area.origin.x == hint.area.origin.x,
           self.hint.area.size.width == hint.area.size.width,
           self.hint_offsetX == offset,
           self.hint_contentW == contentW{
            return false
        }
        self.hint = hint
        self.hint_offsetX = offset
        self.hint_contentW = contentW
        return true
    }
}
