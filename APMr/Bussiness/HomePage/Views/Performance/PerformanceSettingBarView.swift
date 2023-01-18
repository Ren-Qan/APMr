//
//  PerformanceSettingBarView.swift
//  APMr
//
//  Created by 任玉乾 on 2023/1/16.
//

import SwiftUI

struct PerformanceSettingBarView: View {
    
    @EnvironmentObject var service: HomepageService
    
    @State private var isShowPerformanceItem = false
    @State private var isShowPerformanceSetting = false
    
    var body: some View {
        HStack {
            // MARK: - 启动/停止按钮 -
            Button {
                service.isMonitoringPerformance.toggle()
            } label: {
                HStack {
                    Image(systemName: "\(service.isMonitoringPerformance ? "stop" : "play")" + ".circle.fill")
                        .resizable()
                        .frame(width: 15, height: 15)
                    Text("\(service.isMonitoringPerformance ? "停止" : "启动")")
                }
                .frame(height: 25)
            }
            .buttonStyle(
                ButtonCommonStyle(
                    backColor: service.isMonitoringPerformance ? .red : .blue,
                    enable: service.selectDevice != nil && service.selectApp != nil
                )
            )
            .disabled(
                service.selectDevice == nil || service.selectApp == nil
            )
            
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
                    enable: !service.isMonitoringPerformance
                )
            )
            .disabled(service.isMonitoringPerformance)
            .popover(isPresented: $isShowPerformanceItem,
                     arrowEdge: .bottom) {
                PerformanceChartShowSettingPopoverView()
                    .environmentObject(service)
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
                    enable: !service.isMonitoringPerformance
                )
            )
            .disabled(service.isMonitoringPerformance)
            .popover(isPresented: $isShowPerformanceSetting,
                     arrowEdge: .bottom) {
                PerformanceTimeRecordSettingView()
                    .environmentObject(service)
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
            Color.fabulaBack1
        }

        Text("时间片控制 In Progress")        
    }
}

struct PerformanceChartShowSettingPopoverView: View {
    @EnvironmentObject var service: HomepageService
    
    var body: some View {
        VStack(spacing: 1) {
            ForEach(service.testDatas) { chart in
                Button {
                    var item = chart
                    item.chartViewShow.toggle()
                    service.updatePerformanceChartShow(item)
                } label: {
                    HStack {
                        Image(systemName: chart.chartViewShow ? "checkmark.square.fill" : "square")
                            .padding(.trailing, 5)
                        Text(chart.id)
                    }
                    .frame(minHeight: 30)
                    .frame(minWidth: 150, alignment: .leading)
                }
                .buttonStyle(
                    ButtonCommonStyle(
                        backColor: .fabulaBar2
                    )
                )
            }
        }
        .padding(.vertical, 3)

    }
}

struct PerformanceTimeRecordSettingView: View {
    @EnvironmentObject var service: HomepageService
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("采样周期: \(service.samplingTime, specifier: "%g") s")
            Text("单屏时长: \(service.sampleFragmentTime, specifier: "%g") s")
            Text("录制时长: \(service.recordDuration, specifier: "%d") s")
        }
        .padding()
        .frame(minWidth: 200)
    }
}
