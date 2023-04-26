//
//  ProBanner.swift
//  AssisChat
//
//  Created by Nooc on 2023-03-19.
//

import SwiftUI

struct ProBanner: View {
    @EnvironmentObject private var proFeature: ProFeature

    @State private var introductionShowing = false

    var body: some View {
        ZStack(alignment: .topLeading) {
            Image(systemName: "cup.and.saucer")
                .opacity(0.5)
                .font(.system(size: 120))
                .offset(x: -45, y: 30)
                .frame(height: 110)

            HStack {
                Spacer()

                VStack(alignment: .trailing) {
                    HStack(alignment: .center) {
                        if proFeature.pro {
                            Text("Hey, Friend")
                                .bold()
                                .font(.system(.body, design: .rounded))
                        } else {
                            Text(String("Coffee"))
                                .bold()
                                .font(.system(.footnote, design: .rounded))
                                .padding(.vertical, 5)
                                .padding(.horizontal, 10)
                                .foregroundColor(.accentColor)
                                .background(Color.primary)
                                .cornerRadius(20)

                            Text("You are trying the Coffee plan")
                                .bold()
                                .font(.system(.body, design: .rounded))
                        }
                    }
                    Spacer()
                    Text(proFeature.pro ? proFeature.largestPurchasedProProduct?.displayName ?? "Coffee" : String(localized: "Learn More"))
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
        .cornerRadius(12)
        .sheet(isPresented: $introductionShowing) {
            ProIntroductionView()
            #if os(macOS)
                .frame(width: 400, height: 500)
            #endif
        }
    }
}

struct ProBanner_Previews: PreviewProvider {
    static var previews: some View {
        ProBanner()
            .previewLayout(.fixed(width: 400, height: 100))
    }
}
