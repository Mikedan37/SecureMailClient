//  BurnAfterReadToggle.swift
//  MailClient
//  Created by Michael Danylchuk on 5/13/25.
import SwiftUI

struct BurnAfterReadToggle: View {
    @Binding var isOn: Bool
    @State private var animateBurst = false

    var body: some View {
        ZStack(alignment: .trailing) {
            // 🔥 Burst animation layer
            if animateBurst {
                GeometryReader { geo in
                    let centerX = geo.size.width - 32
                    let centerY = geo.size.height / 2

                    ForEach(0..<8) { i in
                        let angle = Double(i) * .pi / 4
                        Image(systemName: "flame.fill")
                            .resizable()
                            .frame(width: 12, height: 12)
                            .foregroundColor(.orange)
                            .position(x: centerX, y: centerY)
                            .offset(
                                x: cos(angle) * 60,
                                y: sin(angle) * 60
                            )
                            .opacity(animateBurst ? 0 : 1)
                            .scaleEffect(animateBurst ? 2.0 : 0.6)
                            .animation(.easeOut(duration: 0.6), value: animateBurst)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .allowsHitTesting(false)
            }

            // 🧨 Toggle and label
            HStack {
                Text("Burn after reading 🔥")
                Toggle("", isOn: $isOn)
                    .labelsHidden()
                    .onChange(of: isOn) { newValue in
                        if newValue {
                            animateOnce()
                        }
                    }
            }
            .padding(.horizontal)
        }
        .frame(height: 40) // ⬅️ tightened vertical spacing
        .clipped()
    }

    private func animateOnce() {
        animateBurst = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            withAnimation {
                animateBurst = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                animateBurst = false
            }
        }
    }
}
