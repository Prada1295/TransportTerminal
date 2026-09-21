//
//  DashboardView.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 31/08/26.
//
import SwiftUI

struct DashboardView: View {
    
    private let container: DependencyContainer
    
    @State private var viewModel: DashboardViewModel
    @State private var showingVehicleEntry = false
    @State private var showingVehicleExit = false
    @State private var showingDispatches = false
    
    init(container: DependencyContainer) {
        self.container = container
        
        _viewModel = State(
            initialValue: container.makeDashboardViewModel()
        )
    }
    
    var body: some View {
        
        NavigationStack {
            
            ScrollView {
                
                VStack(alignment: .leading, spacing: 24) {
                    
                    // MARK: - Header
                    
                    VStack(alignment: .leading, spacing: 4) {
                        
                        Text("Operations Dashboard")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Terminal Norte")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    // MARK: - Operational Overview
                    
                    VStack(alignment: .leading, spacing: 12) {
                        
                        Text("Operational Overview")
                            .font(.headline)
                        
                        ScrollView(
                            .horizontal,
                            showsIndicators: false
                        ) {
                            
                            LazyHStack(spacing: 12) {
                                
                                DashboardMetricCard(
                                    title: "Vehicles",
                                    value: "\(viewModel.vehiclesInsideTerminal.count)",
                                    subtitle: "Inside terminal",
                                    systemImage: "bus"
                                )
                                
                                DashboardMetricCard(
                                    title: "Inside",
                                    value: "\(viewModel.vehiclesInsideTerminal.count)",
                                    subtitle: "Vehicles",
                                    systemImage: "arrow.down.circle"
                                )
                                
                                DashboardMetricCard(
                                    title: "Outside",
                                    value: "\(viewModel.vehiclesAvailableForEntry.count)",
                                    subtitle: "Available for entry",
                                    systemImage: "arrow.up.circle"
                                )
                                
                                DashboardMetricCard(
                                    title: "Dispatches",
                                    value: "\(viewModel.activeDispatches.count)",
                                    subtitle: "Active",
                                    systemImage: "clock.arrow.circlepath"
                                )
                                
                                DashboardMetricCard(
                                    title: "Bays",
                                    value: "\(viewModel.occupiedBayCount)",
                                    subtitle: "Occupied",
                                    systemImage: "rectangle.split.3x1"
                                )
                                
                                DashboardMetricCard(
                                    title: "Movements",
                                    value: "—",
                                    subtitle: "Today",
                                    systemImage: "arrow.left.arrow.right"
                                )
                                
                                DashboardMetricCard(
                                    title: "Maintenance",
                                    value: "—",
                                    subtitle: "Vehicles",
                                    systemImage: "wrench.and.screwdriver"
                                )
                                
                                DashboardMetricCard(
                                    title: "Alerts",
                                    value: "—",
                                    subtitle: "Requires attention",
                                    systemImage: "exclamationmark.triangle"
                                )
                            }
                            .padding(.horizontal, 1)
                        }
                    }
                    
                    // MARK: - Vehicles Inside Terminal
                    
                    VStack(alignment: .leading, spacing: 12) {
                        
                        HStack {
                            
                            Text("Vehicles Inside Terminal")
                                .font(.headline)
                            
                            Spacer()
                            
                            Button("See All") {
                                // Navigation will be connected later.
                            }
                            .font(.subheadline)
                        }
                        
                        if viewModel.isLoading {
                            
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 30)
                            
                        } else if let errorMessage = viewModel.errorMessage {
                            
                            ContentUnavailableView(
                                "Could not load vehicles",
                                systemImage: "exclamationmark.triangle",
                                description: Text(errorMessage)
                            )
                            
                        } else if viewModel.vehiclesInsideTerminal.isEmpty {
                            
                            ContentUnavailableView(
                                "No vehicles inside",
                                systemImage: "bus",
                                description: Text(
                                    "Registered entries will appear here."
                                )
                            )
                            
                        } else {
                            
                            VStack(spacing: 0) {
                                
                                ForEach(
                                    viewModel.vehiclesInsideTerminal
                                ) { vehicle in
                                    
                                    NavigationLink {
                                        VehicleDetailView(
                                            vehicleId: vehicle.id,
                                            viewModel: container.makeVehicleDetailViewModel()
                                        )
                                    } label: {
                                        DashboardVehicleRow(
                                            vehicle: vehicle
                                        )
                                    }
                                    
                                    if vehicle.id !=
                                        viewModel.vehiclesInsideTerminal.last?.id {
                                        
                                        Divider()
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .background(
                                Color(
                                    uiColor:
                                            .secondarySystemGroupedBackground
                                )
                            )
                            .clipShape(
                                RoundedRectangle(
                                    cornerRadius: 16
                                )
                            )
                        }
                    }
                    
                    // MARK: - Active Dispatches

                    VStack(alignment: .leading, spacing: 12) {

                        HStack {
                            Text("Active Dispatches")
                                .font(.headline)

                            Spacer()

                            Button("See All") {
                                // Navigation will be connected later.
                            }
                            .font(.subheadline)
                        }

                        if viewModel.activeDispatches.isEmpty {

                            ContentUnavailableView(
                                "No active dispatches",
                                systemImage: "clock.arrow.circlepath",
                                description: Text(
                                    "Scheduled dispatches will appear here."
                                )
                            )

                        } else {

                            VStack(spacing: 0) {

                                ForEach(viewModel.activeDispatches) { dispatch in

                                    DashboardDispatchRow(
                                        dispatch: dispatch
                                    )

                                    if dispatch.id !=
                                        viewModel.activeDispatches.last?.id {

                                        Divider()
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .background(
                                Color(
                                    uiColor:
                                        .secondarySystemGroupedBackground
                                )
                            )
                            .clipShape(
                                RoundedRectangle(
                                    cornerRadius: 16
                                )
                            )
                        }
                    }
                    
                    // MARK: - Quick Actions
                    
                    VStack(alignment: .leading, spacing: 12) {
                        
                        Text("Quick Actions")
                            .font(.headline)
                        
                        LazyVGrid(
                            columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ],
                            spacing: 12
                        ) {
                            
                            DashboardActionButton(
                                title: "Vehicle Entry",
                                systemImage: "arrow.down.circle"
                            ) {
                                showingVehicleEntry = true
                            }
                            
                            DashboardActionButton(
                                title: "Vehicle Exit",
                                systemImage: "arrow.up.circle"
                            ) {
                                showingVehicleExit = true
                            }
                            
                            DashboardActionButton(
                                title: "Dispatches",
                                systemImage: "clock.arrow.circlepath"
                            ) {
                                showingDispatches = true
                            }
                            
                            DashboardActionButton(
                                title: "Bays",
                                systemImage: "rectangle.split.3x1"
                            ) {
                                //Coming next
                            }
                        }
                    }
                }
                .padding(20)
            }
            .navigationTitle("Transport Terminal")
            .navigationBarTitleDisplayMode(.inline)
            .background(
                Color(uiColor: .systemGroupedBackground)
            )
            .task {
                await viewModel.loadDashboard()
            }
            .refreshable {
                await viewModel.loadDashboard()
            }
            .sheet(isPresented: $showingVehicleEntry) {
                RegisterVehicleEntryView(
                    vehicles: viewModel.vehiclesAvailableForEntry,
                    viewModel: container.makeRegisterVehicleEntryViewModel()
                )
            }
            .sheet(isPresented: $showingVehicleExit) {
                RegisterVehicleExitView(viewModel: container.makeRegisterVehicleExitViewModel()
                )
            }
            
            .sheet(isPresented: $showingDispatches) {
                DispatchesView(
                    viewModel: container.makeDispatchesViewModel()
                )
            }
        }
    }
}

// MARK: - Metric Card

private struct DashboardMetricCard: View {
    
    let title: String
    let value: String
    let subtitle: String
    let systemImage: String
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 12) {
            
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(.tint)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 2) {
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            Color(uiColor: .secondarySystemGroupedBackground)
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 16)
        )
    }
}

// MARK: - Vehicle Row

private struct DashboardVehicleRow: View {
    
    let vehicle: Vehicle
    
    var body: some View {
        
        HStack(spacing: 12) {
            
            Image(systemName: vehicle.type.systemImageName)
                .frame(width: 28)
                .foregroundStyle(.tint)
            
            VStack(alignment: .leading, spacing: 4) {
                
                Text(vehicle.plate)
                    .font(.headline)
                
                Text(
                    "\(vehicle.type.displayName) • Capacity: \(vehicle.capacity)"
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text(vehicle.status.displayName)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(
                    .green.opacity(0.15),
                    in: Capsule()
                )
                .foregroundStyle(.green)
        }
        .padding(.vertical, 14)
    }
}

// MARK: - Dispatch Row

private struct DashboardDispatchRow: View {

    let dispatch: Dispatch

    private var departureTime: String {
        dispatch.scheduledDeparture.formatted(
            date: .omitted,
            time: .shortened
        )
    }

    var body: some View {

        HStack(spacing: 12) {

            Image(systemName: "arrow.up.circle")
                .font(.title3)
                .foregroundStyle(.tint)

            VStack(alignment: .leading, spacing: 4) {

                Text("Dispatch")
                    .font(.headline)

                Text(
                    "Vehicle \(shortID(dispatch.vehicleId))"
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)

                Text(
                    "Bay \(shortID(dispatch.bayId))"
                )
                .font(.caption)
                .foregroundStyle(.secondary)

                Text(
                    "Departure \(departureTime)"
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            Text(dispatch.status.rawValue.capitalized)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(
                    .blue.opacity(0.15),
                    in: Capsule()
                )
        }
        .padding(.vertical, 14)
    }

    private func shortID(_ id: UUID) -> String {
        String(id.uuidString.prefix(8))
    }
}


// MARK: - Action Button

private struct DashboardActionButton: View {
    
    let title: String
    let systemImage: String
    let action: () -> Void
    
    var body: some View {
        
        Button {
            action()
        } label: {
            
            VStack(spacing: 8) {
                
                Image(systemName: systemImage)
                    .font(.title3)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(
                Color(uiColor: .secondarySystemGroupedBackground)
            )
            .clipShape(
                RoundedRectangle(cornerRadius: 16)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Vehicle Type

private extension VehicleType {
    
    var systemImageName: String {
        
        switch self {
            
        case .bus, .buseta, .microbus:
            return "bus"
            
        case .van:
            return "car"
            
        case .taxi:
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
            return "Outside"
            
        case .insideTerminal:
            return "Inside"
            
        case .dispatched:
            return "Dispatched"
            
        case .maintenance:
            return "Maintenance"
        }
    }
}

// MARK: - Preview

#Preview {
    
    DashboardView(
        container: DependencyContainer()
    )
}
