//
//  PerformaceChartView.swift
//  APMr
//
//  Created by 任玉乾 on 2023/1/17.
//

import SwiftUI
import Charts

struct PerformaceChartView: View {
    // MARK: - Public -
    @EnvironmentObject var service: HomepageService
    
    @EnvironmentObject var instruments: HomepageInstrumentsService
            
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                ForEach(instruments.pCM.models) { model in
                    Line()
                        .environmentObject(model)
                }
            }
            .padding(.top, 7)
        }
        
    }
}

extension PerformaceChartView {
    struct Line: View {
        @EnvironmentObject var model: ChartModel
            
        var body: some View {
            if model.visiable {
                ZStack(alignment: .topLeading) {
                    GroupBox {
                        Text(model.title)
                    }
                    .offset(x: 10)
                    .padding(.top, 5)
                                    
                    LineChart()
                        .environmentObject(model)
                        .padding(.top, 10)
                        .padding(.bottom, 5)
                        .frame(height: 190)
                }
                .background {
                    Color.fabulaBack2
                }
                .padding(.bottom, 10)
            }
        }
    }
}

extension PerformaceChartView {
    struct LineChart: NSViewRepresentable {
            
        typealias NSViewType = LineChartView
            
        @EnvironmentObject var chartModel: ChartModel
        
        func makeNSView(context: Context) -> LineChartView {
            let view = LineChartView()
            view.delegate = context.coordinator
            view.data = chartModel.chartData
            view.doubleTapToZoomEnabled = false
            view.dragYEnabled = false
            view.dragXEnabled = false
            view.scaleYEnabled = false
            view.pinchZoomEnabled = false
            view.scaleXEnabled = true
            view.drawGridBackgroundEnabled = false
            
            view.xAxis.labelPosition = .bottom
            view.xAxis.drawGridLinesEnabled = false
            view.xAxis.setLabelCount(10, force: true)
            
            view.legend.horizontalAlignment = .center
            view.legend.verticalAlignment = .top
            
            view.leftAxis.drawTopYLabelEntryEnabled = true
            view.leftAxis.drawGridLinesEnabled = false
            
            view.rightAxis.enabled = false
            view.extraTopOffset = 20
        
            return view
        }
        
        func updateNSView(_ nsView: Charts.LineChartView, context: Context) {
            let count = chartModel.sets[0].entries.count
            
            func update() {
                switch chartModel.updateState {
                    case .view:
                        let xC = 100
                        if count > 0 {
                            let min = count >= xC ? count - xC : 0
                            nsView.xAxis.axisMinimum = Double(min)
                            nsView.xAxis.axisMaximum = Double(min + 100)
                        }
                        
                        nsView.notifyDataSetChanged()
                        
                        if count > 0 {
                            nsView.setVisibleXRange(minXRange: Double(xC), maxXRange: Double(xC))
                        }
                        
                    case.hightlight(let positon):
                        let hightlight = nsView.getHighlightByTouchPoint(positon)
                        nsView.highlightValue(hightlight, callDelegate: false)
                        
                    case .unHighlight:
                        nsView.highlightValue(nil, callDelegate: false)
                        
                    case .none: break
                }
                chartModel.updateState = .none
            }
            
            if Thread.isMainThread {
                update()
            } else {
                DispatchQueue.main.async {
                    update()
                }
            }
        }
        
        func makeCoordinator() -> Proxy {
            let proxy = Proxy()
            
            return proxy
        }
        
        class Proxy: ChartViewDelegate {
            func chartValueSelected(_ chartView: ChartViewBase,
                                    entry: ChartDataEntry,
                                    highlight: Highlight) {
                print(entry.x)
            }
        }
    }
}
