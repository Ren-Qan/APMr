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
            Button {
                service.isMonitoringPreformance.toggle()
            } label: {
                HStack {
                    Image(systemName: "\(service.isMonitoringPreformance ? "stop" : "play")" + ".circle.fill")
                        .resizable()
                        .frame(width: 15, height: 15)
                    Text("\(service.isMonitoringPreformance ? "停止" : "启动")")
                }
                .frame(height: 25)
            }
            .buttonStyle(
                ButtonCommonStyle(
                    backColor: service.isMonitoringPreformance ? .red : .blue
                )
            )
            
            Button {
                isShowPerformanceItem.toggle()
            } label: {
                Text("选择指标")
                    .frame(minHeight: 25)
            }
            .buttonStyle(
                ButtonCommonStyle(
                    backColor: .fabulaBar1
                )
            )
            .popover(isPresented: $isShowPerformanceItem,
                     arrowEdge: .bottom) {
                VStack(spacing: 8) {
                    ForEach(service.testDatas) { chart in
                        Button {
                            
                        } label: {
                            HStack() {
                                Image(systemName: "checkmark.circle.fill")
                                    .padding(.trailing, 8)
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
                .padding(.vertical, 5)
                .background {
                    Color.fabulaBack2
                }
            }
            
            
            Spacer()
            
            Button("设置") {
                isShowPerformanceSetting.toggle()
            }
            .popover(isPresented: $isShowPerformanceSetting, arrowEdge: .bottom) {
                Text("Preformace Setting In Progress\n采样周期 单屏长度 录制时长")
                    .multilineTextAlignment(.center)
                    .padding()
                    .monospaced()
                    .frame(minWidth: 200)
                    .frame(minHeight: 400)
            }
            
            Button("报告") {
                service.isShowPerformanceSummary.toggle()
            }
            
        }
        .padding()
        .background {
            Color.fabulaBack1
        }

        Text("时间片控制 In Progress")
            .monospaced()
        
    }
}
