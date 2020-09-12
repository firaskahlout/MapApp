//
//  ActionsViewController.swift
//  MapApp
//
//  Created by Firas AlKahlout on 9/5/20.
//  Copyright © 2020 Firas Alkahlout. All rights reserved.
//

import UIKit

final class ActionsViewController: UIViewController {

    // MARK: Typealias
    
    typealias ActionHandler = ((LocationItem.ActionType) -> Void)
    
    // MARK: Outlets
    
    @IBOutlet private weak var titleLable: UILabel!
    @IBOutlet private weak var saveButton: UIButton!
    @IBOutlet private weak var deleteButton: UIButton!
    @IBOutlet private weak var latitudeLabel: UILabel!
    @IBOutlet private weak var longitudeLabel: UILabel!
    
    // MARK: Proparities
    
    private let location: LocationItem
    private var handler: ActionHandler?
    
    // MARK: Init
    
    init(
        location: LocationItem,
        handler: ActionHandler?
    ) {
        self.location = location
        self.handler = handler
        let bundle = Bundle(for: type(of: self))
        super.init(nibName: nil, bundle: bundle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.isHidden = location.name != nil
        deleteButton.isHidden = location.name == nil
        titleLable.text = location.name ?? "No Title"
        latitudeLabel.text = String(location.latitude)
        longitudeLabel.text = String(location.longitude)
    }
    
    // MARK: Actions
    
    @IBAction private func didTapShareButton(_ sender: Any) {
        dismiss(animated: true) { self.handler?(.share(self.location)) }
    }
    
    @IBAction private func didTapSaveButton(_ sender: Any) {
        dismiss(animated: true) { self.handler?(.save(self.location)) }
    }
    
    @IBAction private func didTapDeleteButton(_ sender: Any) {
        dismiss(animated: true) { self.handler?(.delete(self.location)) }
    }
}

// MARK: - UIPopoverPresentationControllerDelegate

extension ActionsViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        .none
    }
    
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        true
    }
}
