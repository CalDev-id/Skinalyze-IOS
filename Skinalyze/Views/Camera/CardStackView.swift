//  CardStackView.swift
//  FaceTracking
//
//  Created by Ali Haidar on 10/4/24.
//

import SwiftUI

struct Item: Identifiable {
    let id: Int
    let image: UIImage
    var offset: CGFloat = 0
    var zIndex: Double
}

struct CardStackView: View {
    @State private var selectedIndex = 0
    @Binding private var selectedCardIndex: Int
    @State private var items: [Item]
    let imageSize: CGSize
    let maximumOffset: CGFloat
    
    init(images: [UIImage], selectedCardIndex: Binding<Int>? = nil, imageSize: CGSize = CGSize(width: 100, height: 150)) {
        var createdItems = [Item]()
        for (id, image) in images.enumerated() {
            createdItems.append(Item(id: id, image: image, zIndex: Double(images.count - 1 - id)))
        }
        
        self._selectedCardIndex = selectedCardIndex ?? .constant(0)
        self._items = State(initialValue: createdItems)
        self.imageSize = imageSize
        self.maximumOffset = imageSize.width * 0.75
    }
    
    var body: some View {
        ZStack {
            ForEach(items.indices, id: \.self) { index in
                CardView(item: $items[index], selectedIndex: $selectedIndex, items: $items, selectedCardIndex: $selectedCardIndex, imageSize: imageSize, maximumOffset: maximumOffset)
            }
        }
    }
}

struct CardView: View {
    @Binding var item: Item
    @Binding var selectedIndex: Int
    @Binding var items: [Item]
    @Binding var selectedCardIndex: Int
    let imageSize: CGSize
    let maximumOffset: CGFloat
    
    var body: some View {
        Image(uiImage: item.image)
            .resizable()
            .scaledToFill()
            .frame(width: imageSize.width, height: imageSize.height)
            .clipShape(RoundedRectangle(cornerRadius: imageSize.height * 0.05))
            .overlay(
                RoundedRectangle(cornerRadius: imageSize.height * 0.05)
                    .stroke(.white.opacity(0.20), lineWidth: 4)
                    .padding(-1.5)
            )
            .offset(x: item.offset)
            .zIndex(item.zIndex)
            .rotation3DEffect(
                .degrees(item.offset / maximumOffset * -25.0),
                axis: (x: 0.0, y: 1.0, z: 0.0)
            )
            .rotationEffect(rotationAngle(for: item))
            .scaleEffect(scaleEffect(for: item))
            .offset(x: item.offset / 4)
            .gesture(item.id == selectedIndex ? dragGesture : nil)
    }
    
    private func rotationAngle(for item: Item) -> Angle {
        if item.id == selectedIndex {
            return .degrees(Double(item.offset / maximumOffset * 10.0))
        } else {
            let baseAngle: CGFloat = item.id % 2 == 0 ? 15.0 : -15.0
            let offsetRatio = CGFloat(abs(items[selectedIndex].offset)) / maximumOffset
            return .degrees(Double(baseAngle * (1 - offsetRatio)))
        }
    }
    
    private func scaleEffect(for item: Item) -> CGSize {
        if item.id == selectedIndex {
            let scale = 1 - (abs(item.offset / maximumOffset) * 0.5)
            return CGSize(width: scale, height: 1 - (abs(item.offset / maximumOffset) * 0.3))
        } else {
            let scale = 0.8 + (0.2 * abs(items[selectedIndex].offset / maximumOffset))
            return CGSize(width: scale, height: scale)
        }
    }
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                withAnimation(.linear(duration: 0.1)) {
                    item.offset = value.translation.width
                    withAnimation {
                        item.zIndex = Double(items.count - 1)
                    }
                }
            }
            .onEnded { value in
                let swipeThreshold: CGFloat = maximumOffset * 0.3 // Adjust this value to change sensitivity
                
                if abs(value.translation.width) > swipeThreshold {
                    // Swipe is considered complete
                    for i in items.indices {
                        items[i].zIndex += 1
                    }
                    item.zIndex = 0
                    
                    withAnimation {
                        item.offset = .zero
                        selectedIndex = items.first(where: { $0.zIndex == Double(items.count - 1)})?.id ?? 0
                        selectedCardIndex = selectedIndex
                    }
                } else {
                    // Swipe is not complete, return to original position
                    withAnimation {
                        item.offset = .zero
                    }
                }
            }
    }
}

//struct CardStackView_Previews: PreviewProvider {
//    static var previews: some View {
//        CardStackView(images: [.imgTest], selectedCardIndex: .constant(0), imageSize: CGSize(width: 220, height: 320))
//    }
//}
