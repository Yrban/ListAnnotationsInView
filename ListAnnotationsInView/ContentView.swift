//
//  ContentView.swift
//  ListAnnotationsInView
//
//  Created by Developer on 11/25/21.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    
    @State var locationsInView: Set<LocationAnnotation> = []
    var body: some View {
        VStack {
            MapView(locationsInView: $locationsInView, currentLocation: CLLocationCoordinate2D(latitude: 44.967243, longitude: -103.771556))
                .padding()
            List {
                ForEach(Array(locationsInView), id: \.self) { location in
                    Text(location.title ?? "")
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
