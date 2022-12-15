//
//  HomepageContentView.swift
//  APMr
//
//  Created by 任玉乾 on 2022/12/7.
//

import SwiftUI

struct ID: Identifiable {
    var id: Int { item }
    var item: Int
}

struct HomepageContentView: View {
    @ObservedObject private var deviceService = HomepageDeviceService()
    
    @ObservedObject private var instrumentService = HomepageInstrumentsService()
        
    @State var isShow = false
    
    var items: [ID] = {
        var items = [ID]()
        (0 ..< 20).forEach { i in
            items.append(.init(item: i))
        }
        return items
    }()
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .center, spacing: 10) {
                PerformanceCoordinateView()
                    .frame(height: 190)
                    .background {
                        Color.white
                    }
            }
        }
        .onAppear {
            deviceService.refreshDeviceList()
        }
        .navigationTitle("")
        .frame(minWidth: 800)
        .frame(minHeight: 250)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                MenuButton("asdasdasd") {
                    ForEach(items) { id in
                        Button("\(id.item)") {
                            print(id.item)
                        }
                    }
                }
            }
            
            ToolbarItem(placement: .navigation) {
//                Image(systemName: "wifi.circle")
//                Image(systemName: "cable.connector")

                Meuns {
                    HStack {
                        Text("乾")
                        Image(systemName: "cable.connector")
                        Spacer()
                        Image(systemName: "chevron.down")
                    }
                    .padding(.leading, 10)
                    .padding(.trailing, 8)
                    .frame(width: 150)
                    .frame(height: 35)
                } popContent: {

                    
  
                
                    
                }
                .background {
                    Color
                        .white
                        .opacity(0.9)
                        .frame(height: 35)
                        .cornerRadius(4)
                }
                
            }
            
        }
    }
}
