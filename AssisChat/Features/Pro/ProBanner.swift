//
//  ProBanner.swift
//  AssisChat
//
//  Created by Nooc on 2023-03-19.
//

import SwiftUI

struct ProBanner: View {
    @State private var introductionShowing = false

    var body: some View {
        ZStack(alignment: .topLeading) {
            Image(systemName: "crown.fill")
                .opacity(0.5)
                .font(.system(size: 120))
                .offset(x: -45, y: 30)
                .frame(height: 110)

            HStack {
                Spacer()

                VStack(alignment: .trailing) {
                    HStack(alignment: .center) {
                        Text(String("PRO"))
                            .bold()
                            .font(.system(.footnote, design: .rounded))
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                            .foregroundColor(.accentColor)
                            .background(Color.primary)
                            .cornerRadius(20)

                        Text("You are experiencing the Pro")
                            .bold()
                            .font(.system(.body, design: .rounded))
                    }
                    Spacer()
                    Text("Learn More")
                        .bold()
                        .font(.system(.footnote, design: .rounded))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(Color.primary)
                        .cornerRadius(20)
                        .foregroundColor(.accentColor)
                }
                .padding(.vertical, 10)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)

            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [5]))
                .padding(5)
        }
        .colorScheme(.dark)
        .background(Color.accentColor)
        .onTapGesture {
            introductionShowing.toggle()
        }
        .sheet(isPresented: $introductionShowing) {
            ProIntroductionView()
        }
    }
}

struct ProBanner_Previews: PreviewProvider {
    static var previews: some View {
        ProBanner()
            .previewLayout(.fixed(width: 400, height: 100))
    }
}
