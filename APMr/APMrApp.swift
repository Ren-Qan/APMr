//
//  APMrApp.swift
//  APMr
//
//  Created by 任玉乾 on 2022/11/30.
//

import SwiftUI

@main
struct APMrApp: App {
    
    @ObservedObject var a = A()
    
    var body: some Scene {
        WindowGroup {
            HomepageContentView()
            Button("\(a.items.count)") {
                a.b.items.append("asdasd")
                print("\(a.items.count)")
            }
        }
    }
}


class A: NSObject, ObservableObject  {
    var items: [String] {
       return b.items
    }
    
    var b: B = {
        let b = B()
        return b
    }()
}

class B {
    @Published public var items : [String] = []
}
