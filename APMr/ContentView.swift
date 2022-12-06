//
//  ContentView.swift
//  APMr
//
//  Created by 任玉乾 on 2022/11/30.
//

import SwiftUI
import LibMobileDevice
import Charts


struct LandMarkItem: Identifiable, Hashable {
    var id = 0
    
    var y: CGFloat = 0
    
    var x = 0
}

struct ContentView: View {
    
    @State private var offsetY: CGFloat = 0
    @State private var ruleY: CGFloat = 50
    @State private var ruleDashLineHidden = true
    
    @State private var items: [LandMarkItem] = {
        var arr = [LandMarkItem]()
        (0 ..< 270).forEach { i in
            arr.append(.init(id: i,
                             y: .random(in: 0 ..< 100),
                             x: i))
        }
        return arr
    }()
    
    
    
    
    var body: some View {
        ScrollView {
            LazyVStack {
                Spacer(minLength: 20)
                
                Section {
                    ZStack(alignment: .trailing) {
                        BarChartView(marks: items, ruleY: ruleY)
                            .frame(height: 170)
                            .padding(.init(top: 0, leading: 10, bottom: 0, trailing: 20))
                        
                        HStack {
                            Text(String(format: "%.1f%%", 100 * (1 - (offsetY + 70) / 135)))
                                .font(.system(size: 10, weight: .medium))
                                .frame(width: 40)
                            
                            Line()
                                .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                                .frame(height: 1)
                                .opacity(ruleDashLineHidden ? 0 : 1)
                            
                        }
                        .padding(.init(top: 0, leading: 0, bottom: 0, trailing: 20))
                        .offset(y: offsetY)
                        
                        
                        Text("M")
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged{ value in
                                        let newOffsetY = offsetY + value.location.y - value.startLocation.y
                                        
                                        if newOffsetY >= -70, newOffsetY <= 65 {
                                            offsetY = newOffsetY
                                            ruleDashLineHidden = false
                                        }
                                    }
                                    .onEnded{ value in
                                        ruleY = 100 * (1 - (offsetY + 70) / 135)
                                        ruleDashLineHidden = true
                                    }
                            )
                            .offset(y: offsetY)
                            .offset(x: -5)
                        
                    }
                    .background {
                        Color.white
                    }
                } header : {
                    Text("CPU")
                }
                
                Spacer(minLength: 10)
            }
        }
    }
}

struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        return path
    }
}
