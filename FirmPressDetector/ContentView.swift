//
//  ContentView.swift
//  FirmPressDetector
//
//  Created by Raphael Tang on 30/8/22.
//

import SwiftUI

struct ContentView: View {
    @State private var touchRadius = 0.0
    
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 50)
            
            Text("FirmPressDetector")
                .font(.title)
                .bold()
                .padding()
            Text("Press hard on the thing below")
            
            Text("Touch radius: \(touchRadius)")
                .padding(.top, 10)
            
            Spacer()
                .frame(height: 50)
            
            Button {
                print("Button tapped")
            } label: {
                Label("Press deez nutz", systemImage: "chevron.down")
            }
            .onTouch(perform: handleTouchChanges)
            .contextMenu()
            .fixedSize()
        }
    }
    
    func handleTouchChanges(_ location: CGPoint, _ radius: CGFloat) {
        touchRadius = radius
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice("iPhone 13")
    }
}
