//
//  HomepageInstrumentsModels+Summary.swift
//  APMr
//
//  Created by 任玉乾 on 2023/2/10.
//

import Foundation

extension HomepageInstrumentsService {
    class SummaryModel {
        var items: [SummaryItem] = []
    }
    
    struct SummaryItem {
        var time: Int
        var values: [SummaryItemInfo]
    }
    
    struct SummaryItemInfo {
        var title: String
        var values: [SummaryItemValue]
    }
    
    struct SummaryItemValue {
        var name: String
        var value: CGFloat
    }
}
