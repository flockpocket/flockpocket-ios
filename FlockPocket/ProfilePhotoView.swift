//
//  ProfilePhotoView.swift
//  FlockPocket
//
//  Created by snow on 1/10/24.
//

import Foundation
import SwiftUI

struct ProfilePhoto: View {
    var user: User
    var size: CGFloat = 50
    
    var body: some View {
        AsyncImage(
            url: URL(string: "https://\(hostUrl)/static/profile_pics/\(user.pic ?? "")"),
            content: { image in
                image.resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: size, maxHeight: size)
            },
            placeholder: {
                Image("sheep")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: size, maxHeight: size)
                    .clipShape(.circle)
            }
        )
    }
}
