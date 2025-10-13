//
//  HelpViewController.swift
//  knights25
//
//  Created by Vadim on 18. 9. 2025..
//

import UIKit

final class HelpViewController: BaseViewController {
    let viewModel: HelpViewModel
    init(viewModel: HelpViewModel) { self.viewModel = viewModel; super.init(nibName:nil,bundle:nil) }
    required init?(coder: NSCoder) { fatalError("init(coder:)") }
    let card = UIView()
    let helpLabel = UILabel()
    let status = UILabel()
    let versionLabel = UILabel()
    var knights = [UIImageView]()
    let pos: [(Int, Int)] = [(1,1), (3,2), (2,0), (1,2), (0,4), (2,3), (4,2),  ]
    var move = 0
    var index = 0
    var isAnimating = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let info = Bundle.main.infoDictionary
        let appVersion: String? = info?["CFBundleShortVersionString"] as? String
        let version: String = appVersion ?? ""
        
        loadUI(version:  version)
    }
    
    
    func loadUI(version: String) {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        card.backgroundColor = .systemBackground
        card.layer.cornerRadius = 16
        view.addSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false
        
        
        helpLabel.text = "How to Play All Knights"
        helpLabel.textAlignment = .center
        helpLabel.font = AppFont.font(25, weight: .bold)
        helpLabel.textColor = .lightGray
        view.addSubview(helpLabel)
        helpLabel.translatesAutoresizingMaskIntoConstraints = false
        
            versionLabel.text = "Version \(version)"
            versionLabel.textAlignment = .center
            versionLabel.font = AppFont.font(19, weight: .bold)
            versionLabel.textColor = .lightGray
        view.addSubview(versionLabel)
        versionLabel.translatesAutoresizingMaskIntoConstraints = false

        status.text = viewModel.helpText[0]
        status.textAlignment = .left
        status.font = AppFont.font(19, weight: .semibold)
        status.textColor = .lightGray
        status.numberOfLines = 0
        view.addSubview(status)
        status.translatesAutoresizingMaskIntoConstraints = false
        let g = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            helpLabel.centerXAnchor.constraint(equalTo: g.centerXAnchor),
            helpLabel.topAnchor.constraint(equalTo: g.topAnchor, constant: 20),
            versionLabel.centerXAnchor.constraint(equalTo: g.centerXAnchor),
            versionLabel.topAnchor.constraint(equalTo: card.bottomAnchor, constant: 40),
     
            card.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            card.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            card.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            card.heightAnchor.constraint(equalTo: card.widthAnchor),
            status.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            status.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            status.bottomAnchor.constraint(equalTo: card.topAnchor, constant: -40),
            
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        render()
        startLoop()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent || isBeingDismissed {
            stopLoop()
        }
    }
    
    private func startLoop() {
        guard !isAnimating else { return }
        isAnimating = true
        animateOnce()
    }
    
    
    
    private func animateOnce() {
        guard isAnimating else { return }
        
        let m = 1 + (min(6,move)-1) % 3
        if move==2 || move==5 {
            index += 1
            if index>=viewModel.helpText.count {
                index = 0
            }
            status.text = viewModel.helpText[index]
    
        }
        
        let sound = move>0 ? "merge_\(m)" : "clear"
        move = move<pos.count-1 ? move + 1 : 0
        let ps =  pos[0]
        let pt =  pos[move]
        let fs = frameForCell(ps.0, ps.1)
        let ft = frameForCell(pt.0, pt.1)
        let fx = ft.midX - fs.midX
        let fy = ft.midY - fs.midY
        
        let kt = knights[move]
        let ks =  knights[0]
        UIView.animate(withDuration: 0.6, delay: 0.6, options: [.curveEaseInOut], animations: {
            ks.transform = CGAffineTransformMakeTranslation(fx, fy)
            self.playSound(sound)
            
        }) { _ in
            UIView.animate(withDuration: 0.5, delay: 0.1, options: [.curveEaseInOut], animations: {
            }) { _ in
                if self.move>0 {
                    kt.isHidden = true
                } else {
                    self.knights.forEach({($0 as UIImageView).isHidden = false})
                }
                self.animateOnce()
            }
        }
    }
    
    private func stopLoop() {
        isAnimating = false
        view.layer.removeAllAnimations()
    }
    
    
    private func render() {
        
        for r in 0..<5 {
            for c in 0..<5 {
                let v = UIView()
                v.frame = frameForCell(r, c)
                v.backgroundColor =   (r+c) % 2 == 0 ? .white : UIColor(cgColor: CGColor(gray: 0.75, alpha: 1))
                card.addSubview(v)
            }
        }
        for p in pos {
            let r = p.0
            let c = p.1
            let v = UIImageView(image: UIImage(named: "knight_2"))
            v.frame = frameForCell(r, c, pad: 0.9)
            v.alpha = (r+c) % 2 == 0 ? 0.7 : 0.6
            card.addSubview(v)
            knights.append(v)
        }
        knights[0].alpha = 1
        
         
    }
    
    private func frameForCell(_ r: Int, _ c: Int, pad: CGFloat = 1.0) -> CGRect {
        let s = card.bounds.width / CGFloat(5)
        return CGRect(x: CGFloat(c) * s, y: CGFloat(r) * s, width: s * pad, height: s * pad)
    }
    
    
}
