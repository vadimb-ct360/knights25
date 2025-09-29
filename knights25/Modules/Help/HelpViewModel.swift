//
//  HelpViewModel.swift
//  knights25
//
//  Created by Vadim on 18. 9. 2025..
//

final class HelpViewModel {
    var onDismiss: (() -> Void)?
    func close() { onDismiss?() }
}
