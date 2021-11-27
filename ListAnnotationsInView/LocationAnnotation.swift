
import MapKit
import UIKit


final class LocationAnnotation: NSObject, MKAnnotation, Identifiable {
    var id: String
    var title: String?
    var coordinate: CLLocationCoordinate2D

    override init() {
        self.id = ""
        self.title = ""
        self.coordinate = CLLocationCoordinate2D()
        super.init()
    }
    
    init(coordinate: CLLocationCoordinate2D) {
        self.id = (coordinate.latitude as Double).truncateToPlace(6).description
        self.title = ((coordinate.latitude as Double).truncateToPlace(6).description + ", " + (coordinate.longitude as Double).truncateToPlace(6).description)
        self.coordinate = coordinate
    }
}

fileprivate extension Double {
    func truncateToPlace(_ place: Int) -> Double {
        let trunc = Double(truncating: pow(10, place) as NSNumber)
        return (Double(Int(self * trunc)) / trunc)
    }
}
