//
//  ViewController.swift
//  TareaMarcandoRuta
//
//  Created by Cesar Gonzalez on 20/11/16.
//  Copyright © 2016 Cesar Gonzalez. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapa: MKMapView!
    
    private let manejador = CLLocationManager()
    
    private var longitudInicial:Double?
    private var latitudInicial:Double?
    
    private var disTempo:Double = 0 
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        manejador.delegate = self
        manejador.desiredAccuracy = kCLLocationAccuracyBest
        manejador.requestWhenInUseAuthorization()
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse{
            
            manejador.startUpdatingLocation()
            mapa.showsUserLocation = true
            
            latitudInicial = Double(manager.location!.coordinate.latitude)
            longitudInicial = Double(manager.location!.coordinate.longitude)
            
            
            var puntoInicial = CLLocationCoordinate2D()
            puntoInicial.latitude = latitudInicial!
            puntoInicial.longitude = longitudInicial!
        
            
            // Zoom
            let latDelta: CLLocationDegrees = 0.01
            let lonDelta: CLLocationDegrees = 0.01
            let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
            let region: MKCoordinateRegion = MKCoordinateRegionMake(puntoInicial, span)
            mapa.setRegion(region, animated: false)
            
            
            // Centrar en mapa
            mapa.setCenter(puntoInicial, animated: false)
            
            
            
            
        }else{
            manejador.stopUpdatingLocation()
            mapa.showsUserLocation = false
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        var puntoActual = CLLocationCoordinate2D()
        puntoActual.latitude = manager.location!.coordinate.latitude
        puntoActual.longitude = manager.location!.coordinate.longitude
        
        // Centrar en mapa
        mapa.setCenter(puntoActual, animated: false)
        
        
        let latitud = Double(manager.location!.coordinate.latitude)
        let longitud = Double(manager.location!.coordinate.longitude)
        
        print("Latitud: \(latitud)")
        print("Longitud: \(longitud)")
        
        
        
        let distancia = obtenerDistancia(latitudInicial: latitudInicial!, longitudInicial: longitudInicial!, latitudFinal: latitud, longitudFinal: longitud)
        
        
        let distanciaMTS = distancia*1000
        
        
        if Int(distanciaMTS - disTempo) > 50{
            
            disTempo = distanciaMTS
            
            var punto = CLLocationCoordinate2D()
            punto.latitude = latitud
            punto.longitude = longitud
            
            let pin = MKPointAnnotation()
            pin.title = "(\(longitud), \(latitud))"
            pin.subtitle = "Distancia Recorrida: \(distanciaMTS)mts"
            pin.coordinate = punto
            
            mapa.addAnnotation(pin)
            
    
            
        }
        
        print("Distancia KM: \(distancia)")
        print("Distancia MTS: \(distanciaMTS)")

        
    }
    
    func obtenerDistancia(latitudInicial:Double, longitudInicial:Double, latitudFinal:Double, longitudFinal:Double) -> Double{
        
        let lat1rad = latitudInicial * M_PI/180
        let lon1rad = longitudInicial * M_PI/180
        let lat2rad = latitudFinal * M_PI/180
        let lon2rad = longitudFinal * M_PI/180
        
        
        let difLat = lat2rad - lat1rad
        let difLon = lon2rad - lon1rad
        
        let senDifLat2 = sin(difLat/2)
        let senDifLon2 = sin(difLon/2)
        
        let a = senDifLat2 * senDifLat2 + senDifLon2 * senDifLon2  * cos(lat1rad) * cos(lat2rad)
        
        
        let c = 2 * asin(sqrt(a))
        let R = 6372.8
        
        
        return R * c
    }


    
    @IBAction func segmentedControlAction(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            mapa.mapType = MKMapType.standard
        case 1:
            mapa.mapType = MKMapType.satellite
        case 2:
            mapa.mapType = MKMapType.hybrid
        default: break
        }
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

