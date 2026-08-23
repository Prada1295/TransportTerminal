//
//  VehicleStatus.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 21/08/26.
//
import Foundation

public enum VehicleStatus: String, Codable {
    case outsideTerminal
    case insideTerminal
    case dispatched
    case maintenance
}
