//
//  BlockView.swift
//  Versea
//
//  Created by Hazel Gong on 2024/9/15.

// add onTap

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

// 单个方块的视图，包括文字显示和背景效果
struct BlockView: View {
    @Binding var word: String
    @Binding var backgroundColor: Color
    var noiseImage: UIImage
    var onChange: ((String, Color) -> Void)?

    var body: some View {
        ZStack {
            Image(uiImage: noiseImage)
                .resizable()
                .scaledToFill()
                .opacity(1)
            backgroundColor
                .opacity(0.75).animation(.easeIn(duration: 1))
            withAnimation(.easeIn(duration: 1.5)) {
                Text(word)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .font(.custom("Pixelify Sans", size: 25))
                    .bold()
                    .padding(EdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2))
            }

        }
        .clipped()
        .onTapGesture {
            let newWord = RegionManager.shared.generateRandomWord()
            let newColor = Color.randomCustomColor()
            onChange?(newWord, newColor)
        }
    }
}
