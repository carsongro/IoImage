//
//  IoImageView.swift
//
//
//  Created by Carson Gross on 11/15/23.
//
//  Copyright (c) 2023 Carson Gross
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import SwiftUI

public struct IoImageView: View {
    @State private var image: Image?
    
    private var url: URL?
    private var placeholder: AnyView?
    private var isResizable = false
    
    public init(url: URL?) {
        self.url = url
    }
    
    public var body: some View {
        Group {
            if let image {
                if isResizable {
                    image
                        .resizable()
                } else {
                    image
                }
            } else {
                if let placeholder {
                    placeholder
                } else {
                    /// This is necessary because .task isn't called unless there is something in the group
                    Color.clear
                }
            }
        }
        .task(id: url) {
            if let url {
                do {
                    image = try await IoImageLoader.shared.Image(from: url)
                } catch {
                    
                }
            } else {
                image = nil
            }
        }
    }
    
    public func placeholder<T: View>(
        @ViewBuilder _ content: () -> T
    ) -> IoImageView where T : View {
        var imageView = self
        imageView.placeholder = AnyView(content())
        return imageView
    }
    
    public func resizable() -> IoImageView {
        var imageView = self
        imageView.isResizable = true
        return imageView
    }
}

#Preview {
    IoImageView(url: URL(string: "https://github.com/carsongro/IoImage/blob/main/Tests/IoImageTests/clouds.jpeg?raw=true"))
        .resizable()
        .frame(width: 200, height: 200)
}
