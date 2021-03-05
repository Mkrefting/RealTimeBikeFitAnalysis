//
//  ContentView.swift
//  RealTimeBikeFitAnalysis
//
//  Created by Max Krefting on 02/03/2021.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        ZStack{
            CameraViewController()
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
