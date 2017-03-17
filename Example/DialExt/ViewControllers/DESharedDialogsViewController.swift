//
//  DESharedDialogsViewController.swift
//  DialExt
//
//  Created by Vladlex on 03/10/2017.
//  Copyright (c) 2017 Vladlex. All rights reserved.
//

import UIKit


public protocol DESharedDialogsViewControllerPresenter {
    
    func shouldShowDialog(_ dialog: Dialog) -> Bool
    
    func isSelectionAllowedForDialog(_ dialog: Dialog) -> Bool
    
}

public class DEDefaultSharedDialogsViewControllerPresenter: DESharedDialogsViewControllerPresenter {
    
    public func shouldShowDialog(_ dialog: Dialog) -> Bool {
        return true
    }
    
    public func isSelectionAllowedForDialog(_ dialog: Dialog) -> Bool {
        return true
    }
}

open class DESharedDialogsViewController: UIViewController, UISearchResultsUpdating, UITableViewDataSource, UITableViewDelegate {
    
    static public func createFromDefaultStoryboard() -> DESharedDialogsViewController {
        let bundle = Bundle(for: self )
        let storyboard = UIStoryboard(name: "DESharedDialogsViewController", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! DESharedDialogsViewController
        return controller
    }
    
    var dialogs: [Dialog] = [] {
        didSet {
            updatePresentedDialogs()
        }
    }
    
    /// Dialogs to presented (filtered by search if any search in progress)
    var presentedDialogs: [Dialog] = [] {
        didSet {
            if presentedDialogs != oldValue {
                self.tableView.reloadData()
            }
        }
    }
    
    public var onDidFinish:(()->())? = nil
    
    public let manager = DESharedDialogsManager.init(groupContainerId: "group.im.dlg.DialExtApp",
                                                     keychainGroup: "")
    public var avatarProvider: DEAvatarImageProvidable!
    
    private var hasSelectedDialogs: Bool = false {
        didSet {
            if hasSelectedDialogs != oldValue {
                updateBottomPanelVisibility()
            }
        }
    }
    
    private var selectedDialogIds: Set<Dialog.Id> = Set() {
        didSet {
            updateBottomPanelContent()
            self.hasSelectedDialogs = selectedDialogIds.count > 0
        }
    }
    
    private var selectedDialogs: [Dialog] {
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
        
        if self.avatarProvider == nil {
            let provider = DEAvatarImageProvider.init(localLoader: .createWithContainerGroupId("group.im.dlg.DialExtApp"))
            self.avatarProvider = provider
        }
        
        self.manager.onDidChangeDialogsState = { [weak self] state in
            withExtendedLifetime(self){
                guard self != nil else { return }
                self!.handleDialogsState(state)
            }
        }
        self.manager.start()
        
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
    
    @objc private func close(sender: AnyObject) {
        self.onDidFinish?()
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func handleDialogsState(_ state: DESharedDialogsManager.DialogsState) {
        switch state {
        case let .failed(error):
            fatalError("Totally failed: \(error)")
            
        case .loaded:
            self.dialogs = self.manager.context!.dialog.filter({self.isSelectionAllowedForDialog($0)})
            
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
    
    private func isSearchTestPassingDialog(_ dialog: Dialog, query: String) -> Bool {
        return dialog.title.lowercased().contains(query)
    }
    
    public func updateSearchResults(for searchController: UISearchController) {
        updatePresentedDialogs()
    }
    
    private func shouldShowDialog(_ dialog: Dialog) -> Bool {
        guard let presenter = self.presenter else {
            return true
        }
        return presenter.shouldShowDialog(dialog)
    }
    
    private func isSelectionAllowedForDialog(_ dialog: Dialog) -> Bool {
        guard let presenter = self.presenter else {
            return true
        }
        return presenter.isSelectionAllowedForDialog(dialog)
    }
    
    private func loadImage(dialog: Dialog) {
        self.avatarProvider!.provideImage(dialog: dialog) { [unowned self] (image, isPlaceholder) in
            self.updateAvatarForDialog(dialog, image: image)
        }
    }
    
    private func updateAvatarForDialog(_ dialog: Dialog, image: UIImage?) {
        if let index = self.presentedDialogs.index(where: { $0.id == dialog.id }) {
            let indexPath = IndexPath(row: index, section: 0)
            if let cell = tableView.cellForRow(at: indexPath) as? DEDialogCell {
                self.updateAvatarInCell(cell, image: image)
            }
        }
    }
    
    private func updateSelectedDialogs(dialogId: Dialog.Id, selected: Bool) {
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
        
        let names: [String] = dialog.uid.map({
            return "\($0)"
        })
        cell.statusLabel.text = names.joined(separator: ", ")
        cell.statusLabelContainer.isHidden = !dialog.isGroup
        
        var selectionState = cell.selectionState
        selectionState.selected = self.selectedDialogIds.contains(dialog.id)
        cell.setSelectionState(selectionState, animated: false)
        
        // Just for having an image. Remove it.
        cell.avatarView.image = DEDialogCell.SelectionState.default.deselectedImage
        
        return cell
    }
}

