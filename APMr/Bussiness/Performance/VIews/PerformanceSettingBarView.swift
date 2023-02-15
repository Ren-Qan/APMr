//
//  PerformanceSettingBarView.swift
//  APMr
//
//  Created by 任玉乾 on 2023/1/16.
//

import SwiftUI

struct PerformanceSettingBarView: View {
    
    @EnvironmentObject var service: HomepageService
    @EnvironmentObject var instruments: PerformanceInstrumentsService
    
    @State private var isShowPerformanceItem = false
    @State private var isShowPerformanceSetting = false
    
    var body: some View {
        VStack {
            HStack {
                // MARK: - 启动/停止按钮 
                Button {
                    if instruments.isMonitoringPerformance {
                        instruments.stopService()
                    } else {
                        if let device = service.selectDevice,
                           let app = service.selectApp {
                            instruments.isLaunchingApp = true
                            instruments.start(device) { success, server in
                                if success {
                                    server.launch(app: app)
                                    server.autoReceive()
                                } else {
                                    server.stopService()
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "\(instruments.isMonitoringPerformance ? "stop" : "play")" + ".circle.fill")
                            .resizable()
                            .frame(width: 15, height: 15)
                        Text("\(instruments.isMonitoringPerformance ? "停止" : "启动")")
                    }
                    .frame(height: 25)
                }
                .common(
                    backColor: instruments.isMonitoringPerformance ? .red : .blue,
                    enable: service.selectDevice != nil && service.selectApp != nil && !instruments.isLaunchingApp
                )
                
                // MARK: - 选择指标按钮
                Button {
                    isShowPerformanceItem.toggle()
                } label: {
                    Text("选择指标")
                        .frame(minHeight: 25)
                }
                .common(
                    backColor: .fabulaBar1,
                    enable: !instruments.isMonitoringPerformance
                )
                .popover(isPresented: $isShowPerformanceItem,
                         arrowEdge: .bottom) {
                    VStack(spacing: 1) {
                        ForEach(instruments.pCM.models) { chartModel in
                            PerformanceChartShowSettingPopoverButtonView()
                                .environmentObject(chartModel)
                        }
                    }
                    .padding(.top, 3)
                }
                
#if DEBUG
                Button("插入随机数据") {
                    instruments.insertTestData(count: .random(in: 40 ... 80))
                }
                
                Button("start") {
                    instruments.deviceInfoTest()
                }
                
                Button("stop") {
                    instruments.deviceInfoTest()
                }
#else
#endif
                Spacer()
                                
                // MARK: - 报告按钮
                Button {
                    service.isShowPerformanceSummary.toggle()
                } label: {
                    Text("报告")
                        .frame(minHeight: 25)
                }
                .common(backColor: .fabulaBar1)
            }
            .padding(.vertical, 5)
            .padding(.horizontal, 10)
            .background {
                Color.fabulaBack2
            }
        }
        .environmentObject(service)
        .environmentObject(instruments)
    }
}

struct PerformanceChartShowSettingPopoverButtonView: View {
    @EnvironmentObject var chartModel: ChartModel
    
    var body: some View {
        Button {
            chartModel.visiable.toggle()
        } label: {
            HStack {
                Image(systemName: chartModel.visiable ? "checkmark.square.fill" : "square")
                    .padding(.trailing, 5)
                Text(chartModel.type.name)
            }
            .frame(minHeight: 30)
            .frame(minWidth: 150, alignment: .leading)
        }
        .common(backColor: .fabulaBar2)
    }
}