//
//  DESharedDialogsViewController.swift
//  DialExt
//
//  Created by Vladlex on 03/10/2017.
//  Copyright (c) 2017 Vladlex. All rights reserved.
//

import UIKit
import MobileCoreServices

public protocol DESharedDialogsViewControllerPresenter {
    
    func shouldShowDialog(_ dialog: AppSharedDialog) -> Bool
    
    func isSelectionAllowedForDialog(_ dialog: AppSharedDialog) -> Bool
    
}

public protocol DESharedDialogsViewControllerExtensionContextProvider {
    func extensionContextForSharedDialogsViewController(_ viewController: DESharedDialogsViewController) -> NSExtensionContext?
}

public class DEDefaultSharedDialogsViewControllerPresenter: DESharedDialogsViewControllerPresenter {
    
    public func shouldShowDialog(_ dialog: AppSharedDialog) -> Bool {
        return true
    }
    
    public func isSelectionAllowedForDialog(_ dialog: AppSharedDialog) -> Bool {
        return !dialog.isReadOnly
    }
}

open class DESharedDialogsViewController: UIViewController, UISearchResultsUpdating, UITableViewDataSource, UITableViewDelegate {
    
    static public func createFromDefaultStoryboard(config: DESharedDataConfig) -> DESharedDialogsViewController {
        let bundle = Bundle.dialExtResourcesBundle
        let storyboard = UIStoryboard.loadFirstFound(name: "DESharedDialogsViewController", bundles: [bundle])!
        let controller = storyboard.instantiateInitialViewController() as! DESharedDialogsViewController
        controller.config = config
        return controller
    }
    
    var dialogs: [AppSharedDialog] = [] {
        didSet {
            updatePresentedDialogs()
        }
    }
    
    private var config: DESharedDataConfig!
    
    /// Dialogs to presented (filtered by search if any search in progress)
    var presentedDialogs: [AppSharedDialog] = [] {
        didSet {
            if presentedDialogs != oldValue {
                self.tableView.reloadData()
            }
        }
    }
    
    public lazy var uploader: DEFileUploaderable = {
        let tokenProvider = DEFileUploadTokenInfoProvider.init(keychainGroupId: self.config.keychainGroup)
        let uploader = DEFileUploader.init(tokenProvider: tokenProvider, endpoints: self.config.endpointUploadMethodURLs)
        return uploader
    }()
    
    public var onDidFinish:(()->())? = nil
    
    public var manager: DESharedDialogsManager!
    
    public var avatarProvider: DEAvatarImageProvidable!
    
    public var extensionContextProvider: DESharedDialogsViewControllerExtensionContextProvider? = nil
    
    private var hasSelectedDialogs: Bool = false {
        didSet {
            if hasSelectedDialogs != oldValue {
                updateBottomPanelVisibility()
            }
        }
    }
    
    private var selectedDialogIds: Set<AppSharedDialog.Id> = Set() {
        didSet {
            updateBottomPanelContent()
            self.hasSelectedDialogs = selectedDialogIds.count > 0
        }
    }
    
    private var selectedDialogs: [AppSharedDialog] {
        return self.dialogs.filter({selectedDialogIds.contains($0.id)})
    }
    
    public var presenter: DESharedDialogsViewControllerPresenter? = DEDefaultSharedDialogsViewControllerPresenter.init()
    
    private var image: UIImage? = {
        let bundle = Bundle(for: DESharedDialogsViewController.self)
        let image = UIImage(named: "gp_chat", in: bundle, compatibleWith: nil)
        return image
    }()
    
    private var searchController: UISearchController = {
        let controller = UISearchController.init(searchResultsController: nil)
        return controller
    }()
    
    private var isSearching: Bool {
        guard let text = searchController.searchBar.text else {
            return false
        }
        return !text.isEmpty
    }
    
    @IBOutlet public private(set) var tableView: UITableView!
    
    @IBOutlet public private(set) var sendView: UIView!
    
    @IBOutlet public private(set) var recipientsLabel: UILabel!
    
    @IBOutlet public private(set) var contentView: UIView!
    
