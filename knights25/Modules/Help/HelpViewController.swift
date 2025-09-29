//
//  HelpViewController.swift
//  knights25
//
//  Created by Vadim on 18. 9. 2025..
//

import UIKit

final class HelpViewController: UIViewController {
    let viewModel: HelpViewModel
    init(viewModel: HelpViewModel) { self.viewModel = viewModel; super.init(nibName:nil,bundle:nil) }
    required init?(coder: NSCoder) { fatalError("init(coder:)") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        let card = UIView()
        card.backgroundColor = .systemBackground
        card.layer.cornerRadius = 16
        view.addSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            card.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            card.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            card.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            card.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4)
        ])
        let close = UIButton(type: .system); close.setTitle("Got it", for: .normal)
        close.addTarget(self, action: #selector(dismissMe), for: .touchUpInside)
        card.addSubview(close); close.center = card.center
    }
    @objc private func dismissMe() {
        viewModel.onDismiss?()
        dismiss(animated: true)
    }
}
