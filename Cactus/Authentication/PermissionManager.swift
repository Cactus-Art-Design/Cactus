//
//  PermissionManager.swift
//  Recall
//
//  Created by Brian Masse on 7/14/23.
//

import Foundation
import RealmSwift

//these are the names used for each of the different queries throuhgout the app
//they are used when adding / removing queries
enum QuerySubKey: String, CaseIterable {
    case formattedCactusComponent
}

//MARK: QueryPermission
class QueryPermission<T: Object> {
    
    struct WrappedQuery<O: Object> {
        let name: String
        let query: ((Query<O>) -> Query<Bool>)
        
        init(name: String? = nil, query: @escaping ((Query<O>) -> Query<Bool>)) {
            self.query = query
            if name == nil  { self.name = UUID().uuidString }
            else            { self.name = name! }
            
        }
    }
    
    var baseQuery: (Query<T>) -> Query<Bool>
    private var additionalQueries: [ WrappedQuery<T> ] = []
    
    init( baseQuery: @escaping (Query<T>) -> Query<Bool> ) {
        self.baseQuery = baseQuery
    }

    func addQueries(_ name: String? = nil, _ queries: [ ((Query<T>) -> Query<Bool>) ] ) async {
        for index in queries.indices {
            await self.addQuery(name, queries[index])
        }
    }
    
    func addQuery(_ name: String? = nil, _ query: @escaping ((Query<T>) -> Query<Bool>) ) async {
        let wrappedQuery = WrappedQuery(name: name, query: query)
        let _ = await CactusModel.shared.realmManager.addGenericSubcriptions(name: wrappedQuery.name, query: query)
        additionalQueries.append(wrappedQuery)
    }
    
//    These aren't super useful, since I'm not able to remove queries / subscriptions when a view unloads it seem
//    as of now, all the subscriptions are reset when the app is closed, and when the app is opened
    func removeQueries(baseName: String) async {
        for wrappedQuery in additionalQueries {
            if wrappedQuery.name.contains( baseName ) {
                await removeQuery(wrappedQuery.name)
            }
        }
    }

    func removeQuery(_ name: String) async {
        await CactusModel.shared.realmManager.removeSubscription(name: name)
        if let index = additionalQueries.firstIndex(where: { wrappedQuery in
            wrappedQuery.name == name
        }) {
            additionalQueries.remove(at: index)
        }
    }
    
    func removeAllNonBaseQueries() async {
        for wrappedQuery in additionalQueries {
            await removeQuery( wrappedQuery.name )
        }
        
    }
}
