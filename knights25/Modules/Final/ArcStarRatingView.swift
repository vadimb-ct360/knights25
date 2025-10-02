//
//  ArcStarRatingView.swift
//  knights25
//
//  Created by Vadim on 26. 9. 2025..
//

import UIKit

final class ArcStarRatingView: UIView {
    
    // MARK: Public API
    var rate: Int = 0 { didSet { rate = max(0, min(rate, maxRate)); refresh() } }
    var maxRate: Int = 10 { didSet { maxRate = max(1, maxRate); refresh() } }
    var starSize: CGSize = CGSize(width: 28, height: 28) { didSet { refresh() } }
    var arcDegrees: CGFloat = 140 { didSet { refresh() } }
    
    // MARK: Images
    var filledImage: UIImage? = UIImage(named: "star_star")
    var emptyImage: UIImage?  = UIImage(named: "fade_star")
    
    // MARK: Internals
    private var starViews: [UIImageView] = []
    
    
    // MARK: Life cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
     }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutStars()
    }

    
    // MARK: Public helpers
    func configure(rate: Int, maxRate: Int = 12, starSize: CGSize = CGSize(width: 28, height: 28)) {
        self.maxRate = maxRate
        self.rate = rate
        self.starSize = starSize
        refresh()
    }
    
    // MARK: Private
    private func refresh() {
        // Ensure we have `maxRate` image views
        if starViews.count != maxRate {
            starViews.forEach { $0.removeFromSuperview() }
            starViews = (0..<maxRate).map { _ in
                let iv = UIImageView()
                iv.contentMode = .scaleAspectFit
                addSubview(iv)
                return iv
            }
        }
        // Set images
        for i in 0..<starViews.count {
            starViews[i].image = (i < rate) ? filledImage : emptyImage
            starViews[i].bounds.size = starSize
        }
        setNeedsLayout()
    }
    
    private func layoutStars() {
        guard maxRate > 0, !starViews.isEmpty else { return }

        // Device width and chord
        let deviceWidth = UIScreen.main.bounds.width
        let chord: CGFloat = deviceWidth * 0.8

        // Arc parameters
        let theta = arcDegrees * .pi / 180
        let radius = chord / (2 * sin(theta / 2))

        // Same center as before
        let centerX = bounds.midX
        let verticalOffset: CGFloat = starSize.height * 0.2
        let circleCenter = CGPoint(x: centerX, y: radius - verticalOffset)

   
        // ---- Position stars along the arc ----
        let start = -theta / 2
        let step = (maxRate == 1) ? 0 : (theta / CGFloat(maxRate - 1))

        for i in 0..<maxRate {
            let angle = start + CGFloat(i) * step
            let x = circleCenter.x + 0.9 * radius * sin(angle)
            let y = circleCenter.y + 0.9 * radius * (1 - cos(angle)) // arc below center
            let iv = starViews[i]
            iv.center = CGPoint(x: x, y: y)
            iv.bounds.size = starSize
            iv.transform = CGAffineTransformMakeRotation(angle)
        }
    }

    // Provide a sensible intrinsic height (enough to fit the arc and stars)
    override var intrinsicContentSize: CGSize {
        // Recompute using current device width
        let deviceWidth = UIScreen.main.bounds.width
        let chord: CGFloat = deviceWidth * 0.8
        let theta = arcDegrees * .pi / 180
        let radius = chord / (2 * sin(theta / 2))
        // Height of arc segment = R - R*cos(theta/2), plus star size
        let sagitta = radius * (1 - cos(theta / 2))
        let h = sagitta + starSize.height * 1.1
        // Full width: make it equal to our super’s width if possible; fallback to chord + padding
        let w = max(deviceWidth, chord + starSize.width)
        return CGSize(width: w, height: h)
    }
}
