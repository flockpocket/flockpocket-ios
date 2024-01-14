//
//  DirectoryMemberView.swift
//  FlockPocket
//
//  Created by snow on 1/13/24.
//

import SwiftUI
import CoreData

struct DirectoryMemberView: View {
    @Binding var user: User
    
    var body: some View {
        VStack {
            ProfilePhoto(user: user, size: 150)
                .padding()
            List {
                Section("Name") {
                    Text(user.first_name!)
                    Text(user.last_name!)
                }
                Section("Phone Number") {
                    Text(user.phone!)
                }
                Section("Gender") {
                    Text(user.gender!)
                }
                Section("Address") {
                    Text(user.address!)
                }
                Section("Birthday") {
                    Text(user.birthdayString!)
//                    Text(Date(user.birthday!.formatted(date: .complete, time: .omitted)).description.utf8CString)
                }
            }
        }
    }
}
