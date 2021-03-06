//
//  DialogsController.swift
//  DialExt
//
//  Created by Aleksei Gordeev on 15/03/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import DialExt


extension DESharedDialogsViewController {
    
    func setupAddButton() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add,
                                        target: self,
                                        action: #selector(addDialogAction(sender:)))
        self.navigationItem.rightBarButtonItem = addButton
    }
    
    @objc private func addDialogAction(sender: AnyObject) {
        
        if let context = self.manager.dataLoader.context {
            
            let dialog = AppSharedDialog.create({
                $0.title = UUID.init().uuidString
                $0.isGroup = false
                $0.uids = []
                $0.id = Int64(arc4random())
            })
            
            let newContextBuilder = context.getBuilder()
            newContextBuilder.dialogs.insert(dialog, at: 0)
            
            let newContext = try! newContextBuilder.build()
            
            self.manager.dataLoader.contextQueuer.put(representation: newContext)
            self.resetDialogs(newContext.dialogs)
        }
    }
}
