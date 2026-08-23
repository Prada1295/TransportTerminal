//
//  Bay.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 21/08/26.
//
import Foundation

public struct Bay: Identifiable {
    public let id: UUID
    public var code: String
    public var active: Bool
}
