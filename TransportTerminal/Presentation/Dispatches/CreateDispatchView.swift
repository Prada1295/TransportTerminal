//
//  CreateDispatchView.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 20/09/26.
//

import SwiftUI

struct CreateDispatchView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: CreateDispatchViewModel

    init(viewModel: CreateDispatchViewModel) {
        _viewModel = State(
            initialValue: viewModel
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                if let errorMessage = viewModel.errorMessage {
                    errorSection(message: errorMessage)
                }

                vehicleSection

                routeSection

                baySection

                departureSection

                createSection
            }
            .navigationTitle("Create Dispatch")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .overlay {
                if viewModel.isLoading {
                    loadingOverlay
                }
            }
            .task {
                await viewModel.loadOptions()
            }
        }
    }
}

// MARK: - Sections

private extension CreateDispatchView {

    var vehicleSection: some View {
        Section("Vehicle") {
            Picker(
                "Vehicle",
                selection: $viewModel.selectedVehicleId
            ) {
                Text("Select Vehicle")
                    .tag(UUID?.none)

                ForEach(viewModel.vehicles) { vehicle in
                    Text(vehicle.plate)
                        .tag(Optional(vehicle.id))
                }
            }
        }
    }

    var routeSection: some View {
        Section("Route") {
            Picker(
                "Route",
                selection: $viewModel.selectedRouteId
            ) {
                Text("Select Route")
                    .tag(UUID?.none)

                ForEach(viewModel.routes) { route in
                    Text(
                        "\(route.origin) → \(route.destination)"
                    )
                    .tag(Optional(route.id))
                }
            }
        }
    }

    var baySection: some View {
        Section("Bay") {
            Picker(
                "Bay",
                selection: $viewModel.selectedBayId
            ) {
                Text("Select Bay")
                    .tag(UUID?.none)

                ForEach(viewModel.bays) { bay in
                    Text(bay.code)
                        .tag(Optional(bay.id))
                }
            }
        }
    }

    var departureSection: some View {
        Section("Departure") {
            DatePicker(
                "Scheduled Departure",
                selection: $viewModel.scheduledDeparture,
                displayedComponents: [
                    .date,
                    .hourAndMinute
                ]
            )
        }
    }

    var createSection: some View {
        Section {
            Button {
                Task {
                    if await viewModel.createDispatch() != nil {
                        dismiss()
                    }
                }
            } label: {
                HStack {
                    Spacer()

                    if viewModel.isCreating {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Text("Create Dispatch")
                            .fontWeight(.semibold)
                    }

                    Spacer()
                }
            }
            .disabled(!viewModel.canCreateDispatch)
        }
    }

    func errorSection(message: String) -> some View {
        Section {
            Label(
                message,
                systemImage: "exclamationmark.triangle"
            )
            .foregroundStyle(.red)
        }
    }
}

// MARK: - Loading

private extension CreateDispatchView {

    var loadingOverlay: some View {
        ZStack {
            Color.black
                .opacity(0.08)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                ProgressView()

                Text("Loading options...")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(24)
            .background(
                .regularMaterial,
                in: RoundedRectangle(
                    cornerRadius: 16
                )
            )
        }
    }
}

// MARK: - Preview

#Preview {
    CreateDispatchView(
        viewModel: CreateDispatchViewModel(
            vehicleRepository:
                PreviewCreateDispatchVehicleRepository(),
            routeRepository:
                PreviewCreateDispatchRouteRepository(),
            bayRepository:
                PreviewCreateDispatchBayRepository(),
            createDispatchUseCase:
                PreviewCreateDispatchUseCase()
        )
    )
}

// MARK: - Preview Fakes

private struct PreviewCreateDispatchVehicleRepository:
    VehicleRepository {

    func getAll() async throws -> [Vehicle] {
        [
            Vehicle(
                id: UUID(),
                plate: "ABC123",
                companyId: UUID(),
                type: .bus,
                capacity: 40,
                status: .insideTerminal
            ),
            Vehicle(
                id: UUID(),
                plate: "XYZ789",
                companyId: UUID(),
                type: .buseta,
                capacity: 30,
                status: .insideTerminal
            )
        ]
    }

    func getById(_ id: UUID) async throws -> Vehicle? {
        nil
    }

    func save(_ vehicle: Vehicle) async throws {}

    func update(_ vehicle: Vehicle) async throws {}
}

private struct PreviewCreateDispatchRouteRepository:
    RouteRepository {

    func getById(_ id: UUID) async throws -> Route? {
        nil
    }

    func getAll() async throws -> [Route] {
        [
            Route(
                id: UUID(),
                origin: "Medellín",
                destination: "Bogotá",
                estimatedMinutes: 420,
                isActive: true
            ),
            Route(
                id: UUID(),
                origin: "Medellín",
                destination: "Cali",
                estimatedMinutes: 360,
                isActive: true
            )
        ]
    }

    func save(_ route: Route) async throws {}
}

private struct PreviewCreateDispatchBayRepository:
    BayRepository {

    func getById(_ id: UUID) async throws -> Bay? {
        nil
    }

    func getAll() async throws -> [Bay] {
        [
            Bay(
                id: UUID(),
                code: "B01",
                active: true
            ),
            Bay(
                id: UUID(),
                code: "B02",
                active: true
            )
        ]
    }

    func save(_ bay: Bay) async throws {}
}

private struct PreviewCreateDispatchUseCase:
    CreateDispatchUseCase {

    func execute(
        vehicleId: UUID,
        routeId: UUID,
        bayId: UUID,
        scheduledDeparture: Date
    ) async throws -> CreateDispatchResult {

        CreateDispatchResult(
            dispatchId: UUID(),
            vehicleId: vehicleId,
            routeId: routeId,
            bayId: bayId,
            scheduledDeparture: scheduledDeparture,
            status: .scheduled
        )
    }
}
