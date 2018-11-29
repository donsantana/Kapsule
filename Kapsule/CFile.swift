//
//  CFile.swift
//  Kapsule
//
//  Created by Done Santana on 3/10/18.
//  Copyright © 2018 Done Santana. All rights reserved.
//

import Foundation
import UIKit

class CFile {
    func createFile(fileContent: String) -> URL {
        let filePath = NSHomeDirectory() + "/Library/Caches/ktext.txt"
        do {
            _ = try fileContent.write(toFile: filePath, atomically: true, encoding: String.Encoding.utf8)
            
        } catch {
            
        }
        return URL(fileURLWithPath: filePath)
    }
    
    func readFile() -> String {
        var read = "Vacio"
        let filePath = NSHomeDirectory() + "/Library/Caches/ktext.txt"
        do {
            read = try NSString(contentsOfFile: filePath, encoding: String.Encoding.utf8.rawValue) as String
        }catch {
        }
        return read
    }
    
    func deleteFile(){
        let fileManager = FileManager()
        let filePath = NSHomeDirectory() + "/Library/Caches/ktext.txt"
        do {
            try fileManager.removeItem(atPath: filePath)
        }catch{
            
        }
    }
}
