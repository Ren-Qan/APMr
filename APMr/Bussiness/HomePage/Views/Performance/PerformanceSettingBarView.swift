//
//  PerformanceSettingBarView.swift
//  APMr
//
//  Created by 任玉乾 on 2023/1/16.
//

import SwiftUI

struct PerformanceSettingBarView: View {
    
    @EnvironmentObject var service: HomepageService
    @EnvironmentObject var instruments: HomepageInstrumentsService
    
    @State private var isShowPerformanceItem = false
    @State private var isShowPerformanceSetting = false
    
    var body: some View {
        VStack {
            HStack {
                // MARK: - 启动/停止按钮 -
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
                                    server.autoRequest()
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
                .buttonStyle(
                    ButtonCommonStyle(
                        backColor: instruments.isMonitoringPerformance ? .red : .blue,
                        enable: service.selectDevice != nil && service.selectApp != nil && !instruments.isLaunchingApp
                    )
                )
                .disabled(service.selectDevice == nil)
                .disabled(service.selectApp == nil)
                .disabled(instruments.isLaunchingApp)
                
                // MARK: - 选择指标按钮 -
                Button {
                    isShowPerformanceItem.toggle()
                } label: {
                    Text("选择指标")
                        .frame(minHeight: 25)
                }
                .buttonStyle(
                    ButtonCommonStyle(
                        backColor: .fabulaBar1,
                        enable: !instruments.isMonitoringPerformance
                    )
                )
                .disabled(instruments.isMonitoringPerformance)
                .popover(isPresented: $isShowPerformanceItem,
                         arrowEdge: .bottom) {
                    PerformanceChartShowSettingPopoverView()
                }
                
                
                Spacer()
                
                // MARK: - 设置按钮 -
                Button {
                    isShowPerformanceSetting.toggle()
                } label: {
                    Text("设置")
                        .frame(minHeight: 25)
                }
                .buttonStyle(
                    ButtonCommonStyle(
                        backColor: .fabulaBar1,
                        enable: !instruments.isMonitoringPerformance
                    )
                )
                .disabled(instruments.isMonitoringPerformance)
                .popover(isPresented: $isShowPerformanceSetting,
                         arrowEdge: .bottom) {
                    PerformanceTimeRecordSettingView()
                }
                
                // MARK: - 报告按钮 -
                Button {
                    service.isShowPerformanceSummary.toggle()
                } label: {
                    Text("报告")
                        .frame(minHeight: 25)
                }
                .buttonStyle(
                    ButtonCommonStyle(
                        backColor: .fabulaBar1
                    )
                )
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

struct PerformanceChartShowSettingPopoverView: View {
    @EnvironmentObject var service: HomepageService
    
    var body: some View {
//        VStack(spacing: 1) {
//            ForEach(service.testDatas) { chart in
//                Button {
//                    var item = chart
//                    item.chartViewShow.toggle()
//                    service.updatePerformanceChartShow(item)
//                } label: {
//                    HStack {
//                        Image(systemName: true ? "checkmark.square.fill" : "square")
//                            .padding(.trailing, 5)
//                        Text(chart.id)
//                    }
//                    .frame(minHeight: 30)
//                    .frame(minWidth: 150, alignment: .leading)
//                }
//                .buttonStyle(
//                    ButtonCommonStyle(
//                        backColor: .fabulaBar2
//                    )
//                )
//            }
//        }
//        .padding(.vertical, 3)
        Text("In Progress")
    }
}

struct PerformanceTimeRecordSettingView: View {
    @EnvironmentObject var service: HomepageService
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("In Progress")
        }
        .padding()
        .frame(minWidth: 200)
    }
}