    @IBOutlet private var sendViewLineSeparatorHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet private var contentBottomConstraint: NSLayoutConstraint!
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        guard config != nil else {
            fatalError("No shared data config set")
        }
        
        if self.manager == nil {
            self.manager = DESharedDialogsManager.init(sharedDataConfig: self.config)
        }
        
        if self.avatarProvider == nil {
            let provider = DEAvatarImageProvider.init(localLoader: .createWithContainerGroupId(config.appGroup))
            self.avatarProvider = provider
        }
        
        self.manager.dataLoader.onDidChangeState = { [weak self] state in
            withExtendedLifetime(self){
                guard self != nil else { return }
                self!.handleDialogsState(state)
            }
        }
        
        self.manager.dataLoader.start()
        
        searchController.searchResultsUpdater = self
        self.tableView.tableHeaderView = searchController.searchBar
        self.definesPresentationContext = true
        
        sendViewLineSeparatorHeightConstraint.constant = 1.0 / UIScreen.main.scale
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                                target: self,
                                                                action: #selector(close(sender:)))
        
        // Do any additional setup after loading the view, typically from a nib.
        
        NotificationCenter.default.addObserver(forName: Notification.Name.KeyboardListenerDidDetectEvent,
                                               object: KeyboardListener.shared,
                                               queue: nil) { [unowned self] (notification) in
                                                let event = notification.userInfo![KeyboardListener.eventUserInfoKey] as! KeyboardEvent
                                                self.view.animateKeyboardEvent(event, bottomConstraint: self.contentBottomConstraint)
        }
    }
    
    public func resetDialogs(_ dialogs: [AppSharedDialog]) {
        self.dialogs = dialogs
    }
    
    @objc private func close(sender: AnyObject) {
        self.onDidFinish?()
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction private func sendAction(_ sender: AnyObject) {
         uploadFiles()
    }
    
    
    private func uploadFiles() {
        /*
        if let item = self.currentItems().first,
            let attachment = item.item.firstFoundDataRepresentableAttachment {
            attachment.loadItem(forTypeIdentifier: kUTTypeData as String, options: nil, completionHandler: { (coder, error) in
                
            })
        }
 */
        
    }
    
    private func preferredFileExtension(forItem item: NSExtensionItem) -> String? {
        
        var dict = ["123":"321"]
        dict.de_merge(with: ["555":"455"])
        
        let myitem = item.attachments!.first as! NSItemProvider
        let testTest = "321".testTest()
        
        if let attachments = item.attachments {
            for case let attachment as NSItemProvider in attachments {
//                if let ext = attachment.supposedFileExtension {
//                    return ext
//                }
            }
        }
        
        return nil
    }
    
    private func currentItems() -> [UploadItem] {
        guard let provider = self.extensionContextProvider,
            let context = provider.extensionContextForSharedDialogsViewController(self) else {
                return []
        }
        
        var uploadItems: [UploadItem] = []
        for case let item as NSExtensionItem in context.inputItems {
            guard let attachments = item.attachments else {
                continue
            }
            
            let itemAttachments: [NSItemProvider] = attachments.flatMap({ $0 as? NSItemProvider})
            if itemAttachments.count > 0 {
                var uploadItem = UploadItem(item: item, attachments: itemAttachments)
                uploadItems.append(uploadItem)
            }
        }
        return uploadItems
    }
    
    
    private struct UploadItem {
        var item: NSExtensionItem!
        var attachments: [NSItemProvider]!
    }
    
    private func handleDialogsState(_ state: DESharedDialogsDataLoader.DataState) {
        switch state {
        case let .failured(error):
            fatalError("Totally failed: \(error)")
            
        case .loaded:
            self.dialogs = self.manager.dataLoader.context!.dialogs.filter({self.isSelectionAllowed(for: $0)})
            
        default:
            break
        }
    }
    
    private func updatePresentedDialogs() {
        if self.isSearching {
            let query = self.searchController.searchBar.text!.lowercased()
            self.presentedDialogs = self.dialogs.filter({ isSearchTestPassingDialog($0, query: query)})
        }
        else {
            self.presentedDialogs = dialogs
        }
    }
    
    private func isSearchTestPassingDialog(_ dialog: AppSharedDialog, query: String) -> Bool {
        return dialog.title.lowercased().contains(query)
    }
    
    public func updateSearchResults(for searchController: UISearchController) {
        updatePresentedDialogs()
    }
    
    private func shouldShowDialog(_ dialog: AppSharedDialog) -> Bool {
        guard let presenter = self.presenter else {
            return true
        }
        return presenter.shouldShowDialog(dialog)
    }
    
    private func isSelectionAllowed(for dialog: AppSharedDialog) -> Bool {
        guard let presenter = self.presenter else {
            return true
        }
        return presenter.isSelectionAllowedForDialog(dialog)
    }
    
    private func dialog(at: IndexPath) -> AppSharedDialog? {
        if at.row < presentedDialogs.count {
            return self.presentedDialogs[at.row]
        }
        return nil
    }
    
    private func isSelectionAllowed(at indexPath: IndexPath) -> Bool {
        let dialog = self.dialog(at: indexPath)!
        return isSelectionAllowed(for: dialog)
    }
    
    private func loadImage(dialog: AppSharedDialog) {
        self.avatarProvider!.provideImage(dialog: dialog) { [unowned self] (image, isPlaceholder) in
            self.updateAvatarForDialog(dialog, image: image)
        }
    }
    
    private func updateAvatarForDialog(_ dialog: AppSharedDialog, image: UIImage?) {
        if let index = self.presentedDialogs.index(where: { $0.id == dialog.id }) {
            let indexPath = IndexPath(row: index, section: 0)
            if let cell = tableView.cellForRow(at: indexPath) as? DEDialogCell {
                self.updateAvatarInCell(cell, image: image)
            }
        }
    }
    
    private func updateSelectedDialogs(dialogId: AppSharedDialog.Id, selected: Bool) {
        if selected {
            selectedDialogIds.insert(dialogId)
        }
        else {
            selectedDialogIds.remove(dialogId)
        }
    }
    
    private func updateBottomPanelVisibility() {
        let shouldBeShown = self.hasSelectedDialogs
        let options: UIViewAnimationOptions = [UIViewAnimationOptions.curveEaseInOut,
                                               UIViewAnimationOptions.beginFromCurrentState]
        UIView.animate(withDuration: 0.15, delay: 0.0, options: options, animations: {
            self.sendView.isHidden = !shouldBeShown
        }, completion: nil)
    }
    
    private func updateBottomPanelContent() {
        let dialogTitles: [String] = selectedDialogs.map({$0.title})
        let title = dialogTitles.joined(separator: ", ")
        recipientsLabel.text = title
    }
    
    private func updateAvatarInCell(_ cell: DEDialogCell, image: UIImage?) {
        cell.avatarView.image = image
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presentedDialogs.count
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52.0
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? DEDialogCell {
            var state = cell.selectionState
            state.selected = !state.selected
            cell.setSelectionState(state)
            updateSelectedDialogs(dialogId: self.presentedDialogs[indexPath.row].id, selected: state.selected)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let dialog = self.presentedDialogs[indexPath.row]
        self.loadImage(dialog: dialog)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DEDialogCell", for: indexPath) as! DEDialogCell
        let dialog = self.presentedDialogs[indexPath.row]
        cell.nameLabel.text = dialog.title
        
        let names: [String] = dialog.uids.map({
            return "\($0)"
        })
        cell.statusLabel.text = names.joined(separator: ", ")
        cell.statusLabelContainer.isHidden = !dialog.isGroup
        
        var selectionState = cell.selectionState
        selectionState.selected = self.selectedDialogIds.contains(dialog.id)
        cell.setSelectionState(selectionState, animated: false)
        
        cell.avatarView.image = self.avatarProvider.provideImage(dialog: dialog, completion: { (image, placeholder) in
        })
        
        let cellSide = min(cell.frame.size.width, cell.frame.size.height)
        cell.avatarView.layer.cornerRadius = cellSide / 2.0
        cell.avatarView.layer.masksToBounds = true
        
        return cell
    }
}

