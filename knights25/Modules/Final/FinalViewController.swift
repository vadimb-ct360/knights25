//
//  FinalViewController.swift
//  knights25
//
//  Created by Vadim on 18. 9. 2025..
//

// Modules/Final/FinalViewController.swift
import UIKit

final class FinalViewController: BaseViewController {
    private let vm: FinalViewModel
    var onBest: ((String?) -> Void)?     // passes userId to coordinator
    
    private let titleLabel = UILabel()
    private let scoreLabel = UILabel()
    private let levelLabel = UILabel()
    private let bonusLabel = UILabel()
    private let statusLabel = UILabel()
    private let nameLabel = PaddedLabel()

    private let continueBtn = UIButton(type: .system)
    private let imageView  = UIImageView()
    private let bg = UIImageView()
    private let coin = UIImageView(image: UIImage(named: "coin"))
    private let arc = ArcStarRatingView()

    init(viewModel: FinalViewModel) { self.vm = viewModel; super.init(nibName: nil, bundle: nil) }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadBG()
        loadUI()
        loadRate()
        updateRadiuses()
        bind()
    }
    
    func updateRadiuses() {
   //     circle.layoutIfNeeded()
   //     circle.layer.cornerRadius = circle.bounds.height / 2
    }
    
    func loadUI() {
        
        // Labels (Apple system fonts only)
        titleLabel.text = "Thanks for playing!"
        titleLabel.font = AppFont.font(25, weight: .semibold)
        titleLabel.textAlignment = .center
        
        scoreLabel.text = "Total: \(vm.summary.totalScore) / \(vm.sMax)"
        scoreLabel.font = AppFont.font(23, weight: .semibold)
        scoreLabel.textAlignment = .center
        levelLabel.textColor = vm.summary.totalScore >= vm.sMax ? .red : .secondaryLabel
        
        
        
        levelLabel.text = "Levels cleared: \(vm.summary.levelsCleared) /  \(vm.lMax)"
        levelLabel.font = AppFont.font(21, weight: .semibold)
        levelLabel.textAlignment = .center
        levelLabel.textColor = vm.summary.levelsCleared >= vm.lMax ? .red : .secondaryLabel
        
        bonusLabel.text = "Bonuses: \(vm.summary.bonus) /  \(vm.bMax)"
        
        bonusLabel.font = AppFont.font(21, weight: .semibold)
        bonusLabel.textAlignment = .center
        bonusLabel.textColor = vm.summary.bonus >= vm.bMax ? .red : .secondaryLabel
      
        
        let raw = UIImage(named: "button_2")!
        let bg  = raw.resizableImage(withCapInsets: UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2),
                                     resizingMode: .stretch)
        
        var config = UIButton.Configuration.plain()
        config.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)
        
        config.attributedTitle = AttributedString("Continue",
                                                  attributes: .init([.font: AppFont.font(21, weight: .bold),
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
        
        imageView.contentMode = .scaleAspectFit
         
        statusLabel.text = "Saving score…"
        statusLabel.font = AppFont.font(17, weight: .regular)
        statusLabel.textColor = .tertiaryLabel
        statusLabel.textAlignment = .center
        
        nameLabel.textColor = .brown
        nameLabel.text = "You play chess like\n\(vm.title)"
        nameLabel.numberOfLines = 0
        nameLabel.font = AppFont.font(23, weight: .semibold)
        nameLabel.layer.masksToBounds = true

        nameLabel.backgroundColor = .white.withAlphaComponent(0.7)
        nameLabel.layer.cornerRadius = 23
        nameLabel.textAlignment = .center
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
      
        
        [titleLabel, coin, scoreLabel, levelLabel, bonusLabel, imageView, nameLabel, continueBtn, statusLabel ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        let g = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: g.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: g.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: g.trailingAnchor, constant: -20),
            
            scoreLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            scoreLabel.centerXAnchor.constraint(equalTo: g.centerXAnchor, constant: 12),
            
            coin.centerYAnchor.constraint(equalTo: scoreLabel.centerYAnchor),
            coin.trailingAnchor.constraint(equalTo: scoreLabel.leadingAnchor, constant: -5),
            coin.heightAnchor.constraint(equalToConstant: 32),
            coin.widthAnchor.constraint(equalTo: coin.heightAnchor),
            
            
            levelLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 8),
            levelLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            levelLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            bonusLabel.topAnchor.constraint(equalTo: levelLabel.bottomAnchor, constant: 8),
            bonusLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            bonusLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
        
            
            imageView.centerXAnchor.constraint(equalTo: g.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: g.centerYAnchor),
            imageView.widthAnchor.constraint(lessThanOrEqualTo: g.widthAnchor, multiplier: 0.6),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
        
            
            continueBtn.bottomAnchor.constraint(equalTo: g.bottomAnchor, constant: -66),
            continueBtn.centerXAnchor.constraint(equalTo: g.centerXAnchor),
            continueBtn.widthAnchor.constraint(equalToConstant: 200),
            continueBtn.heightAnchor.constraint(equalToConstant: 80),
            
            statusLabel.topAnchor.constraint(equalTo: continueBtn.bottomAnchor, constant: 8),
            statusLabel.centerXAnchor.constraint(equalTo: g.centerXAnchor),
         
        ])
    }
    
    func loadRate() {
        
        arc.translatesAutoresizingMaskIntoConstraints = false
        arc.configure(rate: 2, maxRate: 10, starSize: CGSize(width: 40, height: 40))
     
        
        view.addSubview(arc)
        
        NSLayoutConstraint.activate([
            arc.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            arc.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -140 ),
            arc.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            arc.heightAnchor.constraint(equalTo: arc.widthAnchor),
        
   ])
    }
    
    private func loadBG() {
        title = "Game Over"
        navigationItem.hidesBackButton = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        view.backgroundColor = .systemBackground
        
        bg.image = UIImage(named: "bg_0")
        
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
    
    
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    
    func bind() {
        vm.onScoreSaved = { [weak self] in
            guard let self = self else { return }
            UIView.transition(with: self.statusLabel, duration: 0.2, options: .transitionCrossDissolve) {
                let n = self.vm.rate
                self.setRating(n)
                self.statusLabel.text = "Score saved to www.bashurov.net"
                self.imageView.image = UIImage(named: "rate_\(n)")
         
            }
        }
    }
    
    func setRating(_ r: Int) {
        arc.rate = r
        // tiny bounce on the last changed star
        let idx = max(0, min(r - 1, arc.maxRate - 1))
        let star = arc.subviews.compactMap { $0 as? UIImageView }[idx]
        let spring = UISpringTimingParameters(dampingRatio: 0.55, initialVelocity: .zero)
        let animator = UIViewPropertyAnimator(duration: 0.75, timingParameters: spring)
        animator.addAnimations { star.transform = CGAffineTransform(scaleX: 1.15, y: 1.15) }
        animator.addCompletion { _ in UIView.animate(withDuration: 0.32) { star.transform = .identity } }
        animator.startAnimation()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        vm.saveScore { [weak self] ok in
            guard let self = self else { return }
            self.statusLabel.text = "Score saved to www.bashurov.net"
       
        }
    }

    
    
    @objc private func continueTapped() {
        onBest?(vm.userId)
    }
}
