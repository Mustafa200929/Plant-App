//
//  SwipeToSelectView.swift
//  Challenge 3
//
//  Created by Mustafa Topiwala on 21/11/25.
//
import SwiftUI

struct SwipeToConfirm: View {
    let title: String
    var backgroundTint: Color = Color(hex: "DFFFE9")
    var height: CGFloat = 56
    var cornerRadius: CGFloat = 28
    var handleSize: CGFloat = 52
    var onConfirm: () -> Void

    @State private var dragOffset: CGFloat = 0
    @State private var confirmed: Bool = false

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let maxOffset = max(0, width - handleSize - 8)
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.primary.opacity(0.12))
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(backgroundTint)
                        .opacity(0.35)
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(backgroundTint)
                        .frame(width: max(handleSize, dragOffset + handleSize))
                        .animation(.easeOut(duration: 0.15), value: dragOffset)
                }
                Text(confirmed ? "Done" : title)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)
                    .opacity(confirmed ? 0.9 : 0.8)

                HStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Image(systemName: confirmed ? "checkmark" : "chevron.right")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(.primary)
                        )
                        .frame(width: handleSize, height: handleSize)
                        .shadow(color: .primary.opacity(0.15), radius: 6, y: 3)
                        .offset(x: dragOffset)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    guard !confirmed else { return }
                                    let x = max(0, value.translation.width)
                                    dragOffset = min(x, maxOffset)
                                }
                                .onEnded { _ in
                                    guard !confirmed else { return }
                                    if dragOffset > maxOffset * 0.85 {
                                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                            dragOffset = maxOffset
                                            confirmed = true
                                        }
                                        onConfirm()
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                            withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                                dragOffset = 0
                                                confirmed = false
                                            }
                                        }
                                    } else {
         
                                        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                            dragOffset = 0
                                        }
                                    }
                                }
                        )
                    Spacer()
                }
                .padding(4)
            }
            .frame(height: height)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .contentShape(RoundedRectangle(cornerRadius: cornerRadius))
        }
        .frame(height: height)
    }
}
