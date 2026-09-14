//
//  RegisterVehicleExitView.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 7/09/26.
//
import SwiftUI

struct RegisterVehicleExitView: View {

    let viewModel: RegisterVehicleExitViewModel

    @Environment(\.dismiss) private var dismiss

    @State private var selectedVehicleId: UUID?
    @State private var showingConfirmation = false
    @State private var showingError = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.vehiclesInsideTerminal.isEmpty {
                    ProgressView("Loading vehicles...")
                } else if viewModel.vehiclesInsideTerminal.isEmpty {
                    ContentUnavailableView(
                        "No Vehicles Inside",
                        systemImage: "bus",
                        description: Text(
                            "There are currently no vehicles inside the terminal."
                        )
                    )
                } else {
                    vehicleList
                }
            }
            .navigationTitle("Vehicle Exit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onChange(of: viewModel.errorMessage) {
                showingError = viewModel.errorMessage != nil
            }
            .alert(
                "Unable to Register Exit",
                isPresented: $showingError
            ) {
                Button("OK", role: .cancel) {
                    viewModel.clearError()
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .task {
                await viewModel.loadVehiclesInsideTerminal()
            }
            .confirmationDialog(
                "Register Vehicle Exit?",
                isPresented: $showingConfirmation,
                titleVisibility: .visible
            ) {
                Button("Register Exit", role: .destructive) {
                    guard let selectedVehicleId else {
                        return
                    }

                    Task {
                        await viewModel.registerExit(
                            vehicleId: selectedVehicleId
                        )
                    }
                }

                Button("Cancel", role: .cancel) {
                    selectedVehicleId = nil
                }
            } message: {
                Text(confirmationMessage)
            }
            .onChange(of: viewModel.exitResult) {
                guard viewModel.exitResult != nil else {
                    return
                }

                dismiss()
            }
        }
    }

    private var vehicleList: some View {
        List {
            Section("Vehicles Inside Terminal") {
                ForEach(viewModel.vehiclesInsideTerminal) { vehicle in
                    Button {
                        selectedVehicleId = vehicle.id
                        showingConfirmation = true
                    } label: {
                        vehicleRow(vehicle)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func vehicleRow(_ vehicle: Vehicle) -> some View {
        HStack(spacing: 16) {
            Image(systemName: "bus")
                .font(.title2)
                .frame(width: 36)
                .foregroundStyle(.tint)

            VStack(alignment: .leading, spacing: 6) {
                Text(vehicle.plate)
                    .font(.headline)

                Text(vehicle.type.rawValue.capitalized)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("\(vehicle.capacity) passengers")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 6)
    }

    private var confirmationMessage: String {
        guard
            let selectedVehicleId,
            let vehicle = viewModel.vehiclesInsideTerminal.first(
                where: { $0.id == selectedVehicleId }
            )
        else {
            return "Are you sure you want to register this vehicle's exit?"
        }

        return """
        Vehicle \(vehicle.plate) will be registered as outside the terminal.
        """
    }
}
