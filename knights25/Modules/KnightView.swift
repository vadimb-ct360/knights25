//
//  KnightView.swift
//  knights25
//
//  Created by Vadim on 19. 9. 2025..
//

import UIKit


final class PaddedLabel: UILabel {
    var insets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
    override func drawText(in rect: CGRect) { super.drawText(in: rect.inset(by: insets)) }
    override var intrinsicContentSize: CGSize {
        let s = super.intrinsicContentSize
        return CGSize(width: s.width + insets.left + insets.right,
                      height: s.height + insets.top + insets.bottom)
    }
}

final class KnightView: UIImageView {
    var index: (r:Int,c:Int)
    let colorId: Int
    var startCenter: CGPoint = .zero
    
    init(colorId: Int, index: (Int,Int)) {
        self.colorId = colorId
        self.index = index
        super.init(frame: .zero)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
