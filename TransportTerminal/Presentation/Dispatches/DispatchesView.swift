//
//  DispatchesView.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 15/09/26.
//
import SwiftUI

struct DispatchesView: View {

    @State private var viewModel: DispatchesViewModel
    @State private var showingCreateDispatch = false

    private let createDispatchViewModelFactory: () -> CreateDispatchViewModel
    private let dispatchDetailViewModelFactory:
        (DispatchDetailsResult) -> DispatchDetailViewModel

    init(
        viewModel: DispatchesViewModel,
        createDispatchViewModelFactory:
            @escaping () -> CreateDispatchViewModel,
        dispatchDetailViewModelFactory:
            @escaping (DispatchDetailsResult) -> DispatchDetailViewModel
    ) {
        _viewModel = State(
            initialValue: viewModel
        )
        self.createDispatchViewModelFactory =
            createDispatchViewModelFactory
        self.dispatchDetailViewModelFactory =
            dispatchDetailViewModelFactory
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading dispatches...")
                } else if let errorMessage = viewModel.errorMessage {
                    errorView(message: errorMessage)
                } else if viewModel.dispatches.isEmpty {
                    emptyStateView
                } else {
                    dispatchesList
                }
            }
            .navigationTitle("Dispatches")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingCreateDispatch = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Create dispatch")
                }
            }
            .task {
                await viewModel.loadDispatches()
            }
            .refreshable {
                await viewModel.loadDispatches()
            }
            .sheet(
                isPresented: $showingCreateDispatch,
                onDismiss: {
                    Task {
                        await viewModel.loadDispatches()
                    }
                }
            ) {
                CreateDispatchView(
                    viewModel: createDispatchViewModelFactory()
                )
            }
        }
    }
}


// MARK: - Dispatches List

private extension DispatchesView {

    var dispatchesList: some View {
        List {
            Section("Today's Operations") {
                ForEach(viewModel.dispatches) { dispatch in
                    NavigationLink {
                        DispatchDetailView(
                            viewModel:
                                dispatchDetailViewModelFactory(dispatch)
                        ) {
                            Task {
                                await viewModel.loadDispatches()
                            }
                        }
                    } label: {
                        DispatchRow(dispatch: dispatch)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}


// MARK: - Empty State

private extension DispatchesView {

    var emptyStateView: some View {
        ContentUnavailableView(
            "No Active Dispatches",
            systemImage: "bus",
            description: Text(
                "There are no active dispatches at the moment."
            )
        )
    }
}


// MARK: - Error State

private extension DispatchesView {

    func errorView(message: String) -> some View {
        ContentUnavailableView(
            "Unable to Load Dispatches",
            systemImage: "exclamationmark.triangle",
            description: Text(message)
        )
    }
}


// MARK: - Dispatch Row

private struct DispatchRow: View {

    let dispatch: DispatchDetailsResult

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            HStack {
                Text(dispatch.scheduledDeparture, style: .time)
                    .font(.headline)

                Spacer()

                statusBadge
            }

            Text("Route")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(
                "\(dispatch.routeOrigin) to \(dispatch.routeDestination)"
            )
            .font(.subheadline)

            HStack(spacing: 16) {

                Label(
                    dispatch.vehiclePlate,
                    systemImage: "bus"
                )

                Label(
                    dispatch.bayCode,
                    systemImage: "rectangle.split.3x1"
                )
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 6)
    }

    private var statusBadge: some View {
        Text(dispatch.status.displayName)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                dispatch.status.tint.opacity(0.15),
                in: Capsule()
            )
            .foregroundStyle(dispatch.status.tint)
    }
}


// MARK: - Presentation Helpers

private extension DispatchStatus {

    var displayName: String {
        switch self {
        case .scheduled:
            return "Scheduled"

        case .boarding:
            return "Boarding"

        case .departed:
            return "Departed"

        case .cancelled:
            return "Cancelled"

        case .delayed:
            return "Delayed"
        }
    }

    var tint: Color {
        switch self {
        case .scheduled:
            return .blue

        case .boarding:
            return .orange

        case .departed:
            return .green

        case .cancelled:
            return .red

        case .delayed:
            return .yellow
        }
    }
}


// MARK: - Preview

#Preview {
    DispatchesView(
        viewModel: DispatchesViewModel(
            getActiveDispatchDetailsUseCase:
                PreviewGetActiveDispatchDetailsUseCase(),
            cancelDispatchUseCase:
                PreviewCancelDispatchUseCase(),
            executeDispatchUseCase:
                PreviewExecuteDispatchUseCase()
        ),
        createDispatchViewModelFactory: {
            CreateDispatchViewModel(
                getVehiclesInsideTerminalUseCase:
                    PreviewCreateDispatchVehiclesUseCase(),
                getActiveRoutesUseCase:
                    PreviewCreateDispatchRoutesUseCase(),
                getAvailableBaysUseCase:
                    PreviewCreateDispatchBaysUseCase(),
                createDispatchUseCase:
                    PreviewCreateDispatchUseCase()
            )
        },
        dispatchDetailViewModelFactory: { dispatch in
            DispatchDetailViewModel(
                dispatch: dispatch,
                cancelDispatchUseCase:
                    PreviewCancelDispatchUseCase(),
                executeDispatchUseCase:
                    PreviewExecuteDispatchUseCase()
            )
        }
    )
}


// MARK: - Preview Fakes

private struct PreviewGetActiveDispatchDetailsUseCase:
    GetActiveDispatchDetailsUseCase {

    func execute() async throws -> [DispatchDetailsResult] {
        [
            DispatchDetailsResult(
                id: UUID(),
                vehicleId: UUID(),
                vehiclePlate: "ABC123",
                vehicleType: .bus,
                routeId: UUID(),
                routeOrigin: "Medellin",
                routeDestination: "Bogota",
                bayId: UUID(),
                bayCode: "B01",
                scheduledDeparture: Date(),
                actualDeparture: nil,
                status: .scheduled
            )
        ]
    }
}

private struct PreviewCancelDispatchUseCase:
    CancelDispatchUseCase {

    func execute(
        dispatchId: UUID
    ) async throws -> CancelDispatchResult {

        fatalError("Preview only")
    }
}

private struct PreviewExecuteDispatchUseCase:
    ExecuteDispatchUseCase {

    func execute(
        dispatchId: UUID
    ) async throws -> ExecuteDispatchResult {

        fatalError("Preview only")
    }
}

private struct PreviewCreateDispatchVehiclesUseCase:
    GetVehiclesInsideTerminalUseCase {

    func execute() async throws -> [Vehicle] {
        []
    }
}

private struct PreviewCreateDispatchRoutesUseCase:
    GetActiveRoutesUseCase {

    func execute() async throws -> [Route] {
        []
    }
}

private struct PreviewCreateDispatchBaysUseCase:
    GetAvailableBaysUseCase {

    func execute() async throws -> [Bay] {
        []
    }
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
