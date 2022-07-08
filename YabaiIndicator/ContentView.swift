//
//  ContentView.swift
//  YabaiIndicator
//
//  Created by Max Zhao on 26/12/2021.
//

import SwiftUI

struct SpaceButton : View {
    var space: Space
    
    func getText() -> String {
        var spaceLabel = space.spaceLabel
        spaceLabel.remove(at: spaceLabel.startIndex)
        return "\(spaceLabel)"
    }
    
    func switchSpace() {
        if !space.active && space.yabaiIndex > 0 {
            gYabaiClient.focusSpace(index: space.yabaiIndex)
        }        
    }
    
    var body: some View {
        Image(nsImage: generateImage(symbol: getText() as NSString, active: space.active, visible: space.visible, hasWindows: space.hasWindows)).onTapGesture {
            switchSpace()
        }.frame(width:24, height: 16)
    }
    
}

struct ContentView: View {
    @EnvironmentObject var spaceModel: SpaceModel
    @AppStorage("showDisplaySeparator") private var showDisplaySeparator = true
    @AppStorage("showCurrentSpaceOnly") private var showCurrentSpaceOnly = false
    @AppStorage("buttonStyle") private var buttonStyle: ButtonStyle = .numeric
    
    private func generateSpaces() -> [Space] {
        var shownSpaces = [Space]()
        for space in spaceModel.spaces {
            if !space.isFullscreen {
                shownSpaces.append(space)
            }
        }
        return shownSpaces.sorted(by: { $0.spaceLabel < $1.spaceLabel })
    }
    
    var body: some View {
        HStack (spacing: 4) {
            if buttonStyle == .numeric || spaceModel.displays.count > 0 {
                ForEach(generateSpaces(), id: \.self) {space in
                    SpaceButton(space: space)
                }
            }
        }.padding(2)
    }
}
