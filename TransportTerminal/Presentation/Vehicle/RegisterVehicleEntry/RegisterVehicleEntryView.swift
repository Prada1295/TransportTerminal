//
//  RegisterVehicleEntryView.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 31/08/26.
//
import SwiftUI

struct RegisterVehicleEntryView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: RegisterVehicleEntryViewModel

    let vehicles: [Vehicle]

    @State private var selectedVehicleId: UUID?
    @State private var showingConfirmation = false

    init(
        vehicles: [Vehicle],
        viewModel: RegisterVehicleEntryViewModel
    ) {
        self.vehicles = vehicles
        _viewModel = State(
            initialValue: viewModel
        )
    }

    var body: some View {

        NavigationStack {

            Form {

                // MARK: - Vehicle Selection

                Section("Select Vehicle") {

                    if vehicles.isEmpty {

                        ContentUnavailableView(
                            "No Vehicles Available",
                            systemImage: "bus",
                            description: Text(
                                "There are no vehicles available for entry."
                            )
                        )

                    } else {

                        ForEach(vehicles) { vehicle in

                            Button {

                                selectedVehicleId = vehicle.id

                            } label: {

                                HStack(spacing: 12) {

                                    Image(
                                        systemName:
                                            vehicle.type.systemImageName
                                    )
                                    .frame(width: 28)
                                    .foregroundStyle(.tint)

                                    VStack(
                                        alignment: .leading,
                                        spacing: 4
                                    ) {

                                        Text(vehicle.plate)
                                            .font(.headline)

                                        Text(
                                            "\(vehicle.type.displayName) • \(vehicle.capacity) passengers"
                                        )
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    }

                                    Spacer()

                                    if selectedVehicleId == vehicle.id {

                                        Image(
                                            systemName: "checkmark.circle.fill"
                                        )
                                        .foregroundStyle(.tint)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                // MARK: - Selected Vehicle

                if let selectedVehicleId,
                   let vehicle = vehicles.first(
                    where: { $0.id == selectedVehicleId }
                   ) {

                    Section("Selected Vehicle") {

                        VStack(
                            alignment: .leading,
                            spacing: 8
                        ) {

                            Text(vehicle.plate)
                                .font(.title3)
                                .fontWeight(.bold)

                            Text(
                                "\(vehicle.type.displayName) • \(vehicle.capacity) passengers"
                            )
                            .foregroundStyle(.secondary)

                            Text(
                                vehicle.status.displayName
                            )
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(
                                .orange.opacity(0.15),
                                in: Capsule()
                            )
                            .foregroundStyle(.orange)
                        }
                        .padding(.vertical, 4)
                    }
                }

                // MARK: - Error

                if let errorMessage = viewModel.errorMessage {

                    Section {

                        Label(
                            errorMessage,
                            systemImage:
                                "exclamationmark.triangle.fill"
                        )
                        .foregroundStyle(.red)
                    }
                }

                // MARK: - Register Entry

                Section {

                    Button {

                        showingConfirmation = true

                    } label: {

                        HStack {

                            Spacer()

                            if viewModel.isLoading {

                                ProgressView()

                            } else {

                                Label(
                                    "Register Vehicle Entry",
                                    systemImage:
                                        "arrow.down.circle.fill"
                                )
                            }

                            Spacer()
                        }
                    }
                    .disabled(
                        selectedVehicleId == nil ||
                        viewModel.isLoading
                    )
                }
            }
            .navigationTitle("Vehicle Entry")
            .navigationBarTitleDisplayMode(.inline)
            .confirmationDialog(
                "Register Vehicle Entry?",
                isPresented: $showingConfirmation,
                titleVisibility: .visible
            ) {

                Button("Register Entry") {

                    guard let selectedVehicleId else {
                        return
                    }

                    Task {

                        await viewModel.registerEntry(
                            vehicleId: selectedVehicleId
                        )
                    }
                }

                Button("Cancel", role: .cancel) {}
            } message: {

                if let selectedVehicleId,
                   let vehicle = vehicles.first(
                    where: { $0.id == selectedVehicleId }
                   ) {

                    Text(
                        "Register the entry of vehicle \(vehicle.plate) into the terminal?"
                    )
                }
            }
            .onChange(of: viewModel.entryResult) {

                if viewModel.entryResult != nil {

                    dismiss()
                }
            }
        }
    }
}

// MARK: - Vehicle Type

private extension VehicleType {

    var systemImageName: String {

        switch self {

        case .bus, .buseta, .microbus:
            return "bus"

        case .van, .taxi:
            return "car"
        }
    }

    var displayName: String {

        switch self {

        case .bus:
            return "Bus"

        case .buseta:
            return "Buseta"

        case .microbus:
            return "Microbus"

        case .van:
            return "Van"

        case .taxi:
            return "Taxi"
        }
    }
}

// MARK: - Vehicle Status

private extension VehicleStatus {

    var displayName: String {

        switch self {

        case .outsideTerminal:
            return "Outside Terminal"

        case .insideTerminal:
            return "Inside Terminal"

        case .dispatched:
            return "Dispatched"

        case .maintenance:
            return "Maintenance"
        }
    }
}
