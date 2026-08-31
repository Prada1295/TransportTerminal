//
//  VehicleDetails.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 31/08/26.
//
import Foundation

public struct VehicleDetailsDTO: Equatable {

    public let vehicle: Vehicle
    public let company: Company

    public init(
        vehicle: Vehicle,
        company: Company
    ) {
        self.vehicle = vehicle
        self.company = company
    }
}
