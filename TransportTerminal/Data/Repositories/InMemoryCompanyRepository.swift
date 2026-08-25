//
//  InMemoryCompanyRepository.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 25/08/26.
//

import Foundation

public actor InMemoryCompanyRepository: CompanyRepository {
    private var companies: [Company]

    public init(companies: [Company] = []) {
        self.companies = companies
    }

    public func getById(_ id: UUID) async throws -> Company? {
        companies.first { $0.id == id }
    }

    public func getAll() async throws -> [Company] {
        companies
    }

    public func save(_ company: Company) async throws {
        companies.append(company)
    }
}
