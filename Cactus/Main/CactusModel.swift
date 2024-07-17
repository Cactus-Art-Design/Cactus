//
//  CactusModel.swift
//  Cactus
//
//  Created by Brian Masse on 6/20/24.
//

import Foundation
import Network

struct CactusModel {
    
//    MARK: Vars
    static var shared: CactusModel = CactusModel()
    
    static var ownerID: String { CactusModel.shared.realmManager.user?.id ?? "" }
    
    var realmManager: RealmManager = RealmManager()

    private let networkMonitor = NWPathMonitor()
    
//    MARK: Init
    init() {
        setupNetworkMonitor()
    }
    

    private func setupNetworkMonitor() {
        
        let queue = DispatchQueue(label: "CactusModelNetworkMonitor")
        networkMonitor.start(queue: queue)
        
        networkMonitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                Task { await CactusModel.shared.realmManager.setNetworkAvailability(to: true) }
                
            } else {
                Task { await CactusModel.shared.realmManager.setNetworkAvailability(to: false) }
            }
        }
    }
}
