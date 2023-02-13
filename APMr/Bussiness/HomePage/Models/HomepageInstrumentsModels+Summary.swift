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
    
    class SummaryItem: ObservableObject , Identifiable {
        var id = UUID()
        var time: Int
        var values: [SummaryItemInfo]
        @Published var isOpen: Bool = false
        
        init(id: UUID = UUID(),
             time: Int,
             values: [SummaryItemInfo],
             isOpen: Bool = false) {
            self.id = id
            self.time = time
            self.values = values
            self.isOpen = isOpen
        }
    }
    
    class SummaryItemInfo: ObservableObject, Identifiable {
        var id = UUID()
        var title: String = ""
        var values: [SummaryItemValue] = []
        @Published var isShowDetails: Bool = false
    }
    
    struct SummaryItemValue: Identifiable, Hashable {
        var id = UUID()
        var name: String
        var value: CGFloat
    }
}
