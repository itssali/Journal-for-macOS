//
//  OrbTest.swift
//  Journal for macOS
//
//  Created by Ali Nasser on 14/11/2024.
//

import Orb
import SwiftUI

// All Orb Configurations
enum OrbStyle: String, CaseIterable {
    case minimal = "Minimal"
    case arctic = "Arctic"
    case shadow = "Shadow"
    case sunset = "Sunset"
    case toxic = "Toxic"
    case magma = "Magma"
    case cosmic = "Cosmic"
    case ocean = "Ocean"
    case forest = "Forest"
    
    var configuration: OrbConfiguration {
        switch self {
        case .minimal:
            return OrbConfiguration(
                backgroundColors: [.gray, .white],
                glowColor: .white,
                showWavyBlobs: false,
                showParticles: false,
                speed: 30
            )
        case .arctic:
            return OrbConfiguration(
                backgroundColors: [.cyan, .white, .blue],
                glowColor: .white,
                coreGlowIntensity: 0.75,
                showParticles: true,
                speed: 40
            )
        case .shadow:
            return OrbConfiguration(
                backgroundColors: [.black, .gray],
                glowColor: .gray,
                coreGlowIntensity: 0.7,
                showParticles: false
            )
        case .sunset:
            return OrbConfiguration(
                backgroundColors: [.orange, .red, .pink],
                glowColor: .orange,
                coreGlowIntensity: 0.8
            )
        case .toxic:
            return OrbConfiguration(
                backgroundColors: [.green, .yellow],
                glowColor: .green,
                coreGlowIntensity: 0.9,
                showParticles: true,
                speed: 45
            )
        case .magma:
            return OrbConfiguration(
                backgroundColors: [.red, .orange, .yellow],
                glowColor: .orange,
                coreGlowIntensity: 0.8,
                speed: 50
            )
        case .cosmic:
            return OrbConfiguration(
                backgroundColors: [.purple, .blue, .pink],
                glowColor: .purple,
                coreGlowIntensity: 0.85,
                speed: 35
            )
        case .ocean:
            return OrbConfiguration(
                backgroundColors: [.blue, .cyan, .teal],
                glowColor: .blue,
                coreGlowIntensity: 0.7,
                speed: 55
            )
        case .forest:
            return OrbConfiguration(
                backgroundColors: [.green, .mint, .teal],
                glowColor: .green,
                coreGlowIntensity: 0.6,
                speed: 45
            )
        }
    }
}

struct OrbTest: View {
    @State private var selectedStyle: OrbStyle = .minimal
    
    var body: some View {
        VStack(spacing: 20) {
            Picker("Orb Style", selection: $selectedStyle) {
                ForEach(OrbStyle.allCases, id: \.self) { style in
                    Text(style.rawValue).tag(style)
                }
            }
            .pickerStyle(.menu)
            
            Text(selectedStyle.rawValue)
                .font(.headline)
            
            OrbView(configuration: selectedStyle.configuration)
                .frame(width: 200, height: 200)
        }
        .padding()
    }
}

#Preview {
    OrbTest()
}

