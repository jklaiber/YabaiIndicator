//
//  YabaiClient.swift
//  YabaiIndicator
//
//  Created by Max Zhao on 01/01/2022.
//

import SwiftUI

struct YabaiResponse {
    let error:Int
    let response:Any
}

class YabaiClient {
    
    func _yabaiSocketCall(_ args: [String]) -> (Int, String) {
        var cresp:UnsafeMutablePointer<CChar>? = nil
        var cargs = args.map { strdup($0) }

        let ret = send_message(Int32(args.count), &cargs, &cresp)

        for ptr in cargs { free(ptr) }
        var response = ""
        if let r = cresp {
            response = String(cString: r)
        }
        free(cresp)
        return (Int(ret), response)
    }
    
    @discardableResult
    func yabaiSocketCall(_ args: String...) -> YabaiResponse {
        let (e, m) = _yabaiSocketCall(args)
        var resp: Any = []
        if m.count > 0 {
            if let data = m.data(using: .utf8) {
                do {
                    resp = try JSONSerialization.jsonObject(with: data, options: [])
                } catch {
                    print(error)
                }
            }
        }
        let r = YabaiResponse(error: e, response: resp)
        return r
    }
    
    func focusSpace(index: Int) {
        yabaiSocketCall(
            "-m", "space", "--switch", "s\(index)")
    }
    
    func querySpaces() -> [Space] {
        if let r = yabaiSocketCall("-m", "query", "--spaces").response as? [[String: Any]] {
            let spaces = r.compactMap{Space(spaceid: $0["id"] as! UInt64, spaceLabel: $0["label"] as! String, hasWindows: $0["windows"] as! [Int], uuid: $0["uuid"] as! String, visible: $0["is-visible"] as! Bool, active: $0["has-focus"] as! Bool, display: $0["display"] as! Int, index: $0["index"] as! Int, yabaiIndex: $0["index"] as! Int)}
            return spaces
        }
        return []
    }
    
    func queryWindows() -> [Window] {
        if let r = yabaiSocketCall("-m", "query", "--windows").response as? [[String: Any]] {
            let windows = r.compactMap{Window(id: $0["id"] as! UInt64, pid: $0["pid"] as! UInt64, app: $0["app"] as! String, title: $0["title"] as! String, frame: NSRect(x: ($0["frame"] as! [String:Double])["x"]!, y: ($0["frame"] as! [String:Double])["y"]!, width: ($0["frame"] as! [String:Double])["w"]!, height: ($0["frame"] as! [String:Double])["h"]!), displayIndex: $0["display"] as! Int, spaceIndex: $0["space"] as! Int)}
            return windows
        }
        return []
    }
}

let gYabaiClient = YabaiClient()
