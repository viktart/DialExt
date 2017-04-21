//
//  NSItemProvider+DialExt.swift
//  DialExt
//
//  Created by Aleksei Gordeev on 20/04/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation

import MobileCoreServices

public enum DEItemProviderError: Error {
    case failToRepresent
}

public extension NSItemProvider {
    
    public var isDataRepresentable: Bool {
        return self.hasItemConformingToTypeIdentifier(kUTTypeData as String)
    }
    
    public var supposedMimeType: String? {
        for case let uti as CFString in self.registeredTypeIdentifiers {
            if let foundExtensionUnmanaged = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType) {
                return foundExtensionUnmanaged.takeRetainedValue() as String
            }
        }
        return nil
    }
    
    public var supposedFileExtension: String? {
        for case let uti as CFString in self.registeredTypeIdentifiers {
            if let foundExtensionUnmanaged = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassFilenameExtension) {
                return foundExtensionUnmanaged.takeRetainedValue() as String
            }
        }
        return nil
    }
    
    @discardableResult public func loadItemData(options: [AnyHashable : Any]?,
                                                completionHandler: NSItemProvider.CompletionHandler?) -> Bool {
        let typeId = kUTTypeData as String
        guard self.hasItemConformingToTypeIdentifier(typeId) else {
            return false
        }
        self.loadItem(forTypeIdentifier: typeId, options: options, completionHandler: completionHandler)
        return true
    }
    
    @discardableResult public func loadAndRepresentData(options: [AnyHashable : Any]?,
                                                        completionHandler: ((Data?, Error?)->())?) -> Bool {
        return self.loadItemData(options: options, completionHandler: { (result, error) in
            switch result {
            case let data as Data:
                completionHandler?(data, nil)
                
            case let url as URL:
                DispatchQueue.global(qos: .utility).async {
                    let data: Data
                    do {
                        data = try Data.init(contentsOf: url)
                    }
                    catch {
                        completionHandler?(nil, error)
                        return
                    }
                    
                    completionHandler?(data, nil)
                }
            default:
                completionHandler?(nil, DEItemProviderError.failToRepresent)
                break
            }
        })
    }
}