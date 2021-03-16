//
//  CameraView.swift
//  RealTimeBikeFitAnalysis
//
//  Created by Max Krefting on 06/03/2021.
//

import SwiftUI

// To contain all UI specific to the camera
struct CameraView: View {
    
    @State private var startRecording: Bool = false
    
    var body: some View {
        ZStack{
            //CameraControllerView(startRecording: $startRecording)
            PoseView()
            // To do - add fancy recording button!
            Button("Start Recording", action: {
                startRecording = true
            })
        }
        
    }
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}
