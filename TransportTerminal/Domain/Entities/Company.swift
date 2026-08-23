//
//  Company.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 21/08/26.
//
import Foundation

public struct Company: Identifiable, Equatable {
    public let id: UUID
    public var name: String
    public var nit: String
    public var isActive: Bool
}
