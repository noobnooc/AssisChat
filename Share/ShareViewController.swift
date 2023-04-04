//
//  ShareViewController.swift
//  Share
//
//  Created by Nooc on 2023-03-31.
//

import SwiftUI

class ShareViewController: UIViewController {
    private let rootView: any View
    private let hostingController: UIHostingController<AnyView>

    init(rootView: any View) {
        self.rootView = rootView
        self.hostingController = UIHostingController(rootView: AnyView(rootView))
        self.hostingController.view.backgroundColor = UIColor.clear
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        hostingController.didMove(toParent: self)
    }
}

