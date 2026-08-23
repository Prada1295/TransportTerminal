//
//  VehicleRepository.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 21/08/26.
//
import Foundation

public protocol VehicleRepository {

    func getAll() async throws -> [Vehicle]
    func getById(_ id: UUID) async throws -> Vehicle?
    func save(_ vehicle: Vehicle) async throws
    func update(_ vehicle: Vehicle) async throws
}
