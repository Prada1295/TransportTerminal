//
//  DispatchesView.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 15/09/26.
//
import SwiftUI

struct DispatchesView: View {

    @State private var viewModel: DispatchesViewModel

    init(viewModel: DispatchesViewModel) {
        _viewModel = State(
            initialValue: viewModel
        )
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
                        // Create Dispatch will be connected later.
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
                        Text("Dispatch Detail")
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

    let dispatch: Dispatch

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
                "\(dispatch.routeId.uuidString.prefix(8))"
            )
            .font(.subheadline)

            HStack(spacing: 16) {

                Label(
                    String(dispatch.vehicleId.uuidString.prefix(8)),
                    systemImage: "bus"
                )

                Label(
                    String(dispatch.bayId.uuidString.prefix(8)),
                    systemImage: "rectangle.split.3x1"
                )
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 6)
    }

    private var statusBadge: some View {
        Text(dispatch.status.rawValue.capitalized)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Color.secondary.opacity(0.12),
                in: Capsule()
            )
    }
}


// MARK: - Preview

#Preview {
    DispatchesView(
        viewModel: DispatchesViewModel(
            getActiveDispatchesUseCase:
                PreviewGetActiveDispatchesUseCase(),
            cancelDispatchUseCase:
                PreviewCancelDispatchUseCase(),
            executeDispatchUseCase:
                PreviewExecuteDispatchUseCase()
        )
    )
}


// MARK: - Preview Fakes

private struct PreviewGetActiveDispatchesUseCase:
    GetActiveDispatchesUseCase {

    func execute() async throws -> [Dispatch] {
        []
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
