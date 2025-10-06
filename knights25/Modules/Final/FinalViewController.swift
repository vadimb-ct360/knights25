//
//  FinalViewController.swift
//  knights25
//
//  Created by Vadim on 18. 9. 2025..
//

// Modules/Final/FinalViewController.swift
import UIKit
import AVFoundation

final class FinalViewController: BaseViewController {
    private var queuePlayer: AVQueuePlayer?
    private var looper: AVPlayerLooper?
    private let vm: FinalViewModel
    var onBest: ((String?) -> Void)?     // passes userId to coordinator
  
    private let titleLabel = UILabel()
    
    private let scoreLabelL = UILabel()
    private let levelLabelL = UILabel()
    private let bonusLabelL = UILabel()
    
    private let scoreLabelR = UILabel()
    private let levelLabelR = UILabel()
    private let bonusLabelR = UILabel()
    

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
        if isSoundOn {
             startGaplessLoop()
        }
  
        loadBG()
        loadUI()
        loadRate()
        updateRadiuses()
        bind()
    }
    
    
    override func soundSettingDidChange(isOn: Bool) {
         // start/stop music or mute SFX for this screen
        if isOn {
            startGaplessLoop()
        } else {
            stopGapless()
        }
    }

    
    func updateRadiuses() {
        nameLabel.layoutIfNeeded()
        nameLabel.layer.cornerRadius = nameLabel.bounds.height / 2
    }
    
    func loadUI() {
        
        // Labels (Apple system fonts only)
        titleLabel.text = "Thanks for playing!"
        titleLabel.font = AppFont.font(25, weight: .semibold)
        titleLabel.textAlignment = .center
        
        scoreLabelL.text = "Total :"
        let m = String(format: "%05d", vm.summary.totalScore)
        scoreLabelR.text = "\(m)/\(vm.sMax)"
        scoreLabelL.font = AppFont.font(23, weight: .semibold)
        scoreLabelL.textAlignment = .right
        scoreLabelR.font = AppFont.font(23, weight: .semibold)
        scoreLabelR.textAlignment = .left
    
        
        
        levelLabelL.textColor = vm.summary.totalScore >= vm.sMax ? .red : .secondaryLabel
         levelLabelL.text = "Levels cleared :"
        levelLabelL.font = AppFont.font(21, weight: .semibold)
        levelLabelL.textAlignment = .right
        levelLabelL.textColor = vm.summary.levelsCleared >= vm.lMax ? .red : .secondaryLabel
 
        levelLabelR.textColor = vm.summary.totalScore >= vm.sMax ? .red : .secondaryLabel
        
        let m2 = String(format: "%02d", vm.summary.levelsCleared)
  
        levelLabelR.text = "\(m2)/\(vm.lMax)"
        levelLabelR.font = AppFont.font(21, weight: .semibold)
        levelLabelR.textAlignment = .left
        levelLabelR.textColor = vm.summary.levelsCleared >= vm.lMax ? .red : .secondaryLabel
 
        
        
        bonusLabelL.text = "Bonuses :"
        bonusLabelL.font = AppFont.font(21, weight: .semibold)
        bonusLabelL.textAlignment = .center
        bonusLabelL.textColor = vm.summary.bonus >= vm.bMax ? .red : .secondaryLabel
        
        let m3 = String(format: "%03d", vm.summary.bonus)

        bonusLabelR.text = "\(m3)/\(vm.bMax)"
        
        bonusLabelR.font = AppFont.font(21, weight: .semibold)
        bonusLabelR.textAlignment = .center
        bonusLabelR.textColor = vm.summary.bonus >= vm.bMax ? .red : .secondaryLabel
      
        
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
      
        
        [titleLabel, coin, scoreLabelL, levelLabelL, bonusLabelL, scoreLabelR, levelLabelR, bonusLabelR, imageView, nameLabel, continueBtn, statusLabel ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        let g = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: g.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: g.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: g.trailingAnchor, constant: -20),
            
            scoreLabelL.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            scoreLabelL.trailingAnchor.constraint(equalTo: g.centerXAnchor),
         
            scoreLabelR.centerYAnchor.constraint(equalTo: scoreLabelL.centerYAnchor),
            scoreLabelR.leadingAnchor.constraint(equalTo: g.centerXAnchor, constant: 10),
 
            
            
            
            coin.centerYAnchor.constraint(equalTo: scoreLabelL.centerYAnchor),
            coin.trailingAnchor.constraint(equalTo: scoreLabelL.leadingAnchor, constant: -5),
            coin.heightAnchor.constraint(equalToConstant: 32),
            coin.widthAnchor.constraint(equalTo: coin.heightAnchor),
            
            
            levelLabelL.topAnchor.constraint(equalTo: scoreLabelL.bottomAnchor, constant: 8),
            levelLabelL.leadingAnchor.constraint(lessThanOrEqualTo: scoreLabelL.leadingAnchor),
            levelLabelL.trailingAnchor.constraint(equalTo: scoreLabelL.trailingAnchor),
     
            levelLabelR.centerYAnchor.constraint(equalTo: levelLabelL.centerYAnchor),
            levelLabelR.leadingAnchor.constraint(equalTo: g.centerXAnchor, constant: 10),
 
            
            
            bonusLabelL.topAnchor.constraint(equalTo: levelLabelL.bottomAnchor, constant: 8),
            bonusLabelL.trailingAnchor.constraint(equalTo: scoreLabelL.trailingAnchor),
        
            bonusLabelR.centerYAnchor.constraint(equalTo: bonusLabelL.centerYAnchor),
            bonusLabelR.leadingAnchor.constraint(equalTo: g.centerXAnchor, constant: 10),
 
            imageView.topAnchor.constraint(equalTo: bonusLabelL.bottomAnchor, constant: 60 ),
         imageView.centerXAnchor.constraint(equalTo: g.centerXAnchor),
            imageView.widthAnchor.constraint(equalTo: g.widthAnchor, multiplier: 0.6),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 22),
            nameLabel.leadingAnchor.constraint(greaterThanOrEqualTo: g.leadingAnchor, constant: 80),
            nameLabel.trailingAnchor.constraint(greaterThanOrEqualTo: g.trailingAnchor, constant: 80),
            nameLabel.centerXAnchor.constraint(equalTo: g.centerXAnchor),
        
            
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
            arc.topAnchor.constraint(equalTo: bonusLabelL.bottomAnchor, constant: 30 ),
            arc.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
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
        stopGapless()
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
    
    
    
    private func startGaplessLoop() {
        guard isSoundOn else {
            return
        }
        let url = Bundle.main.url(forResource: "level2", withExtension: "caf", subdirectory: "Resources/Sound")
            ?? Bundle.main.url(forResource: "level2", withExtension: "caf")
        guard let url else { print("level2.caf not found"); return }

        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch { print(error) }

        let item = AVPlayerItem(url: url)
        let player = AVQueuePlayer()
        self.queuePlayer = player
        self.looper = AVPlayerLooper(player: player, templateItem: item) // infinite
        player.play()
    }

    private func stopGapless() {
        looper?.disableLooping()
        queuePlayer?.pause()
        queuePlayer = nil
        looper = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

}
