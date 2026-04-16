//
//  ConnectivityService.swift
//  MusicPlayer
//
//  Created by Gabriel Maciel on 16/04/26.
//

import Foundation
import Network
import Observation

protocol ConnectivityMonitoring: AnyObject {
    var isConnected: Bool { get }
}

@Observable
@MainActor
final class ConnectivityService: ConnectivityMonitoring {
    private let monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "ConnectivityService")

    private(set) var isConnected = true

    init(monitor: NWPathMonitor = NWPathMonitor()) {
        self.monitor = monitor
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}
