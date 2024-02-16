//
//  ProfileView.swift
//  FlockPocket
//
//  Created by snow on 1/8/24.
//

import SwiftUI
import CoreData

struct ProfileView: View {
    @State var user: User
    @State private var newEmail = ""
    @State private var newFirstName = ""
    @State private var newLastName = ""
    @State private var newPhone = ""
    @State private var newGender = ""
    @State private var newBirthday: Date
    @State private var newMembershipStatus = ""
    
    // TODO: make this a proper set of address fields. Maybe need to change how API returns addresses
    @State private var newAddress = ""
    
    init() {
        let viewContext = PersistenceController.shared!.container.viewContext
        let ownId = UserDefaults.standard.string(forKey: "ownUserId") ?? ""
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id LIKE %@",  ownId)
        let user = try! viewContext.fetch(fetchRequest).first ?? User(context: viewContext)
        _user =         State(initialValue: user)
        _newBirthday =  State(initialValue: user.birthday!)
        _newGender = State(initialValue: user.gender!)
        
    }
    
    var body: some View {
        VStack {
            ProfilePhoto(user: user)
                .padding()
            List {
                Section("Name") {
                    TextField(user.first_name!, text: $newFirstName)
                    TextField(user.last_name!, text: $newLastName)
                }
                Section("Phone Number") {
                    TextField(user.phone!, text: $newPhone)
                }
                Section("Gender") {
                    Picker(selection: $newGender,
                           label: Text("Gender")) {
                        Text("Not selected").tag("Not selected")
                        Text("Male").tag("Male")
                        Text("Female").tag("Female")
                    }
                }
                Section("Address") {
                    TextField(user.address!, text: $newAddress)
                }
                Section("Birthday") {
                    DatePicker("Birthday", selection: $newBirthday ,displayedComponents: .date)
                }
            }
        }
    }
}
