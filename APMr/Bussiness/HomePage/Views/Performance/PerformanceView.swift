//
//  PerformanceView.swift
//  APMr
//
//  Created by 任玉乾 on 2023/1/10.
//

import SwiftUI

struct TestItem: Identifiable {
    var id: String
}

struct PerformanceView: View {
    
    let charts = [TestItem(id: "CPU"), TestItem(id: "FPS"), TestItem(id: "Memory"), TestItem(id: "GPU"), TestItem(id: "Network"), TestItem(id: "I/O"), TestItem(id: "Battery")]
    @State var timeRange: CGFloat = 0
        
    
    @EnvironmentObject var service: HomepageService
    
    var body: some View {
        VStack {            
            HStack {
                Button {
                    print("Start")
                } label: {
                    HStack {
                        Image(systemName: "play.circle.fill")
                            .resizable()
                            .frame(width: 15, height: 15)
                        Text("启动")
                    }
                    .frame(minHeight: 25)
                }
                .buttonStyle(ButtonCommonStyle(backColor: .blue))
                
                
                Button("选择指标") {
                    
                }
                
                Spacer()
                
                Button("设置") {
                    
                }
                
                Button("报告") {
                    
                }
                
            }
            .padding()
            .background {
                Color.fabulaBack1
            }
            
        
            Slider(value: $timeRange)
                .padding()
                .background {
                    Color.fabulaBack1
                }
            
            GeometryReader { proxy in
                ScrollView {
                    LazyVStack {
                        ForEach(charts) { item in
                            Text(item.id)
                                .fontDesign(.monospaced)
                                .frame(height: 300)
                                .frame(width: proxy.size.width)
                                .padding(.bottom, 20)
                                .background {
                                    Color.fabulaBack1
                                }
                        }
                    }
                }
            }
        }
    }
}
