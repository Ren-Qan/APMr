//
//  HomepageModels.swift
//  APMr
//
//  Created by 任玉乾 on 2022/12/20.
//

import Foundation

// MARK: - Chart Models -

struct HomepageBarChartModel: Identifiable {
    var title: String
    var yMax: Int = 100
    var datas: [HomepageBarCharItem] = []
    
    var id: String { title }
}


struct HomepageLineChartModel: Identifiable {
    var title: String
    var yMax: Int = 100
    var datas: [HomepageLineCharItem] = []
    
    var id: String { title }
}


struct HomepageBarCharItem: PerformanceCoordinateViewMarkProtocol {
    var x: Int
    var y: Int
    var tips: String

    var id: Int {
        return x
    }
}


struct HomepageLineCharItem: PerformanceCoordinateViewMarkProtocol {
    var x: Int
    var y: Int
    var tips: String
    
    var xAxisKey: String = ""
    var yAxisKey: String = ""
    
    var id: Int {
        return x
    }
}
