//
//  Routes.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 21/08/26.
//

import Foundation

public struct Route: Identifiable, Equatable {
    public let id: UUID
    public var origin: String
    public var destination: String
    public var estimatedMinutes: Int
    public var isActive: Bool
}
