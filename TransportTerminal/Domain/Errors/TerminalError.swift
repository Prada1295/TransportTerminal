//
//  TerminalError.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 21/08/26.
//

public enum TerminalError: Error, Equatable {
    case vehicleNotFound
    case companyNotFound
    case companyInactive
    case vehicleAlreadyInside
    case vehicleInMaintenance
}
