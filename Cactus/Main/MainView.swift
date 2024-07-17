//
//  ContentView.swift
//  Cactus
//
//  Created by Brian Masse on 6/18/24.
//

import SwiftUI
import CactusComponents
import RealmSwift

final class FormattedCactusComponent: Object, Identifiable {
    
    enum Publicity: String {
        case publicComponent
        case privateComponent
    }
    
    @Persisted(primaryKey: true) var _id: ObjectId
    
    
    @Persisted var name: String         = ""
    @Persisted var summary: String      = ""
    @Persisted var publicity: String    = Publicity.publicComponent.rawValue
    
    @Persisted var authorId: String     = ""
    @Persisted var author: String       = ""
    
    @Persisted var className: String    = ""
    
    convenience init( name: String, summary: String, authorId: String, author: String, className: String ) {
        self.init()
        
        self.name = name
        self.summary = summary
        
        self.authorId = authorId
        self.author = author
        
        self.className = className
    }
}

struct FormattedCactusComponentCreationView: View {
    
    @State private var name: String = ""
    @State private var summary: String = ""
    @State private var author: String = ""
    @State private var className: String = ""
    
    private func submit() {
        if name.isEmpty ||
            summary.isEmpty ||
            author.isEmpty ||
            className.isEmpty {
            return
        }
        
        let component = FormattedCactusComponent(name: name,
                                                 summary: summary,
                                                 authorId: CactusModel.ownerID,
                                                 author: author,
                                                 className: className)
        
        RealmManager.addObject(component)
    }

    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text( "Create Component" )
                    .font(.title)
                    .bold()
                
                Spacer()
            }
            
            TextField(text: $name, prompt: Text("name")) { }
                .padding()
            
            TextField(text: $summary, prompt: Text("summary")) { }
                .padding()
            
            TextField(text: $author, prompt: Text("author")) { }
                .padding()
            
            
            
            
//            TextField(text: $className, prompt: Text("className")) { }
//                .padding()
//
//            Button(action: { submit() }, label: {
//                Text("submit")
//            })
            
            Spacer()
        }
    }
}

struct MainView: View {
    
    @State private var showingCreationView: Bool = false
    
    @ObservedResults( FormattedCactusComponent.self ) var cactusComponents
    
    @State private var testCode: String = "click to load code"
    
    var body: some View {
        
        VStack {
            HStack {
                Image(systemName: "pencil")
                
                Spacer()
                
                Text("the MOMA project")
                    .font(.title2)
                    .bold()
                    .onTapGesture {
                        let test: [FormattedCactusComponent] = RealmManager.retrieveObjects()
                        print(test)
                        print(cactusComponents)
                    }
                
                Spacer()
                
                Image(systemName: "plus")
                    .onTapGesture { showingCreationView = true }
                
            }
            
            Text( testCode )
                .onTapGesture {
                    
                    print( "running" )
                    
//                    do {
                        
                        if let url = Bundle.main.url(forResource: "test.swift", withExtension: nil) {
                            print(url)
                        }
                    
                    for t in Bundle.main.paths(forResourcesOfType: "py", inDirectory: "") {
                        print(t)
                    }
                    
                        if let bundlePath = Bundle.main.path(forResource: "test", ofType: "txt") {
                                
                            print( bundlePath )
                            
                            let string = try! String(contentsOfFile: bundlePath)
                            self.testCode = string
                        }
                        
//                        
//                    } catch {
//                        print( error.localizedDescription )
//                    }
                    
                    
                }
            
            Spacer()
            
//            ScrollView(.horizontal) {
//                
//                ForEach( cactusComponents ) { component in
//                    if let loadingBlurComponent = NSClassFromString( "CactusComponents.\(component.className)" ) as? CactusComponent.Type {
//                        loadingBlurComponent.shared.preview(false)
//                    } else {
//                        Image(systemName: "exclamationmark.triangle.fill")
//                    }
//                }
//            }
            
            
            //        LoadingBlurComponent.shared.preview(false)
        }
        .sheet(isPresented: $showingCreationView) {
            FormattedCactusComponentCreationView()
        }
    }
}



struct ProfileCreationView: View {
    var body: some View {
        Text("Bypassing Profile Creation Scene")
            .task {
                await CactusModel.shared.realmManager.checkProfile()
            }
    }
}


#Preview {
    MainView()
        .padding()
}
