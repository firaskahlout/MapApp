//
//  ActionsViewController.swift
//  MapApp
//
//  Created by Firas AlKahlout on 9/5/20.
//  Copyright © 2020 Firas Alkahlout. All rights reserved.
//

import UIKit
import CoreLocation

final class ActionsViewController: UIViewController {

    // MARK: Typealias
    
    typealias ActionHandler = ((ActionType) -> Void)
    
    // MARK: Outlets
    
    @IBOutlet private weak var latitudeLabel: UILabel!
    @IBOutlet private weak var longitudeLabel: UILabel!
    
    // MARK: Proparities
    
    private let coordinate: CLLocationCoordinate2D
    private var handler: ActionHandler?
    
    // MARK: Init
    
    init(
        coordinate: CLLocationCoordinate2D,
        handler: ActionHandler?
    ) {
        self.coordinate = coordinate
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
        latitudeLabel.text = String(coordinate.latitude)
        longitudeLabel.text = String(coordinate.longitude)
    }
    
    // MARK: Actions
    
    @IBAction private func didTapShareButton(_ sender: Any) {
        dismiss(animated: true) { self.handler?(.share(self.coordinate)) }
    }
    
    @IBAction private func didTapSaveButton(_ sender: Any) {
        dismiss(animated: true) { self.handler?(.save(self.coordinate)) }
    }
}

// MARK: - ActionsView.ActionType

extension ActionsViewController {
    enum ActionType {
        case share(_ coordinate: CLLocationCoordinate2D)
        case save(_ coordinate: CLLocationCoordinate2D)
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
