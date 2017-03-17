//
//  DialogsController.swift
//  DialExt
//
//  Created by Aleksei Gordeev on 15/03/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import DialExt

class DialogsController: DESharedDialogsViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = nil
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                                 target: self,
                                                                 action: #selector(addDialogAction(sender:)))
    }
    
    
    @objc private func addDialogAction(sender: AnyObject) {
        
        if let context = self.manager.context {
            let contextBuilder = context.getBuilder()
            let dialogBuilder = Dialog.getBuilder()
            dialogBuilder.title = UUID.init().uuidString
            dialogBuilder.isGroup = false
            dialogBuilder.uid = []
            let dialog = try! dialogBuilder.build()
            
            contextBuilder.dialog.insert(dialog, at: 0)
            
            let newContext = try! contextBuilder.build()
            self.manager.saveDialogListContext(newContext, completion: { (success, error) in
                
            })
        }
    }
}
