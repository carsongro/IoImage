//
//  IoImageView.swift
//  
//
//  Created by Carson Gross on 11/15/23.
//

import SwiftUI

struct IoImageView: View {
    @State private var image: Image?
    
    var url: URL?
    
    private var placeholder: AnyView?
    private var isResizable = false
    
    init(url: URL?) {
        self.url = url
    }
    
    var body: some View {
        Group {
            if let image {
                if isResizable {
                    image
                        .resizable()
                } else {
                    image
                }
            } else {
                placeholder
            }
        }
        .onAppear {
            if let url {
                loadImage(url: url)
            }
        }
        .onChange(of: url) { _, _ in
            if let url {
                loadImage(url: url)
            } else {
                image = nil
            }
        }
    }
    
    @MainActor
    private func loadImage(url: URL) {
        Task {
            do {
                image = try await IoImageLoader.shared.Image(from: url)
            } catch {
                
            }
        }
    }
    
    func placeholder<T: View>(
        @ViewBuilder _ content: () -> T
    ) -> IoImageView where T : View {
        var imageView = self
        imageView.placeholder = AnyView(content())
        return imageView
    }
    
    func resizable() -> IoImageView {
        var imageView = self
        imageView.isResizable = true
        return imageView
    }
}
