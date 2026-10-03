//
//  DispatchDetailView.swift
//  TransportTerminal
//
//  Created by Codex on 3/10/26.
//

import SwiftUI

struct DispatchDetailView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: DispatchDetailViewModel

    private let onDidChange: () -> Void

    init(
        viewModel: DispatchDetailViewModel,
        onDidChange: @escaping () -> Void = {}
    ) {
        _viewModel = State(
            initialValue: viewModel
        )
        self.onDidChange = onDidChange
    }

    var body: some View {
        List {
            if let errorMessage = viewModel.errorMessage {
                errorSection(message: errorMessage)
            }

            statusSection
            routeSection
            vehicleSection
            baySection
            scheduleSection
            actionsSection
        }
        .navigationTitle("Dispatch Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Sections

private extension DispatchDetailView {

    var statusSection: some View {
        Section {
            HStack {
                Label(
                    viewModel.dispatch.status.displayName,
                    systemImage: viewModel.dispatch.status.systemImageName
                )
                .font(.headline)

                Spacer()

                Text(viewModel.dispatch.status.displayName)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        viewModel.dispatch.status.tint.opacity(0.15),
                        in: Capsule()
                    )
                    .foregroundStyle(viewModel.dispatch.status.tint)
            }
        }
    }

    var routeSection: some View {
        Section("Route") {
            LabeledContent(
                "Origin",
                value: viewModel.dispatch.routeOrigin
            )

            LabeledContent(
                "Destination",
                value: viewModel.dispatch.routeDestination
            )
        }
    }

    var vehicleSection: some View {
        Section("Vehicle") {
            LabeledContent(
                "Plate",
                value: viewModel.dispatch.vehiclePlate
            )

            LabeledContent(
                "Type",
                value: viewModel.dispatch.vehicleType.displayName
            )
        }
    }

    var baySection: some View {
        Section("Bay") {
            LabeledContent(
                "Assigned Bay",
                value: viewModel.dispatch.bayCode
            )
        }
    }

    var scheduleSection: some View {
        Section("Schedule") {
            LabeledContent("Scheduled") {
                Text(
                    viewModel.dispatch.scheduledDeparture,
                    format: .dateTime.day().month().year().hour().minute()
                )
            }

            if let actualDeparture = viewModel.dispatch.actualDeparture {
                LabeledContent("Actual Departure") {
                    Text(
                        actualDeparture,
                        format: .dateTime.day().month().year().hour().minute()
                    )
                }
            }
        }
    }

    var actionsSection: some View {
        Section {
            Button {
                Task {
                    if await viewModel.executeDispatch() != nil {
                        onDidChange()
                        dismiss()
                    }
                }
            } label: {
                actionLabel(
                    title: "Execute Dispatch",
                    systemImage: "arrow.up.circle",
                    isLoading: viewModel.isExecuting
                )
            }
            .disabled(!viewModel.canExecute)

            Button(role: .destructive) {
                Task {
                    if await viewModel.cancelDispatch() != nil {
                        onDidChange()
                        dismiss()
                    }
                }
            } label: {
                actionLabel(
                    title: "Cancel Dispatch",
                    systemImage: "xmark.circle",
                    isLoading: viewModel.isCancelling
                )
            }
            .disabled(!viewModel.canCancel)
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

    func actionLabel(
        title: String,
        systemImage: String,
        isLoading: Bool
    ) -> some View {
        HStack {
            Spacer()

            if isLoading {
                ProgressView()
                    .controlSize(.small)
            } else {
                Label(title, systemImage: systemImage)
                    .fontWeight(.semibold)
            }

            Spacer()
        }
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

    var systemImageName: String {
        switch self {
        case .scheduled:
            return "clock"

        case .boarding:
            return "person.2"

        case .departed:
            return "arrow.up.circle"

        case .cancelled:
            return "xmark.circle"

        case .delayed:
            return "exclamationmark.triangle"
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

private extension VehicleType {

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

#Preview {
    NavigationStack {
        DispatchDetailView(
            viewModel: DispatchDetailViewModel(
                dispatch: DispatchDetailsResult(
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
                ),
                cancelDispatchUseCase: PreviewDispatchDetailCancelUseCase(),
                executeDispatchUseCase: PreviewDispatchDetailExecuteUseCase()
            )
        )
    }
}

private struct PreviewDispatchDetailCancelUseCase: CancelDispatchUseCase {

    func execute(dispatchId: UUID) async throws -> CancelDispatchResult {
        CancelDispatchResult(
            dispatchId: dispatchId,
            vehicleId: UUID(),
            routeId: UUID(),
            bayId: UUID(),
            status: .cancelled
        )
    }
}

private struct PreviewDispatchDetailExecuteUseCase: ExecuteDispatchUseCase {

    func execute(dispatchId: UUID) async throws -> ExecuteDispatchResult {
        ExecuteDispatchResult(
            dispatchId: dispatchId,
            vehicleId: UUID(),
            routeId: UUID(),
            bayId: UUID(),
            scheduledDeparture: Date(),
            actualDeparture: Date(),
            status: .departed
        )
    }
}
