//
//  ContentView.swift
//  RealTimeBikeFitAnalysis
//
//  Created by Max Krefting on 02/03/2021.
//

import SwiftUI

// To contain all the UI for the video analysis (including camera)
struct ContentView: View {
    
    var body: some View {
        ZStack{
            // Live data, other controls - fit on top of the camera view
            
            CameraView()
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
