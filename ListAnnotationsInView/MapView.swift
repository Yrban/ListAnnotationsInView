//
//  MapView.swift
//  HotHorse
//
//  Created by Developer on 11/17/20.
//

import SwiftUI
import MapKit
import Combine

struct MapView: UIViewRepresentable {
    @Binding var locationsInView: Set<LocationAnnotation>
    @State var currentLocation: CLLocationCoordinate2D
    @State var locations: Set<LocationAnnotation> = []
    private var locationsArray: [LocationAnnotation] {
        locations.map( { $0 })
    }
    
    let mapView = MKMapView()
    let regionRadius: CLLocationDistance = 5000
        
    func makeUIView(context: Context) -> MKMapView {
        let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        let region = MKCoordinateRegion(center: currentLocation, span: span)
        let longPressRecognizer = UILongPressGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.triggerLongPressAction(sender:)))
        let annotations = locationsArray
        
        mapView.delegate = context.coordinator
        mapView.region = region
        mapView.showsScale = true
        mapView.showsUserLocation = false
        mapView.mapType = .hybrid
        mapView.isZoomEnabled = true
        mapView.addGestureRecognizer(longPressRecognizer)
        mapView.addAnnotations(annotations)
        
        return mapView
    }
    
    
    func updateUIView(_ view: MKMapView, context: Context) {
        let annotations = locationsArray
        view.removeAnnotations(annotations)
        view.addAnnotations(annotations)
    }
    
    func updateLocationsInView() {
    let mapRect = mapRectFor(region: mapView.region)
        if let locInView = mapView.annotations(in: mapRect) as? Set<LocationAnnotation> {
            locationsInView = locInView
        }
    }

    func mapRectFor(region: MKCoordinateRegion) -> MKMapRect {
        let topLeft = CLLocationCoordinate2D(latitude: region.center.latitude + (region.span.latitudeDelta/2), longitude: region.center.longitude - (region.span.longitudeDelta/2))
        let bottomRight = CLLocationCoordinate2D(latitude: region.center.latitude - (region.span.latitudeDelta/2), longitude: region.center.longitude + (region.span.longitudeDelta/2))
        
        let topLeftPoint = MKMapPoint(topLeft)
        let bottomRightPoint = MKMapPoint(bottomRight)
        
        return MKMapRect(origin: MKMapPoint(x:min(topLeftPoint.x,bottomRightPoint.x), y:min(topLeftPoint.y,bottomRightPoint.y)), size: MKMapSize(width: abs(topLeftPoint.x-bottomRightPoint.x), height: abs(topLeftPoint.y-bottomRightPoint.y)))
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        
        init(_ parent: MapView) {
            self.parent = parent
        }
        
        func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
            parent.updateLocationsInView()
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let identifier = "Placemark"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
                annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            } else {
                annotationView?.annotation = annotation
            }
            return annotationView
        }
        
        @objc func triggerLongPressAction(sender: UILongPressGestureRecognizer) {
            
            if sender.state == .ended {
                let position = sender.location(in: parent.mapView)
                let longPressLocation = parent.mapView.convert(position, toCoordinateFrom: parent.mapView)
                let annotation = LocationAnnotation(coordinate: longPressLocation)
                parent.locations.insert(annotation)
                // The call to updateLocationsInView() needs to be delayed ever so slightly, or the latest annotation will be left out.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    self.parent.updateLocationsInView()
                }
            }
        }
    }
}


