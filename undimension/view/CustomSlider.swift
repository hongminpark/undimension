//

import SwiftUI

struct CustomSlider: View {
    @Binding var value: CGFloat
    let range: ClosedRange<CGFloat>
    let step: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // The timeline track
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 5)
                
                // The timeline progress
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: geometry.size.width * (value - range.lowerBound) / (range.upperBound - range.lowerBound), height: 5)
                
                // The draggable indicator
                Circle()
                    .fill(Color.white)
                    .frame(width: 25, height: 25)
                    .shadow(radius: 2)
                    .offset(x: geometry.size.width * (value - range.lowerBound) / (range.upperBound - range.lowerBound) - 12.5)
                    .gesture(DragGesture(minimumDistance: 0).onChanged({ gesture in
                        let sliderWidth = geometry.size.width
                        let newValue = (gesture.location.x / sliderWidth) * (range.upperBound - range.lowerBound) + range.lowerBound
                        value = min(max(newValue, range.lowerBound), range.upperBound)
                    }))
            }
        }
        .frame(height: 25)
    }
}

#Preview {    
    CustomSlider(value: .constant(0.5), range: 0...1, step: 0.01)
                .padding()
                .previewLayout(.sizeThatFits)
}
