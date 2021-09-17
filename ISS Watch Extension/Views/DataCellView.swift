//
//  CustomDataCellView.swift
//  ISS Real-Time Tracker
//
//  Created by Michael Stebel on 9/17/21.
//  Copyright © 2021 Michael Stebel Consulting, LLC. All rights reserved.
//

import SwiftUI

/// Custom cell view
struct DataCellView: View {
    
    let title: String
    let latitude: String
    let longitude: String
    
    var body: some View {
        VStack {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
            }
            Spacer()
            HStack (alignment: .top) {
                HStack {
                    Spacer()
                    Text(latitude)
                        .font(.custom(Theme.appFont, size: 17))
                        .bold()
                }
                Text("LAT")
                    .font(.subheadline)
                    .foregroundColor(.ISSRTT3DRed)
                    .bold()
            }
            HStack(alignment: .top) {
                HStack {
                    Spacer()
                    Text(longitude)
                        .font(.custom(Theme.appFont, size: 17))
                        .bold()
                }
                Text("LON")
                    .font(.subheadline)
                    .foregroundColor(.ISSRTT3DRed)
                    .bold()
            }
        }
        .padding()
        .background(Color.ISSRTT3DBackground)
        .cornerRadius(5.0)
    }
}

struct DataCellView_Previews: PreviewProvider {
    static var previews: some View {
        DataCellView(title: "Title", latitude: "test", longitude: "test")
    }
}