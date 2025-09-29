//
//  LevelViewController.swift
//  knights25
//
//  Created by Vadim on 18. 9. 2025..
//

import UIKit

final class LevelViewController: BaseViewController {
    private let vm: LevelViewModel
    var onContinue: ((Int?) -> Void)?

    private let scorePill = UIView()
    private let scoreLabel = UILabel()
    private let bestLabel  = UILabel()
    
    private let coin = UIImageView(image: UIImage(named: "coin"))
    private let imageView  = UIImageView()
    private let statusLabel  = UILabel()
    private let movesLabel  = UILabel()
    private let continueBtn = UIButton(type: .system)
    private let colorsStrip = UIView()
    private let circle = UIView()
    private let colorsStack = UIStackView()
    private let bg = UIImageView()
  
    init(viewModel: LevelViewModel) { self.vm = viewModel; super.init(nibName:nil,bundle:nil) }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadBG()
        loadUI()
        setupColorsStrip()
        renderColorsStrip(numColors: vm.nextLevel.numColors)
        updateRadiuses()
        bind()
    }
    
    private func loadBG() {
        view.backgroundColor = .systemBackground
   
        bg.image = UIImage(named: "bg")
        
        bg.contentMode = .scaleAspectFill
        bg.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bg)
        
        NSLayoutConstraint.activate([
            bg.topAnchor.constraint(equalTo: view.topAnchor),
            bg.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bg.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bg.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
        ])
    }
    
    func loadUI() {
        title = "Level \(vm.level.num) Complete"
        navigationItem.hidesBackButton = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false

        // Level Score
        scoreLabel.text = "Current Score : \(vm.totalScore)"
        scoreLabel.font = AppFont.font(23, weight: .bold)
        scoreLabel.textAlignment = .center
        scoreLabel.textColor = .white
     
        bestLabel.text = "Best level result : \(vm.bestLevelScore)"
        bestLabel.font = AppFont.font(17, weight: .regular)
        bestLabel.textColor = .darkGray
        bestLabel.textAlignment = .center
   
        scorePill.backgroundColor = .brown.withAlphaComponent(0.5)
        scorePill.layer.cornerRadius = 120
        scorePill.layer.cornerCurve = .continuous
    
        circle.backgroundColor = .brown.withAlphaComponent(0.35)
        circle.layer.cornerRadius = 120
        circle.layer.cornerCurve = .continuous
        circle.layer.shadowColor = UIColor.black.withAlphaComponent(0.15).cgColor
        circle.layer.shadowOpacity = 1
        circle.layer.shadowRadius = 8
        circle.layer.shadowOffset = .zero
    
        // Bonus image
        imageView.contentMode = .scaleAspectFit
        let num = 1 + (vm.level.num-1) % 15
        imageView.image = UIImage(named: "level_\(num)")
        imageView.layer.magnificationFilter = .nearest

        // next  Level title
        let nextNum = vm.nextLevel.num
       

      
        // NEW: Next level description
        statusLabel.text = vm.nextLevelDescription
        statusLabel.textAlignment = .center
        statusLabel.font = AppFont.font(17, weight: .light)
        statusLabel.textColor = .black
        
        movesLabel.text = "\(vm.nextLevel.moveQuota) moves to go"
        movesLabel.textAlignment = .center
        movesLabel.font = AppFont.font(17, weight: .light)
        movesLabel.textColor = .black
      
     
        let raw = UIImage(named: "button_2")!
        let bg  = raw.resizableImage(withCapInsets: UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2),
                                     resizingMode: .stretch)

        var config = UIButton.Configuration.plain()
        config.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)
        
        config.attributedTitle = AttributedString("Level \(nextNum)",
                attributes: .init([.font: AppFont.font(27, weight: .bold),
                                   .foregroundColor: UIColor(cgColor: CGColor(red: 1, green: 0.85, blue: 0.5, alpha: 1))]))
        config.background.backgroundColor = .clear
        continueBtn.configuration = config
        continueBtn.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)
        
        let bgView = UIImageView(image: bg)
        bgView.isUserInteractionEnabled = false
            bgView.translatesAutoresizingMaskIntoConstraints = false
        continueBtn.insertSubview(bgView, at: 0)
            NSLayoutConstraint.activate([
                bgView.topAnchor.constraint(equalTo: continueBtn.topAnchor),
                bgView.bottomAnchor.constraint(equalTo: continueBtn.bottomAnchor),
                bgView.leadingAnchor.constraint(equalTo: continueBtn.leadingAnchor),
                bgView.trailingAnchor.constraint(equalTo: continueBtn.trailingAnchor),
            ])

        
      
       
        [scorePill, bestLabel, circle, imageView, statusLabel, movesLabel, continueBtn].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false; view.addSubview($0)
        }
        scorePill.addSubview(scoreLabel)
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
   
        coin.translatesAutoresizingMaskIntoConstraints = false
        scorePill.addSubview(coin)
   

        let g = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            
            scorePill.topAnchor.constraint(equalTo: g.topAnchor, constant: 15),
            scorePill.centerXAnchor.constraint(equalTo: g.centerXAnchor),
             
            coin.centerYAnchor.constraint(equalTo: scorePill.centerYAnchor),
            coin.leadingAnchor.constraint(equalTo: scorePill.leadingAnchor, constant: 5),
            coin.heightAnchor.constraint(equalToConstant: 40),
            
            coin.widthAnchor.constraint(equalTo: coin.heightAnchor),
      
            
            
            scoreLabel.topAnchor.constraint(equalTo: scorePill.topAnchor, constant: 8),
            scoreLabel.bottomAnchor.constraint(equalTo: scorePill.bottomAnchor, constant: -8),
            scoreLabel.leadingAnchor.constraint(equalTo: coin.trailingAnchor, constant: 5),
            scoreLabel.trailingAnchor.constraint(lessThanOrEqualTo: scorePill.trailingAnchor, constant: -30),
         
            bestLabel.topAnchor.constraint(equalTo: scorePill.bottomAnchor, constant: 6),
            bestLabel.centerXAnchor.constraint(equalTo: scorePill.centerXAnchor),
       
            circle.centerXAnchor.constraint(equalTo: g.centerXAnchor),
            circle.topAnchor.constraint(equalTo: bestLabel.bottomAnchor, constant: 15),
            circle.widthAnchor.constraint(equalTo: g.widthAnchor, multiplier: 0.75),
            circle.heightAnchor.constraint(equalTo: circle.widthAnchor),
        
            
            imageView.centerXAnchor.constraint(equalTo: g.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: circle.centerYAnchor),
            imageView.widthAnchor.constraint(lessThanOrEqualTo: g.widthAnchor, multiplier: 0.6),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
        
          
          
            continueBtn.bottomAnchor.constraint(equalTo: g.bottomAnchor, constant: -80),
            continueBtn.centerXAnchor.constraint(equalTo: g.centerXAnchor),
            continueBtn.widthAnchor.constraint(equalToConstant: 200),
            continueBtn.heightAnchor.constraint(equalToConstant: 80),
    ])
    }
    
    private func setupColorsStrip() {
        colorsStrip.backgroundColor = UIColor(cgColor: CGColor(red: 1, green: 0.7, blue: 0.3, alpha: 1))
        colorsStrip.layer.cornerRadius = 16
        colorsStrip.layer.cornerCurve = .continuous
        
        
        colorsStrip.layer.borderWidth = 0
        colorsStrip.layer.borderColor = UIColor.white.cgColor
        colorsStrip.layer.masksToBounds = true
        
        colorsStrip.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(colorsStrip)
        
        colorsStack.axis = .horizontal
        colorsStack.alignment = .center
        colorsStack.spacing = 3
        colorsStack.translatesAutoresizingMaskIntoConstraints = false
        colorsStrip.addSubview(colorsStack)
        
        let g = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            // Centered, not full-width
            colorsStrip.centerXAnchor.constraint(equalTo: g.centerXAnchor),
            colorsStrip.bottomAnchor.constraint(equalTo: continueBtn.topAnchor, constant: -8),
            
            // Keep some margins if it grows wide
            colorsStrip.leadingAnchor.constraint(greaterThanOrEqualTo: g.leadingAnchor, constant: 20),
            colorsStrip.trailingAnchor.constraint(lessThanOrEqualTo: g.trailingAnchor, constant: -20),
            
            // Stack inside with padding; strip width follows content
            colorsStack.topAnchor.constraint(equalTo: colorsStrip.topAnchor, constant: 13),
            colorsStack.bottomAnchor.constraint(equalTo: colorsStrip.bottomAnchor, constant: -13),
            colorsStack.leadingAnchor.constraint(equalTo: colorsStrip.leadingAnchor, constant: 20),
            colorsStack.trailingAnchor.constraint(equalTo: colorsStrip.trailingAnchor, constant: -20),
            
            movesLabel.bottomAnchor.constraint(equalTo: colorsStrip.topAnchor, constant: -6),
            movesLabel.centerXAnchor.constraint(equalTo: g.centerXAnchor),
          
            
            statusLabel.bottomAnchor.constraint(equalTo: movesLabel.topAnchor, constant: -4),
            statusLabel.centerXAnchor.constraint(equalTo: g.centerXAnchor),
    
        ])
        
        // Make the pill hug its content (don’t stretch)
        colorsStrip.setContentHuggingPriority(.required, for: .horizontal)
        colorsStrip.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    private func renderColorsStrip(numColors: Int) {
        
        
        let iconSize: CGFloat = 28
        for i in 1...numColors {
            let iv = UIImageView(image: UIImage(named: "knight_\(i)"))
            iv.contentMode = .scaleAspectFit
            iv.translatesAutoresizingMaskIntoConstraints = false
            iv.widthAnchor.constraint(equalToConstant: iconSize).isActive = true
            iv.heightAnchor.constraint(equalToConstant: iconSize).isActive = true
            colorsStack.addArrangedSubview(iv)
        }
        // Update corner radius to match new height
    }
 
    func updateRadiuses() {
        colorsStrip.layoutIfNeeded()
        colorsStrip.layer.cornerRadius = colorsStrip.bounds.height / 2
        circle.layoutIfNeeded()
        circle.layer.cornerRadius = circle.bounds.height / 2
        
        scorePill.layoutIfNeeded()
        scorePill.layer.cornerRadius = scorePill.bounds.height / 2
      
   
    }
    
    
    
    
    
    
    
    
    
    
    
    
    

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        vm.saveScore { [weak self] ok in
            guard let self = self else { return }
            let s = "Score \(self.vm.totalScore)"
            self.bestLabel.text = ok ? s + " saved" : s + " not saved"
            
            
            // If server provided best for N+1, crossfade the updated preview
             let updated = self.vm.nextLevelDescription
            UIView.transition(with: self.statusLabel ,
                               duration: 0.2,
                               options: .transitionCrossDissolve,
                              animations: {
                self.statusLabel.text = updated
            })

        }
     
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    
    func bind() {
        vm.onNextLevelPreviewUpdate = { [weak self] in
            guard let self = self else { return }
            UIView.transition(with: self.statusLabel, duration: 0.2, options: .transitionCrossDissolve) {
                self.statusLabel.text = self.vm.nextLevelDescription
                self.scoreLabel.text = "\(self.vm.totalScore) / \(self.vm.bestLevelScore)"
            
            }
        }
    }

    @objc private func continueTapped() { onContinue?(vm.nextLevelBestScore) }
}


  
