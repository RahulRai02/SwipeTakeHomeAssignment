//
//  NetworkMonitor.swift
//  SwipePro
//
//  Created by Rahul Rai on 25/11/24.
//

import Foundation
import Network


final class NetworkMonitor : ObservableObject{
    static let shared = NetworkMonitor()

    private let queue = DispatchQueue(label: "NetworkConnectivityMonitor")
    private let monitor: NWPathMonitor

    private(set) var isConnected = false

    private init() {
        monitor = NWPathMonitor()
    }

    func startMonitoring() {
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = { path in
            self.isConnected = path.status == .satisfied
//            self.isConnected = path.status == .satisfied
            print(path.status)
        }
    }

    func stopMonitoring() {
        monitor.cancel()
    }
}
