//
//  InMemorySeedData.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 25/08/26.
//

import Foundation

public enum InMemorySeedData {

    // MARK: - Companies

    public static let bolivarianoCompanyId =
        UUID(uuidString: "11111111-1111-1111-1111-111111111111")!

    public static let rapidoOchoaCompanyId =
        UUID(uuidString: "22222222-2222-2222-2222-222222222222")!

    public static let flotaOccidentalCompanyId =
        UUID(uuidString: "33333333-3333-3333-3333-333333333333")!

    // MARK: - Routes

    public static let neivaBogotaRouteId =
        UUID(uuidString: "44444444-4444-4444-4444-444444444444")!

    public static let medellinCaliRouteId =
        UUID(uuidString: "55555555-5555-5555-5555-555555555555")!

    public static let neivaFlorenciaRouteId =
        UUID(uuidString: "66666666-6666-6666-6666-666666666666")!

    // MARK: - Bays

    public static let bayA1Id =
        UUID(uuidString: "77777777-7777-7777-7777-777777777777")!

    public static let bayA2Id =
        UUID(uuidString: "88888888-8888-8888-8888-888888888888")!

    public static let bayB1Id =
        UUID(uuidString: "99999999-9999-9999-9999-999999999999")!

    // MARK: - Companies

    public static let companies: [Company] = [

        Company(
            id: bolivarianoCompanyId,
            name: "Expreso Bolivariano",
            nit: "900123456",
            isActive: true
        ),

        Company(
            id: rapidoOchoaCompanyId,
            name: "Rapido Ochoa",
            nit: "900654321",
            isActive: true
        ),

        Company(
            id: flotaOccidentalCompanyId,
            name: "Flota Occidental",
            nit: "901987654",
            isActive: false
        )
    ]

    // MARK: - Vehicles

    public static let vehicles: [Vehicle] = [

        // MARK: Inside Terminal

        Vehicle(
            id: UUID(
                uuidString: "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"
            )!,
            plate: "DEF456",
            companyId: rapidoOchoaCompanyId,
            type: .buseta,
            capacity: 28,
            status: .insideTerminal
        ),

        Vehicle(
            id: UUID(
                uuidString: "bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"
            )!,
            plate: "JKL234",
            companyId: bolivarianoCompanyId,
            type: .bus,
            capacity: 42,
            status: .insideTerminal
        ),

        Vehicle(
            id: UUID(
                uuidString: "cccccccc-cccc-cccc-cccc-cccccccccccc"
            )!,
            plate: "MNO567",
            companyId: rapidoOchoaCompanyId,
            type: .bus,
            capacity: 45,
            status: .insideTerminal
        ),

        Vehicle(
            id: UUID(
                uuidString: "dddddddd-dddd-dddd-dddd-dddddddddddd"
            )!,
            plate: "PQR890",
            companyId: bolivarianoCompanyId,
            type: .microbus,
            capacity: 18,
            status: .insideTerminal
        ),

        Vehicle(
            id: UUID(
                uuidString: "eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee"
            )!,
            plate: "STU321",
            companyId: rapidoOchoaCompanyId,
            type: .buseta,
            capacity: 30,
            status: .insideTerminal
        ),

        Vehicle(
            id: UUID(
                uuidString: "ffffffff-ffff-ffff-ffff-ffffffffffff"
            )!,
            plate: "VWX654",
            companyId: bolivarianoCompanyId,
            type: .bus,
            capacity: 40,
            status: .insideTerminal
        ),

        // MARK: Outside Terminal

        Vehicle(
            id: UUID(
                uuidString: "10101010-1010-1010-1010-101010101010"
            )!,
            plate: "ABC123",
            companyId: bolivarianoCompanyId,
            type: .bus,
            capacity: 42,
            status: .outsideTerminal
        ),

        Vehicle(
            id: UUID(
                uuidString: "20202020-2020-2020-2020-202020202020"
            )!,
            plate: "YZA987",
            companyId: rapidoOchoaCompanyId,
            type: .buseta,
            capacity: 28,
            status: .outsideTerminal
        ),

        // MARK: Maintenance

        Vehicle(
            id: UUID(
                uuidString: "30303030-3030-3030-3030-303030303030"
            )!,
            plate: "GHI789",
            companyId: bolivarianoCompanyId,
            type: .microbus,
            capacity: 18,
            status: .maintenance
        )
    ]

    // MARK: - Routes

    public static let routes: [Route] = [

        Route(
            id: neivaBogotaRouteId,
            origin: "Neiva",
            destination: "Bogota",
            estimatedMinutes: 360,
            isActive: true
        ),

        Route(
            id: medellinCaliRouteId,
            origin: "Medellin",
            destination: "Cali",
            estimatedMinutes: 430,
            isActive: true
        ),

        Route(
            id: neivaFlorenciaRouteId,
            origin: "Neiva",
            destination: "Florencia",
            estimatedMinutes: 210,
            isActive: false
        )
    ]

    // MARK: - Bays

    public static let bays: [Bay] = [

        Bay(
            id: bayA1Id,
            code: "A1",
            active: true
        ),

        Bay(
            id: bayA2Id,
            code: "A2",
            active: true
        ),

        Bay(
            id: bayB1Id,
            code: "B1",
            active: false
        )
    ]

    // MARK: - Dispatches

    public static let dispatches: [Dispatch] = []

    // MARK: - Movements

    public static let movements: [VehicleMovement] = []
}
