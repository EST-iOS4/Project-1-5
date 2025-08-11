//
//  TabItemView.swift
//  EgenBoys
//
//  Created by 이건준 on 8/11/25.
//

import SwiftUI

struct TabItemView: View {
    var imageName: String
    var text: String

    var body: some View {
        VStack {
            Image(systemName: imageName)
            Text(text)
        }
    }
}
