//
//  BubbleView.swift
//  knights25
//
//  Created by Vadim on 24. 9. 2025..
//


import UIKit

final class BubbleView: UIView {
    private let bg = UIImageView()
    private let label = UILabel()

    // MARK: - Init
    init(text: String,
         color: Int = 3,
         textColor: UIColor = .white,
         font: UIFont = AppFont.font(25, weight: .bold) ){
        super.init(frame: .zero)

        isUserInteractionEnabled = false
        backgroundColor = .clear

        bg.image = UIImage(named: "bubble_\(color)")
            
        bg.contentMode = .scaleAspectFit
        bg.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.textAlignment = .center
        label.textColor = textColor
        label.font = font
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOpacity = 0.4
        label.layer.shadowRadius = 2
        label.layer.shadowOffset = CGSize(width: 0, height: 1)

        addSubview(bg)
        addSubview(label)

        NSLayoutConstraint.activate([
            bg.topAnchor.constraint(equalTo: topAnchor),
            bg.leadingAnchor.constraint(equalTo: leadingAnchor),
            bg.trailingAnchor.constraint(equalTo: trailingAnchor),
            bg.bottomAnchor.constraint(equalTo: bottomAnchor),

            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -1)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Show / Animate
    /// Spawns the bubble at a point and makes it float up & fade.
    func show(from start: CGPoint,
              in parent: UIView,
              size: CGFloat = 80,
              driftY: CGFloat = 90,
              duration: TimeInterval = 0.7) {
        parent.addSubview(self)
        parent.bringSubviewToFront(self)
        frame = CGRect(x: 0, y: 0, width: size, height: size)
        let x: [CGFloat] = [-10, 10]
        center = CGPoint(x: start.x + (x.randomElement() ?? 10), y: start.y - CGFloat.random(in:10...30) )
        layer.zPosition = 200
        transform = CGAffineTransform(scaleX: 0.5, y: 0.5).rotated(by: 1.0)
        alpha = 0.7
      
        UIView.animate(withDuration: 0.45,
                       delay: 0,
                       usingSpringWithDamping: 0.55,
                       initialSpringVelocity: 0.3,
                       
                       animations: {
            self.alpha = 1
            self.transform = .identity
            // move up
        }, completion: { _ in
            UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseIn], animations: {
                self.alpha = 0.75
                self.center = CGPoint(x: self.center.x, y: self.center.y - driftY )
            }, completion: { _ in
                UIView.animate(withDuration: 0.2, delay: 0, animations: {
                    self.alpha = 0.1
                    self.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
                }, completion: { _ in
                    self.removeFromSuperview()
                })
                })
        })
    }
}

