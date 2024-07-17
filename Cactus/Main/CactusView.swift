//
//  CactusView.swift
//  Cactus
//
//  Created by Brian Masse on 6/20/24.
//

import Foundation
import SwiftUI
import RealmSwift

struct CactusView: View {
    
    @ObservedObject var realmManager = CactusModel.shared.realmManager
    
    var body: some View {
        switch realmManager.authenticationState {
        case .authenticating:
            AuthenticationView()
                .padding()
            
        case .openingRealm:
            if realmManager.networkAvailable {
                OpenFlexibleSyncRealmView()
                    .environment(\.realmConfiguration, realmManager.configuration)
                    .padding()
            } else {
                
                Text("offline")
                    .task {
                        print("loading Offline Realm")
                        await realmManager.authOfflineRealm()
                    }
                
            }
            
        case .creatingProfile:
            ProfileCreationView()
            
        case .error:
            Text("An error occoured")
                
            
        case .complete:
            MainView()
                .environment(\.realmConfiguration, realmManager.configuration)
                .padding()
        }
    }
}
