//
//  CompanyRepository.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 21/08/26.
//
import Foundation

public protocol CompanyRepository {
    func getById(_ id: UUID) async throws -> Company?
    func getAll() async throws -> [Company]
    func save(_ company: Company) async throws
}
