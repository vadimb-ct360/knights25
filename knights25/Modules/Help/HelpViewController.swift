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
    let card = UIView()
    let status = UILabel()
    var knights = [UIImageView]()
    let pos: [(Int, Int)] = [(1,1), (3,2), (2,0), (1,2), (0,4), (2,3), (4,2),  ]
    var move = 0
    var isAnimating = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        card.backgroundColor = .systemBackground
        card.layer.cornerRadius = 16
        view.addSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false
        
        
        status.text = viewModel.text[0]
        status.textAlignment = .center
        status.font = AppFont.font(21, weight: .semibold)
        status.textColor = .white
        status.numberOfLines = 0
        view.addSubview(status)
        status.translatesAutoresizingMaskIntoConstraints = false
  
        NSLayoutConstraint.activate([
            card.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            card.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            card.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
             card.heightAnchor.constraint(equalTo: card.widthAnchor),
            status.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
             status.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            status.bottomAnchor.constraint(equalTo: card.topAnchor, constant: -50),
  
        ])
      }
    
    override func viewDidAppear(_ animated: Bool) {
           super.viewDidAppear(animated)
            render()
            startLoop()
    }
    
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            // Only stop when leaving this VC (back or swipe)
            if isMovingFromParent || isBeingDismissed {
                stopLoop()
            }
        }

        private func startLoop() {
            guard !isAnimating else { return }
            isAnimating = true
            animateOnce()
        }
    
    private func playSound(_ sound: String) {
        SFX.shared.playIfOn(sound, isOn: viewModel.sound)
    }
   

        private func animateOnce() {
            guard isAnimating else { return }
            
            move = move<pos.count-1 ? move + 1 : 0
            let m = min(3,move)
         
            let sound = move>0 ? "merge_\(m)" : "clear"
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
                self.status.text = self.viewModel.text[self.move]
               
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
            view.layer.removeAllAnimations() // cancels any in-flight UIView animations
        }
  

    private func render() {
        
        for r in 0..<5 {
            for c in 0..<5 {
                let v = UIView()
                v.frame = frameForCell(r, c)
                v.backgroundColor =   (r+c) % 2 == 0 ? .white : .lightGray
                card.addSubview(v)
            }
        }
        for p in pos {
            let r = p.0
            let c = p.1
            let v = UIImageView(image: UIImage(named: "knight_2"))
            v.frame = frameForCell(r, c)
            v.alpha = (r+c) % 2 == 0 ? 0.7 : 0.6
            card.addSubview(v)
            knights.append(v)
        }
        knights[0].alpha = 1
        
        let v = UIImageView(image: UIImage(named: "knight_3"))
        v.frame = frameForCell(0, 3)
        card.addSubview(v)
        let v2 = UIImageView(image: UIImage(named: "knight_3"))
        v2.frame = frameForCell(0, 0)
        card.addSubview(v2)

    }
    
    private func frameForCell(_ r: Int, _ c: Int) -> CGRect {
        let s = card.bounds.width / CGFloat(5)
        
        return CGRect(x: CGFloat(c) * s, y: CGFloat(r) * s, width: s, height: s)
    }
  
     
}
