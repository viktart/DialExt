//
//  ShareViewController.swift
//  Share
//
//  Created by Aleksei Gordeev on 15/03/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import Social
import DialExt

public enum FakeError: Error {
    case noError
}

class ShareViewController: DESharedDialogsPresentationViewController {
    
    override var config: DESharedDataConfig! {
        return DESharedDataConfig.init(keychainGroup: "", appGroup: "")
    }
    
    private var dialogsController: DESharedDialogsViewController? = nil
    
    private var navController: UINavigationController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard config != nil else {
            fatalError("No shared data config found!")
        }
        
        let dialogsController = DESharedDialogsViewController.createFromDefaultStoryboard(config: config)
        dialogsController.extensionContextProvider = self
        self.dialogsController = dialogsController
        
        let navController = UINavigationController(rootViewController: dialogsController)
        self.navController = navController
        
        self.dialogsController?.onDidFinish = { [unowned self] in
            if let context = self.extensionContext {
                self.navController!.dismiss(animated: true, completion: { 
                    context.cancelRequest(withError: FakeError.noError)
                })
            }
        }
        
        self.present(navController, animated: true, completion: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }

    
//    override func isContentValid() -> Bool {
//        // Do validation of contentText and/or NSExtensionContext attachments here
//        return true
//    }
//
//    override func didSelectPost() {
//        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
//    
//        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
//        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
//    }
//
//    override func configurationItems() -> [Any]! {
//        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
//        return []
//    }
    
}
