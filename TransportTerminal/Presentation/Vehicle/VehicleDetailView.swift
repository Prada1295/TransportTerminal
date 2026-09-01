//
//  VehicleDetailView.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 31/08/26.
//
import SwiftUI

struct VehicleDetailView: View {

    let vehicleId: UUID

    @State private var viewModel: VehicleDetailViewModel


    init(
        vehicleId: UUID,
        viewModel: VehicleDetailViewModel
    ) {
        self.vehicleId = vehicleId

        _viewModel = State(
            initialValue: viewModel
        )
    }

    var body: some View {

        ZStack(alignment: .top) {

            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {

                // MARK: - Content

                if viewModel.isLoading {

                    ProgressView("Loading vehicle...")

                } else if let errorMessage = viewModel.errorMessage {

                    ContentUnavailableView(
                        "Unable to Load Vehicle",
                        systemImage: "exclamationmark.triangle",
                        description: Text(errorMessage)
                    )

                } else if let details = viewModel.vehicleDetails {

                    vehicleDetailsView(details)

                } else {

                    ContentUnavailableView(
                        "Vehicle Not Found",
                        systemImage: "bus"
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .top)
        }
        .navigationTitle("Vehicle Details")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadVehicleDetails(
                vehicleId: vehicleId
            )
        }
    }

    // MARK: - Vehicle Details

    @ViewBuilder
    private func vehicleDetailsView(
        _ details: VehicleDetailsDTO
    ) -> some View {

        ScrollView {

            VStack(spacing: 24) {

                // MARK: Vehicle Header

                VStack(spacing: 10) {

                    Image(
                        systemName: details.vehicle.type.systemImageName
                    )
                    .font(.system(size: 42))
                    .foregroundStyle(.tint)

                    Text(details.vehicle.plate)
                        .font(.system(size: 32, weight: .bold))

                    Text(details.vehicle.type.displayName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 24)

                // MARK: Vehicle Information

                detailSection(
                    title: "Vehicle",
                    systemImage: "bus"
                ) {

                    detailRow(
                        title: "Plate",
                        value: details.vehicle.plate
                    )

                    Divider()

                    detailRow(
                        title: "Type",
                        value: details.vehicle.type.displayName
                    )

                    Divider()

                    detailRow(
                        title: "Capacity",
                        value: "\(details.vehicle.capacity) passengers"
                    )

                    Divider()

                    detailRow(
                        title: "Status",
                        value: details.vehicle.status.displayName
                    )
                }

                // MARK: Company Information

                detailSection(
                    title: "Company",
                    systemImage: "building.2"
                ) {

                    detailRow(
                        title: "Name",
                        value: details.company.name
                    )

                    Divider()

                    detailRow(
                        title: "NIT",
                        value: details.company.nit
                    )

                    Divider()

                    detailRow(
                        title: "Status",
                        value: details.company.isActive
                            ? "Active"
                            : "Inactive"
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
    }

    // MARK: - Detail Section

    @ViewBuilder
    private func detailSection<Content: View>(
        title: String,
        systemImage: String,
        @ViewBuilder content: () -> Content
    ) -> some View {

        VStack(alignment: .leading, spacing: 10) {

            HStack(spacing: 8) {

                Image(systemName: systemImage)
                    .foregroundStyle(.tint)

                Text(title)
                    .font(.headline)
            }

            VStack(spacing: 0) {
                content()
            }
            .padding(.horizontal, 16)
            .background(
                Color(uiColor: .secondarySystemGroupedBackground)
            )
            .clipShape(
                RoundedRectangle(cornerRadius: 16)
            )
        }
    }

    // MARK: - Detail Row

    @ViewBuilder
    private func detailRow(
        title: String,
        value: String
    ) -> some View {

        HStack {

            Text(title)
                .foregroundStyle(.primary)

            Spacer()

            Text(value)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 14)
    }
}

// MARK: - Vehicle Type Presentation

private extension VehicleType {

    var systemImageName: String {

        switch self {

        case .bus, .buseta, .microbus:
            "bus"

        case .van:
            "car"

        case .taxi:
            "taxi"
        }
    }

    var displayName: String {

        switch self {

        case .bus:
            "Bus"

        case .buseta:
            "Buseta"

        case .microbus:
            "Microbus"

        case .van:
            "Van"

        case .taxi:
            "Taxi"
        }
    }
}

// MARK: - Vehicle Status Presentation

private extension VehicleStatus {

    var displayName: String {

        switch self {

        case .outsideTerminal:
            "Outside Terminal"

        case .insideTerminal:
            "Inside Terminal"

        case .dispatched:
            "Dispatched"

        case .maintenance:
            "Maintenance"
        }
    }
}

#Preview {

    let container = DependencyContainer()

    VehicleDetailView(
        vehicleId: UUID(),
        viewModel: container.makeVehicleDetailViewModel()
    )
}
