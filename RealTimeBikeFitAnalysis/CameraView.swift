//
//  CameraView.swift
//  RealTimeBikeFitAnalysis
//
//  Created by Max Krefting on 06/03/2021.
//

import SwiftUI

// To contain all UI specific to the camera
struct CameraView: View {
        
    var body: some View {
        ZStack{
            // recording button
            CameraViewController()
        }
        
    }
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}
