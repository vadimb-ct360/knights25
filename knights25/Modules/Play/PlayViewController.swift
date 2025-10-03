//
//  PlayViewController.swift
//  knights25
//
//  Created by Vadim on 18. 9. 2025..
//

import UIKit

final class PlayViewController: BaseViewController {
    
    private let NUMROW = 5
    private let NUMDROPS = 7
    private var cellSize: CGFloat = 0
    
    private var uiLockCount = 0
    private var displayedScore: Int = 0
    private var prevScore: Int = 0  // to detect deltas from state
    private var lastLevelNum: Int = 0
    private var lastBombNum: Int?
    private var lastBonusNum: Int?
    
    let viewModel: PlayViewModel
    private var state: GameState { viewModel.state }
    
    private var pieceViews: [[KnightView?]] = []
    private let boardView = UIView()
    
    private var soundBarButton: UIBarButtonItem?
    private let bonusLabel = PaddedLabel()
    
    private let scoreLabel = UILabel()
    private let scorePill = UIView()
    private let dropsPill = UIView()
    private let clock = UIImageView(image: UIImage(named: "clock"))
    private let coin = UIImageView(image: UIImage(named: "coin"))
    private let bombButton = UIButton(type: .custom)
    private let bombLabel  = UILabel()
    private let lastColorKnight = UIButton(type: .custom)
    private let lastColorImage = UIImageView()
    private let lastColorLabel  = UILabel()
    
    
    private let movesNumberLabel = UILabel()     // numbers only
    private let dropsStack = UIStackView()
    private var dropSlots: [UIImageView] = []
    private let dropSlotSize: CGFloat = 36
    
    private var highlightOverlays: [UIView] = []     // empty-cell highlights
    private var pulsingMergeTargets: [KnightView] = [] // pulsing same-color pieces
    private var tapHighlightsTimer: Timer?
    
    
    
    private let colorsStrip = UIView()
    private let colorsStack = UIStackView()
    
    
    
    init(viewModel: PlayViewModel) { self.viewModel = viewModel; super.init(nibName: nil, bundle: nil) }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private let backgroundImageView = UIImageView()
    
    private let bgImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "board"))
        iv.contentMode = .scaleToFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = false
        setupUI()
        setupHUD()
        setupNavBarButtons()
        setupBombButton()
        setupColorsStrip()
        bindVM()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false) // ensure visible
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    
    private func setupNavBarButtons() {
        // LEFT: Best scores (use SF Symbol or your jelly asset)
        let bestItem: UIBarButtonItem
        if let img = UIImage(named: "btnBest")?.withRenderingMode(.alwaysOriginal) {
            bestItem = UIBarButtonItem(image: img, style: .plain, target: self, action: #selector(bestTapped))
        } else {
            bestItem = UIBarButtonItem(image: UIImage(systemName: "trophy.fill"),
                                       style: .plain, target: self, action: #selector(bestTapped))
        }
        bestItem.accessibilityLabel = "Escape"
        navigationItem.leftBarButtonItem = bestItem
        
        // RIGHT: Sound toggle
        let icon = viewModel.isSoundOn ? "speaker.wave.2.fill" : "speaker.slash.fill"
        let soundItem: UIBarButtonItem
        if let img = UIImage(named: viewModel.isSoundOn ? "btnSoundOn" : "btnSoundOff")?.withRenderingMode(.alwaysOriginal) {
            soundItem = UIBarButtonItem(image: img, style: .plain, target: self, action: #selector(soundTapped))
        } else {
            soundItem = UIBarButtonItem(image: UIImage(systemName: icon),
                                        style: .plain, target: self, action: #selector(soundTapped))
        }
        soundItem.accessibilityLabel = "Sound"
        navigationItem.rightBarButtonItem = soundItem
        self.soundBarButton = soundItem
        
        // Optional tint if you’re using SF Symbols:
        // navigationController?.navigationBar.tintColor = .label
    }
    
    
    @objc private func helpTapped() {
        // route via VM -> Coordinator.showHelp()
        viewModel.exitToHelp()
    }
    
    @objc private func bestTapped() {
        // route via VM -> Coordinator.showBest()
        let a = UIAlertController(title:"Escape game?", message:"View Today Best Scores And Restart Game", preferredStyle:.alert)
        a.addAction(UIAlertAction(title:"Cancel", style:.cancel))
        a.addAction(UIAlertAction(title:"OK", style:.destructive){ _ in self.viewModel.exitToBest() })
        present(a, animated:true)
    }
  
    @objc private func soundTapped() {
        viewModel.toggleSound()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemPink
        backgroundImageView.image = UIImage(named: "bg_1")
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.isUserInteractionEnabled = false
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundImageView)
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        view.addSubview(boardView)
        boardView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            boardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            boardView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            boardView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 5.0/6.0),
            boardView.heightAnchor.constraint(equalTo: boardView.widthAnchor)
        ])
        boardView.addSubview(bgImageView)
        boardView.clipsToBounds = false
        NSLayoutConstraint.activate([
            bgImageView.centerXAnchor.constraint(equalTo: boardView.centerXAnchor),
            bgImageView.centerYAnchor.constraint(equalTo: boardView.centerYAnchor),
            bgImageView.widthAnchor.constraint(equalTo: view.widthAnchor),
            bgImageView.heightAnchor.constraint(equalTo: bgImageView.widthAnchor)
        ])
    }
    
    private func scoreString(_ score: Int) -> String {
        return "\(score) / \(state.level.bestScore)"
    }
    
    private func setupHUD() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        // Top row with  Drops strip
        
        // --- SCORE PILL (white rounded rect) ---
        scorePill.backgroundColor = .brown.withAlphaComponent(0.7)
        scorePill.layer.cornerRadius = 21
        scorePill.layer.cornerCurve = .continuous
        scorePill.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scorePill)
        
        dropsPill.backgroundColor = UIColor(cgColor: CGColor(red: 1, green: 0.75, blue: 0.35, alpha: 1))
        
        dropsPill.layer.cornerRadius = 23
        dropsPill.layer.cornerCurve = .continuous
        dropsPill.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dropsPill)
        
        
        
        renderBonus(state.bonus)
        bonusLabel.textColor = .brown
        bonusLabel.layer.masksToBounds = true
        
        bonusLabel.backgroundColor = UIColor(cgColor: CGColor(red: 1, green: 0.7, blue: 0.3, alpha: 1))
        
        bonusLabel.layer.cornerRadius = 12
        
        bonusLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bonusLabel)
        
        scoreLabel.textColor = .white
        scoreLabel.text = scoreString(0)
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scorePill.addSubview(scoreLabel)
        
        coin.translatesAutoresizingMaskIntoConstraints = false
        scorePill.addSubview(coin)
        
        
        clock.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(clock)
        //    clock.alpha = 0.75
        
        
        movesNumberLabel.textColor = UIColor.brown
        movesNumberLabel.textAlignment = .center
        movesNumberLabel.text = "0:10"             // numbers only
        movesNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(movesNumberLabel)
        
        
        lastColorKnight.setImage(UIImage(named: "help"), for: .normal)
   
        lastColorKnight.addTarget(self, action: #selector(helpTapped), for: .touchUpInside)
       
        lastColorKnight.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(lastColorKnight)
        
        lastColorImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(lastColorImage)
        
        lastColorLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(lastColorLabel)
        lastColorLabel.text = ""
        lastColorLabel.textColor = UIColor.white
        lastColorLabel.textAlignment = .center
        
        
        view.bringSubviewToFront(boardView)
        
        
        
        // Drops stack (right-aligned)
        dropsStack.axis = .horizontal
        dropsStack.alignment = .center
        dropsStack.spacing = 0
        dropsStack.translatesAutoresizingMaskIntoConstraints = false
        dropsPill.addSubview(dropsStack)
        
        dropSlots.removeAll()
        for _ in 0..<5 {
            let iv = UIImageView()
            iv.contentMode = .scaleAspectFit
            iv.translatesAutoresizingMaskIntoConstraints = false
            iv.widthAnchor.constraint(equalToConstant: dropSlotSize).isActive = true
            iv.heightAnchor.constraint(equalToConstant: dropSlotSize).isActive = true
            dropSlots.append(iv)
            dropsStack.addArrangedSubview(iv)
        }
        let d6 = UIImageView()
        d6.contentMode = .scaleAspectFit
        d6.translatesAutoresizingMaskIntoConstraints = false
        dropSlots.append(d6)
        let d7 = UIImageView()
        d7.contentMode = .scaleAspectFit
        d7.translatesAutoresizingMaskIntoConstraints = false
        dropSlots.append(d7)
        view.addSubview(d6)
        view.addSubview(d7)
      
        // Layout
        let g = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            // center pill under the title
            
            scorePill.topAnchor.constraint(equalTo: g.topAnchor, constant: 8),
            scorePill.centerXAnchor.constraint(equalTo: g.centerXAnchor),
      
            coin.centerYAnchor.constraint(equalTo: scorePill.centerYAnchor),
            coin.leadingAnchor.constraint(equalTo: scorePill.leadingAnchor, constant: 5),
            coin.heightAnchor.constraint(equalToConstant: dropSlotSize+4),
            coin.widthAnchor.constraint(equalTo: coin.heightAnchor),
            
            // pill hugs content (not full width)
            scoreLabel.topAnchor.constraint(equalTo: scorePill.topAnchor, constant: 8),
            scoreLabel.bottomAnchor.constraint(equalTo: scorePill.bottomAnchor, constant: -8),
            scoreLabel.leadingAnchor.constraint(equalTo: coin.trailingAnchor, constant: 5),
            scoreLabel.trailingAnchor.constraint(equalTo: scorePill.trailingAnchor, constant: -15),
            
             
            clock.leadingAnchor.constraint(equalTo: g.leadingAnchor, constant: 2),
            clock.centerYAnchor.constraint(equalTo: dropsStack.centerYAnchor, constant: -10 ),
            clock.heightAnchor.constraint(equalTo: dropsStack.heightAnchor, multiplier: 2),
            
            clock.widthAnchor.constraint(equalTo: clock.heightAnchor),
            
            // Moves label inside with padding
            movesNumberLabel.centerXAnchor.constraint(equalTo: clock.centerXAnchor),
            movesNumberLabel.centerYAnchor.constraint(equalTo: clock.centerYAnchor),
            
        
            // Drops stack on right
            dropsStack.centerXAnchor.constraint(equalTo: g.centerXAnchor),
            dropsStack.topAnchor.constraint(equalTo: scorePill.bottomAnchor, constant: 30),
            dropsStack.heightAnchor.constraint(equalToConstant: dropSlotSize),
            
            dropsPill.centerYAnchor.constraint(equalTo: dropsStack.centerYAnchor ),
            dropsPill.leadingAnchor.constraint(equalTo: dropsStack.leadingAnchor, constant: -12 ),
            dropsPill.heightAnchor.constraint(equalTo: dropsStack.heightAnchor, multiplier: 1.4),
            dropsPill.trailingAnchor.constraint(equalTo: dropsStack.trailingAnchor, constant: 12 ),
         
            
            d6.centerYAnchor.constraint(equalTo: dropsStack.centerYAnchor),
            d6.leadingAnchor.constraint(equalTo: g.trailingAnchor, constant: dropSlotSize),
            d6.widthAnchor.constraint(equalToConstant: dropSlotSize),
            d6.heightAnchor.constraint(equalToConstant: dropSlotSize),
   
            d7.centerYAnchor.constraint(equalTo: dropsStack.centerYAnchor),
            d7.leadingAnchor.constraint(equalTo: g.trailingAnchor, constant: dropSlotSize),
            d7.widthAnchor.constraint(equalToConstant: dropSlotSize),
            d7.heightAnchor.constraint(equalToConstant: dropSlotSize),
   
           
            lastColorKnight.trailingAnchor.constraint(equalTo: g.trailingAnchor, constant: -1),
            lastColorKnight.centerYAnchor.constraint(equalTo: dropsStack.centerYAnchor, constant: -10),
            lastColorKnight.widthAnchor.constraint(equalTo: clock.widthAnchor, multiplier: 0.95),
            lastColorKnight.heightAnchor.constraint(equalTo: lastColorKnight.widthAnchor),
            
            lastColorLabel.centerXAnchor.constraint(equalTo: lastColorImage.centerXAnchor),
            lastColorLabel.centerYAnchor.constraint(equalTo: lastColorImage.centerYAnchor),
            
            lastColorImage.centerXAnchor.constraint(equalTo: lastColorKnight.centerXAnchor),
            lastColorImage.centerYAnchor.constraint(equalTo: lastColorKnight.centerYAnchor),
            lastColorImage.widthAnchor.constraint(equalTo: lastColorKnight.widthAnchor, multiplier: 0.8),
            lastColorImage.heightAnchor.constraint(equalTo: lastColorImage.widthAnchor),
            
            bonusLabel.topAnchor.constraint(equalTo: boardView.bottomAnchor, constant: 42),
            bonusLabel.trailingAnchor.constraint(equalTo: g.trailingAnchor, constant: -16),
            
          
            
        ])
        
    }
    
    
    private func setupColorsStrip() {
        colorsStrip.backgroundColor = UIColor(cgColor: CGColor(red: 1, green: 0.7, blue: 0.3, alpha: 1))
        
        colorsStrip.layer.cornerRadius = 10
        colorsStrip.layer.cornerCurve = .continuous
        colorsStrip.layer.shadowColor = UIColor.black.withAlphaComponent(0.15).cgColor
        colorsStrip.layer.shadowOpacity = 1
        colorsStrip.layer.shadowRadius = 8
        colorsStrip.layer.shadowOffset = .zero
        colorsStrip.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(colorsStrip)
        
        colorsStack.axis = .horizontal
        colorsStack.alignment = .center
        colorsStack.spacing = 0
        colorsStack.translatesAutoresizingMaskIntoConstraints = false
        colorsStrip.addSubview(colorsStack)
        
        let g = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            colorsStrip.centerYAnchor.constraint(equalTo: bonusLabel.centerYAnchor),
            
            colorsStrip.leadingAnchor.constraint(equalTo: g.leadingAnchor, constant: 12),
            
            // Stack inside with padding; strip width follows content
            colorsStack.topAnchor.constraint(equalTo: colorsStrip.topAnchor, constant: 10),
            colorsStack.bottomAnchor.constraint(equalTo: colorsStrip.bottomAnchor, constant: -10),
            colorsStack.leadingAnchor.constraint(equalTo: colorsStrip.leadingAnchor, constant: 12),
            colorsStack.trailingAnchor.constraint(equalTo: colorsStrip.trailingAnchor, constant: -12),
            
        ])
        
        // Make the pill hug its content (don’t stretch)
        colorsStrip.setContentHuggingPriority(.required, for: .horizontal)
        colorsStrip.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    private func renderColorsStrip(numColors: Int) {
        colorsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        guard numColors > 0 else { return }
        
        let iconSize: CGFloat = 19
        for i in 1...numColors {
            let iv = UIImageView(image: knightImage(i))
            iv.contentMode = .scaleAspectFill
            iv.translatesAutoresizingMaskIntoConstraints = false
            iv.widthAnchor.constraint(equalToConstant: iconSize).isActive = true
            iv.heightAnchor.constraint(equalToConstant: iconSize).isActive = true
            colorsStack.addArrangedSubview(iv)
        }
        // Update corner radius to match new height
        colorsStrip.layoutIfNeeded()
        bonusLabel.layoutIfNeeded()
        scorePill.layoutIfNeeded()
        
        colorsStrip.layer.cornerRadius = colorsStrip.bounds.height / 2
        bonusLabel.layer.cornerRadius = bonusLabel.bounds.height / 2
        scorePill.layer.cornerRadius = scorePill.bounds.height / 2
        
    }
    
    
    private func setupBombButton() {
        
        scoreLabel.font = AppFont.font(25, weight: .bold)
        bonusLabel.font = AppFont.font(21, weight: .bold)
        movesNumberLabel.font = AppFont.font(25, weight: .bold)
        lastColorLabel.font = AppFont.font(21, weight: .bold)
        bombLabel.text = ""
        bombLabel.font = AppFont.font(23, weight: .bold)
        bombLabel.textColor = .yellow
        bombLabel.textAlignment = .center
        bombLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 57x57 image-only button
        bombButton.translatesAutoresizingMaskIntoConstraints = false
        bombButton.imageView?.contentMode = .scaleAspectFit
        bombButton.accessibilityLabel = "Bomb"
        bombButton.addTarget(self, action: #selector(bombTapped), for: .touchUpInside)
        
        // In setupBombButton()
        bombButton.addTarget(self, action: #selector(bombDown), for: [.touchDown, .touchDragEnter])
        bombButton.addTarget(self, action: #selector(bombUp),   for: [.touchUpInside, .touchCancel, .touchDragExit])
        view.addSubview(bombButton)
        view.addSubview(bombLabel)
        
        NSLayoutConstraint.activate([
            // Centered above the colors strip
            bombButton.centerXAnchor.constraint(equalTo: boardView.centerXAnchor),
            bombButton.topAnchor.constraint(equalTo: boardView.bottomAnchor, constant: 75),
            bombButton.heightAnchor.constraint(equalToConstant: 72),
            bombButton.widthAnchor.constraint(equalTo: bombButton.heightAnchor, multiplier: 2.0 ),
            
            bombLabel.centerXAnchor.constraint(equalTo: bombButton.centerXAnchor, constant: -7),
            bombLabel.centerYAnchor.constraint(equalTo: bombButton.centerYAnchor),
        ])
        
    }
    
    
    
    private func bindVM() {
        viewModel.onLevelFinished = { [weak self] finish in
            guard let self = self else { return }
            
            
            let delta = state.score - self.prevScore
            if delta > 0 { self.addScore(delta) }
            self.prevScore = state.score
            renderBonus(state.bonus)
            self.renderMoves(state.remainingMoves)
            levelFinished(finish)
        }
        
        
        
        viewModel.onSoundChanged = { [weak self] isOn in
            guard let self = self else { return }
            // Update bar button icon
            if let img = UIImage(named: isOn ? "btnSoundOn" : "btnSoundOff")?.withRenderingMode(.alwaysOriginal) {
                self.soundBarButton?.image = img
            } else {
                self.soundBarButton?.image = UIImage(systemName: isOn ? "speaker.wave.2.fill" : "speaker.slash.fill")
            }
            self.soundBarButton?.accessibilityLabel = isOn ? "Sound On" : "Sound Off"
        }
        
        
        viewModel.onStateChanged = { [weak self] state in
            guard let self = self else { return }
            DispatchQueue.main.async {
                
                
                let delta = state.score - self.prevScore
                if delta > 0 {
                    self.addScore(delta)
                } else {
                    self.scoreLabel.text = self.scoreString(state.score)
                    
                }
                self.prevScore = state.score
                
                if self.lastLevelNum != state.level.num {
                    self.title = "Level \(state.level.num)"
                    self.playSound("level")
                    self.lastLevelNum = state.level.num
                    self.resetForNewLevel(using: state)
                    
                }
                
                if self.lastBombNum != state.bomb {
                    self.updateBombButton(bombs: state.bomb)
                    self.lastBombNum = state.bomb
                    self.playSound("bomb")
                }
                
                
                self.renderLastColor(state.lastColor, number: state.numLastColor)
                  
                self.renderBonus(state.bonus)
                self.renderMoves(state.remainingMoves)
                self.updateBombButton(bombs: state.bomb)
                
            }
        }
        viewModel.onDropKnight = { [weak self] target in
            guard let self = self else { return }
            self.animateDrop(index: 0, to: target)
        }
        
        viewModel.onDropTwoKnights = { [weak self] target1, target2 in
            guard let self = self else { return }
            playSound("clear")
            self.animateTwoDrops(t1: target1, t2: target2)
        }
        viewModel.onFreeMove = { [weak self] in
            guard let self = self else { return }
            self.unlockUI()
            self.render(state: state)
        }
     }
    
    
    
    func renderLastColor(_ lastColor: Int, number: Int) {
        
        
        if number>0 {
            let img = UIImage(named: "knight_\(lastColor)")?.withRenderingMode(.alwaysOriginal)
            lastColorKnight.setImage(img, for: .normal)
        
            lastColorImage.image = UIImage(named: "k_\(lastColor)")
            lastColorKnight.alpha = 0.5
            lastColorLabel.text =  "\(number)"
            lastColorImage.isHidden = false
            lastColorLabel.isHidden = false
        } else {
            let img = UIImage(named: "help")?.withRenderingMode(.alwaysOriginal)
            lastColorKnight.setImage(img, for: .normal)
       
            lastColorKnight.alpha = 1
            lastColorImage.isHidden = true
            lastColorLabel.isHidden = true
        }
    
    }
  
    func renderBonus(_ bns: Int) {
        bonusLabel.textColor = state.allowFreeMove ? .red : .black
        bonusLabel.text = "♥︎\(bns)"  //🖤♡
    }
    
    func playPink() {
        playSound("pink")
        UIView.animate(withDuration: 0.5,
                       delay: 0.0,
                       options: [.curveEaseOut],
                       animations: {
            self.backgroundImageView.alpha = 0.5
        }, completion: { _ in
            UIView.animate(withDuration: 0.3,
                           delay: 1.0,
                           options: [.curveEaseIn],
                           animations: {
                self.backgroundImageView.alpha = 1.0
            })
        }
        )
    }
    
    
    func renderMoves(_ moves: Int) {
        let m = String(format: ":%02d", moves)
        movesNumberLabel.text = m
        if moves<3 {
            if moves==1 && state.allowFreeMove {
                self.playPink()
            } else {
                playSound("alarm")
            }
            clock.image = UIImage(named: "clock_alarm")!
            movesNumberLabel.textColor = UIColor.yellow
            if moves<=1 {
                _ = dropSlots.map({$0.alpha = 0})
            }
        } else {
            clock.image = UIImage(named: "clock")!
            movesNumberLabel.textColor = UIColor(cgColor: CGColor(red: 0.99, green: 0.9, blue: 0.8, alpha: 1))
        }
        dropsPill.alpha = state.remainingMoves>1 ? 1.0 : 0
    }
    
    
    // MARK: Reset all transient UI/state for a new level
    private func resetForNewLevel(using s: GameState) {
        uiLockCount = 0
        view.isUserInteractionEnabled = true
        navigationController?.navigationBar.isUserInteractionEnabled = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        tapHighlightsTimer?.invalidate(); tapHighlightsTimer = nil
        scoreDisplayLink?.invalidate();   scoreDisplayLink   = nil
        
        clearDragHighlights()
        pulsingMergeTargets.removeAll()
        title = s.level.diablo>0 ? "Keep out upper rows" : s.level.isCleaning ? "Safety level \(s.level.num)" : "Level \(s.level.num)"
        backgroundImageView.image = UIImage(named: s.level.ground)
        
        
        renderDrops(s.level.drops)
        render(state: s)
        renderMoves(s.remainingMoves)
        
        updateBombButton(bombs: s.bomb)
        
        renderColorsStrip(numColors: s.level.numColors)
    }
    
    
    func restartGame() {
        scoreDisplayLink?.invalidate()
        displayedScore = 0
        prevScore = 0
        scoreLabel.text = self.scoreString(0)
        lastLevelNum = 0
        viewModel.start(levelNumber: 1)
        
    }
    
    
    
    private func animateDropStripShift(completion: (() -> Void)? = nil) {
        let lastDrop = NUMDROPS-1
        // Ensure slot 0 is hidden at start of the shift (it was consumed/flying)
        dropSlots[0].alpha = 0.0
        
        
        // Helper: animate slot i → slot (i-1), then recurse
        for i in 1...lastDrop {
            let from = dropSlots[i]
            let to   = dropSlots[i-1]
            let fromCenter = from.superview!.convert(from.center, to: self.view)
            let toCenter   = to.superview!.convert(to.center, to: self.view)
            let dx = toCenter.x - fromCenter.x
            
            let drop = dropSlots[i]
            UIView.animate(withDuration: 0.35,
                           delay: 0.05 * Double(i-1),
                           usingSpringWithDamping: 0.5,
                           initialSpringVelocity: 0.0,
                           animations: {
                drop.transform = CGAffineTransform(translationX: dx, y: 0)
            }, completion: { _ in
                if i<lastDrop {
                    self.playSound("click")
                } else {
                    completion?()
                }
            })
        }
    }
    
    
    private func animateDropStripDoubleShift(completion: (() -> Void)? = nil) {
        dropSlots[0].alpha = 0.0
        dropSlots[1].alpha = 0.0
        let lastDrop = NUMDROPS-1
        
        
        for i in 2...lastDrop {
            let from = dropSlots[i]
            let to   = dropSlots[i-2]
            let fromCenter = from.superview!.convert(from.center, to: self.view)
            let toCenter   = to.superview!.convert(to.center, to: self.view)
            let dx = toCenter.x - fromCenter.x
            
            let drop = dropSlots[i]
            
            UIView.animate(withDuration: 0.4,
                           delay: 0.1 * Double(i-2),
                           usingSpringWithDamping: 0.5,
                           initialSpringVelocity: 0.0,
                           animations: {
                drop.transform = CGAffineTransform(translationX: dx, y: 0)
            }, completion: { _ in
                if i<lastDrop {
                    self.playSound("click")
                } else {
                    completion?()
                }
            })
        }
    }
    
    
    func validTargetsForDrag(from src:(Int,Int)) -> (merges: [(Int,Int)], bombEmpties: [(Int,Int)]) {
        return viewModel.validTargetsForDrag(from: src)
    }
    
    
    
    // Make sure this helper returns the view so we can animate it after landing.
    @discardableResult
    private func addPieceView(id: Int, at pos: (Int,Int)) -> KnightView {
        let v = KnightView(colorId: id, index: pos)
        v.image = knightImage(id)
        v.isUserInteractionEnabled = true
        v.contentMode = .scaleToFill
        v.frame = frameForCell(pos.0, pos.1)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        pan.delegate = self
        
        let press = UILongPressGestureRecognizer(target: self, action: #selector(knightLongPressed(_:)))
        press.minimumPressDuration = 0            // touch-down
        press.allowableMovement = 12              // small wiggle still counts as press
        press.delegate = self
        
        v.addGestureRecognizer(press)
        v.addGestureRecognizer(pan)
        boardView.addSubview(v)
        
        return v
    }
    
    
    @objc private func knightLongPressed(_ gr: UILongPressGestureRecognizer) {
        guard uiLockCount == 0, let piece = gr.view as? KnightView else { return }
        
        switch gr.state {
        case .began:
            tapHighlightsTimer?.invalidate()
            clearDragHighlights()
            showDragHighlights(from: piece)
            
        case .ended, .cancelled, .failed:
            tapHighlightsTimer?.invalidate()
            clearDragHighlights()          // ✅ stop pulsing immediately on release
        default:
            break
        }
    }
    
    private func superBonus() {
        playSound("clear")
        
        var sx: CGFloat = 66
        for r in 0..<5 {
            for c in 0..<5 {
                if state.board[r][c] == 0 {
                    let f =  frameForCell(r, c)
                    
                    let bubble = BubbleView(text: "", color: 0)
                    bubble.show(from: f.center, in: boardView, size: sx, driftY: f.midY + CGFloat.random(in: 90...110.0), duration: CGFloat.random(in:2...3.0))
                    sx += 3
                    playStarBurst(at: f.center,
                                  count: 10,
                                  imageName: "star",
                                  minDistance: 300,
                                  maxDistance: 350)
                }
            }
        }
        let fb = frameForCell(5,2)
        
        let bubble = BubbleView(text: "", color: 0)
        bubble.show(from: fb.center, in: boardView, size: sx-5, driftY: fb.midY + 90, duration: 2.3)
        
        
        
    }
    
    private func animateTwoDrops(t1: (Int, Int), t2: (Int, Int)) {
        var flyers: [UIImageView] = []
        var tfs: [CGRect] = []
        
        
        unlockUI()
        for i in 0...1 {
            let d = dropSlots[i]
            let srcInSelf  = d.superview?.convert(d.frame, to: self.view) ?? .zero
            let srcInBoard = self.view.convert(srcInSelf, to: boardView)
            
            d.alpha = 0.0
            let color = state.level.drops[i]
            
            let targetFrame = i==0 ? frameForCell(t1.0, t1.1) : frameForCell(t2.0, t2.1)
            let flyer = UIImageView(image: knightImage(color))
            flyer.contentMode = .scaleAspectFit
            flyer.frame = srcInBoard
            
            flyer.layer.zPosition = CGFloat(99+i)
            boardView.addSubview(flyer)
            boardView.bringSubviewToFront(flyer)
            flyers.append(flyer)
            tfs.append(targetFrame)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.playSound("drop")
            
        }
        
        UIView.animate(withDuration: 0.51,
                       delay: 0.5,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.1,
                       options: [.curveEaseIn, .allowUserInteraction],
                       animations: {
            flyers[0].frame = tfs[0]
        }, completion: { _ in
            self.playSound("drop")
            UIView.animate(withDuration: 0.52,
                           delay: 0.0,
                           usingSpringWithDamping: 0.3,
                           initialSpringVelocity: 0.1,
                           options: [.allowUserInteraction],
                           animations: {
                flyers[1].frame = tfs[1]
            }, completion: { _ in
                flyers[0].removeFromSuperview()
                flyers[1].removeFromSuperview()
                self.playSound("bonus")
                
                // Now that the drop finished flying, shift the strip
                self.render(state: self.state)
                self.viewModel.shiftDrops()
                self.viewModel.shiftDrops()
                
                self.unlockUI()
                
                self.animateDropStripDoubleShift {
                    self.renderDrops(self.state.level.drops)
                }
                
            })
        })
        
    }
    
    
    private func animateDrop(index: Int, to target: (Int, Int)) {
        // Ensure the target cell stays hidden while we animate the flyer.
        
        unlockUI()
        let sourceView = dropSlots[index]
        
        // Convert source (drop slot) rect into boardView coords.
        let srcInSelf  = sourceView.superview?.convert(sourceView.frame, to: self.view) ?? .zero
        let srcInBoard = self.view.convert(srcInSelf, to: boardView)
        
        sourceView.alpha = 0.0
        let color = state.level.drops[index]
        
        let targetFrame = frameForCell(target.0, target.1)
        
        self.viewModel.shiftDrops()
        
        // Flyer sprite on top
        let flyer = UIImageView(image: knightImage(color))
        flyer.contentMode = .scaleAspectFit
        flyer.frame = srcInBoard
        
        flyer.layer.zPosition = 99
        boardView.addSubview(flyer)
        boardView.bringSubviewToFront(flyer)
        flyer.transform = CGAffineTransform(scaleX: 1.8, y: 1.8)
        UIView.animate(withDuration: 0.15, animations: {
            flyer.transform = .identity
        }) { _ in
            self.playSound("drop")
            
            UIView.animate(withDuration: 0.51,
                           delay: 0,
                           usingSpringWithDamping: 0.4,     // < 1.0 = bouncy
                           initialSpringVelocity: 0.0,
                           options: [ .allowUserInteraction],
                           animations: {
                flyer.frame = targetFrame
            }, completion: { _ in
                flyer.removeFromSuperview()
                
                self.render(state: self.state)
                
                self.unlockUI()
                
                self.animateDropStripShift {
                    self.renderDrops(self.state.level.drops)
                }
            })
        }
    }
    
    
    private func knightImage(_ id: Int) -> UIImage? {
        // asset names: knight_1, knight_2, ...
        UIImage(named: "knight_\(id)")?.withRenderingMode(.alwaysOriginal)
    }
    
    
    private func renderDrops(_ drops: [Int]) {
        for i in 0..<min(dropSlots.count, NUMDROPS) {
            let color = drops[i]
            let slot = dropSlots[i]
            slot.image = knightImage(color)
            slot.alpha = 1.0
            slot.transform = .identity
        }
    }
    
    
    private func render(state: GameState) {
        var knights = 0
        boardView.subviews.compactMap { $0 as? KnightView }.forEach {
            knights += 1
            $0.removeFromSuperview()
        }
        pieceViews = Array(repeating: Array(repeating: nil, count: NUMROW), count: NUMROW)
        
        for r in 0..<NUMROW {
            for c in 0..<NUMROW {
                let id = state.board[r][c]
                guard id > 0 else { continue }
                let v = addPieceView(id: id, at: (r,c))
                pieceViews[r][c] = v
            }
        }
        
        if knights==0 {
            self.boardView.subviews.compactMap { $0 as? KnightView }.forEach {
                $0.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            }
            
            UIView.animate(withDuration: 0.59,
                           delay: 0.0,
                           usingSpringWithDamping: 0.25,
                           initialSpringVelocity: 0.0,
                           animations: {
                self.boardView.subviews.compactMap { $0 as? KnightView }.forEach {
                    $0.transform = .identity
                }
            })
            
        }
    }
    
    @objc private func handlePan(_ gr: UIPanGestureRecognizer) {
        guard let piece = gr.view as? KnightView else { return }
        switch gr.state {
        case .began:
            tapHighlightsTimer?.invalidate()
            clearDragHighlights()
            piece.startCenter = piece.center
            piece.layer.zPosition = 11
            showDragHighlights(from: piece)
            
        case .changed:
            let t = gr.translation(in: boardView)
            piece.center = CGPoint(x: piece.startCenter.x + t.x, y: piece.startCenter.y + t.y)
            
        case .ended, .cancelled, .failed:
            piece.layer.zPosition = 0
            clearDragHighlights()
            
            let p = gr.location(in: boardView)
            guard let dst = indexForPoint(p) else {
                UIView.animate(withDuration: 0.22) { piece.center = piece.startCenter }
                return
            }
            
            let src = piece.index
            let color = piece.colorId
            let legal = viewModel.isValidMove(from: src, to: dst)
            
            
            if legal>0 {
                let cellCenter = frameForCell(dst.0, dst.1).center
                lockUI()
                
                UIView.animate(withDuration: 0.15,
                               animations: {
                    piece.center = cellCenter
                }, completion: { _ in
                    if legal>1 {
                        self.hideKnight(dst: dst)
                    }
                    if legal==3 {
                        piece.alpha = 0.0
                        self.playSound("shift")
                        self.playStarBurst(at: cellCenter,
                                           count: 11,
                                           imageName: "star",
                                           minDistance: 200,
                                           maxDistance: 400)
                        
                    }
                })
                
                let moveResult = viewModel.makeMove(Move(from: src, to: dst))
                let ms: CGFloat = CGFloat(70 + min(15, moveResult.0))
                let m = min(3,state.numLastColor)
                playSound("merge_\(m)")
                let bubble = BubbleView(text: String(moveResult.0), color: color)
                bubble.show(from: cellCenter, in: boardView, size: ms, driftY: cellCenter.y + CGFloat.random(in: 90...110.0), duration: CGFloat.random(in:0.5...1.0))
                if moveResult.1 > 0 {
                    superBonus()
                }
                
                playStarBurst(at: cellCenter, count: 9, imageName: "bonus")
            } else {
                UIView.animate(withDuration: 0.22) { piece.center = piece.startCenter }
            }
        default: break
        }
    }
    
    private func hideKnight(dst:(Int,Int)) {
        if let v = pieceViews[dst.0][dst.1] {
            v.alpha = 0.0
            v.removeFromSuperview()
        }
        
    }
    
    
    private func playSound(_ sound: String) {
        SFX.shared.playIfOn(sound, isOn: viewModel.isSoundOn)
    }
    
    
    private func playStarBurst(at center: CGPoint,
                               count: Int,
                               imageName: String = "star",
                               minDistance: CGFloat = 150,
                               maxDistance: CGFloat = 200,
    )
    {
        guard let star = UIImage(named: imageName) else { return }
        boardView.clipsToBounds = false  // allow flying out
        
        
        for i in 0..<count {
            // base angle evenly spaced + tiny jitter so it’s not “perfect gears”
            let angle = (CGFloat.random(in: 0...20.0) * .pi) * 0.1
            
            let distance  = CGFloat.random(in: minDistance...maxDistance)
            let d  = CGFloat(10 + i*5)
            let w  = CGFloat(40 + i*2)
            
            let dx        = cos(angle)
            let dy        = sin(angle)
            let dl = i==0 ? 1.0 : CGFloat.random(in: 50...100)*0.01
            let spin = CGFloat.random(in: -2*CGFloat.pi ... 2*CGFloat.pi)
            
            // sprite
            let pop = UIImageView(image: star)
            pop.frame = CGRect(x: 0, y: 0, width: w, height: w)
            pop.center = CGPoint(x: center.x + dx * d, y: center.y + dy * d)
            pop.alpha = 0.25
            //   iv.layer.zPosition = 2
            pop.transform = CGAffineTransformMakeScale(0.25, 0.25)
            boardView.addSubview(pop)
            
            UIView.animate(withDuration: 0.12, animations: {
                pop.alpha = 1.0
                pop.transform = .identity
            }) { _ in
                UIView.animate(withDuration: dl,
                               delay: 0.0,
                               animations: {
                    pop.transform = CGAffineTransform(translationX: dx * distance, y: dy * distance).rotated(by: spin)
                    pop.alpha = 0.75
                }, completion: { _ in
                    pop.removeFromSuperview()
                })
            }
            
            
            
            
        }
    }
    
    private func knightView(at idx: (Int, Int)) -> KnightView? {
        boardView.subviews
            .compactMap { $0 as? KnightView }
            .first { kv in
                kv.index.0 == idx.0 && kv.index.1 == idx.1
            }
    }
    
    
    private func startPulse(_ view: UIView, key: String = "pulse",
                            from: CGFloat = 0.75, to: CGFloat = 1.3,
                            duration: CFTimeInterval = 0.3) {
        let a = CABasicAnimation(keyPath: "transform.scale")
        a.fromValue = from
        a.toValue = to
        a.duration = duration
        a.autoreverses = true
        a.repeatCount = .infinity
        a.isRemovedOnCompletion = false
        view.alpha = 0.7
        
        view.layer.add(a, forKey: key)
    }
    
    private func stopPulse(_ view: UIView, key: String = "pulse") {
        view.layer.removeAnimation(forKey: key)
        view.transform = .identity
        view.alpha = 1
    }
    
    private func addEmptyCellHighlight(at idx:(Int,Int)) {
        let cell = frameForCell(idx.0, idx.1)
        let pad = cell.width * 0.10
        let h = UIView(frame: cell.insetBy(dx: pad, dy: pad))
        h.isUserInteractionEnabled = false
        h.layer.zPosition = 5
        h.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.15)
        h.layer.borderColor = UIColor.systemBrown.cgColor
        h.layer.borderWidth = 5
        h.layer.cornerRadius = 7
        boardView.addSubview(h)
        // pulse scale + opacity
        startPulse(h, to: 1.08, duration: 0.37)
        let op = CABasicAnimation(keyPath: "opacity")
        op.fromValue = 0.15; op.toValue = 0.4
        op.duration = 0.37; op.autoreverses = true
        op.repeatCount = .infinity; op.isRemovedOnCompletion = false
        h.layer.add(op, forKey: "opulse")
        highlightOverlays.append(h)
    }
    
    private func showDragHighlights(from piece: KnightView) {
        // ask VM for legal targets
        let targets = viewModel.validTargetsForDrag(from: piece.index)
        
        // empty cells → pulsing highlight view
        targets.bombEmpties.forEach { addEmptyCellHighlight(at: $0) }
        
        // same-color merges → pulse the target knight views (not the dragged one)
        targets.merges.forEach { idx in
            if let kv = knightView(at: idx), kv !== piece {
                startPulse(kv, to: 1.4, duration: 0.25)
                pulsingMergeTargets.append(kv)
            }
        }
    }
    
    private func clearDragHighlights() {
        // remove empty-cell overlays
        highlightOverlays.forEach {
            $0.layer.removeAllAnimations()
            $0.removeFromSuperview()
        }
        highlightOverlays.removeAll()
        
        // stop pulsing merge targets
        pulsingMergeTargets.forEach { stopPulse($0) }
        pulsingMergeTargets.removeAll()
    }
    
    
    func remove2rows(_ rows: Int) {
        let r1 = rows
        let c1 = NUMROW
        let s = view.frame.width/6
        let h: CGFloat = s * (3 - (CGFloat(rows)+1)/2)
        
        let ink = UIImageView(image: UIImage(named: "ink"))
        ink.bounds.size = CGSize(width: 100, height: Int(s) * rows)
        ink.center = CGPoint(x: view.frame.midX-180, y: view.frame.midY - h)
        ink.alpha = 0.65
        view.addSubview(ink)
   
        
        let brush = UIImageView(image: UIImage(named: "brush"))
        brush.bounds.size = CGSize(width: s*2.5, height: s*3.5)
        brush.center = CGPoint(x: view.frame.midX-200, y: view.frame.midY - h)
        brush.alpha = 0.9
        view.addSubview(brush)
        view.bringSubviewToFront(brush)
            
        self.playSound("sling")
        brush.transform = CGAffineTransformMakeRotation(-0.5 * .pi)
        
    UIView.animate(withDuration: 1.05,
                   delay: 0.0,
                   animations: {
        
        ink.transform = CGAffineTransform(translationX: 250, y: 0).scaledBy(x: 4, y: 1)
        brush.transform = CGAffineTransform(translationX: 500, y: 0).rotated(by: -0.5 * .pi)
        for r in 0..<r1 {
            for c in 0..<c1 {
                let id = self.state.board[r][c]
                guard id == 0 else { continue }
                if let v = self.pieceViews[r][c] {
                    print("clear knight [\(r),\(c)]")
                    v.alpha = 0.0
                    v.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
                }
            }
        }
    }, completion: { _ in
        brush.removeFromSuperview()
        ink.removeFromSuperview()
        self.viewModel.showLevelView()
        self.playSound("stolen")
    })
}
    func levelFinished(_ flag: Bool) {
        lockUI()
        _ = dropSlots.map { $0.alpha = 0.0  }
        if state.level.diablo>0 {
            remove2rows(state.level.diablo)
        } else {
            playSound("level")
            UIView.animate(withDuration: 1.2,
                           delay: 0.0,
                           animations: {
                _ = self.pieceViews.map { $0.map {$0?.alpha = 0.25 } }
            }, completion: { _ in
                self.viewModel.showLevelView()
                self.playSound("final")
            })
        }
    }
    
    // MARK: - Score animation + sound
    private var scoreDisplayLink: CADisplayLink?
    private var scoreAnimStartTime: CFTimeInterval = 0
    private var scoreAnimDuration: TimeInterval = 0.6
    private var scoreAnimFrom: Int = 0
    private var scoreAnimTo: Int = 0
    
    func addScore(_ inc: Int) {
        // Play sound
        playSound("score")
        
        // Setup number tween
        scoreAnimFrom = displayedScore
        scoreAnimTo   = displayedScore + inc
        displayedScore = scoreAnimTo   // commit the target
        
        scoreAnimStartTime = CACurrentMediaTime()
        scoreDisplayLink?.invalidate()
        scoreDisplayLink = CADisplayLink(target: self, selector: #selector(tickScoreAnim))
        scoreDisplayLink?.add(to: .main, forMode: .common)
        
        // Pop-up “+inc” near the score label
        showScorePop("+\(inc)")
    }
    
    
    
    
    @objc private func tickScoreAnim() {
        guard let link = scoreDisplayLink else { return }
        let t = (CACurrentMediaTime() - scoreAnimStartTime) / scoreAnimDuration
        if t >= 1.0 {
            scoreLabel.text = self.scoreString(scoreAnimTo)
            link.invalidate()
            scoreDisplayLink = nil
            return
        }
        // easeOutCubic
        let p = CGFloat(t)
        let eased = 1 - pow(1 - p, 3)
        let val = Int(round(CGFloat(scoreAnimFrom) + (CGFloat(scoreAnimTo - scoreAnimFrom) * eased)))
        scoreLabel.text = self.scoreString(val)
    }
    
    private func showScorePop(_ text: String) {
        // Position a small label above the scoreLabel, animate up & fade
        let pop = UILabel()
        pop.text = text
        pop.font = .boldSystemFont(ofSize: 16)
        pop.textColor = UIColor.systemGreen
        pop.alpha = 0.0
        
        // Place it in the same coordinate space as scoreLabel
        pop.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pop)
        
        // Anchor pop's center to scoreLabel's center (convert to view)
        let centerX = pop.centerXAnchor.constraint(equalTo: scoreLabel.centerXAnchor)
        let centerY = pop.centerYAnchor.constraint(equalTo: scoreLabel.centerYAnchor, constant: -4)
        NSLayoutConstraint.activate([centerX, centerY])
        
        view.layoutIfNeeded()
        // start slightly below and small
        pop.transform = CGAffineTransform(translationX: 0, y: 8).scaledBy(x: 0.9, y: 0.9)
        
        UIView.animate(withDuration: 0.18, animations: {
            pop.alpha = 1.0
            pop.transform = .identity
        }) { _ in
            UIView.animate(withDuration: 0.45,
                           delay: 0.0,
                           usingSpringWithDamping: 0.9,
                           initialSpringVelocity: 0.3,
                           animations: {
                pop.transform = CGAffineTransform(translationX: 0, y: -18)
                pop.alpha = 0.0
            }, completion: { _ in
                pop.removeFromSuperview()
            })
        }
    }
    
    
    // MARK: - Helpers
    private func frameForCell(_ r: Int, _ c: Int) -> CGRect {
        let pad: CGFloat = 0.9
        let s = cellSize > 0 ? cellSize : (boardView.bounds.width / CGFloat(NUMROW))
        
        return CGRect(x: 2 + CGFloat(c) * s, y: CGFloat(r) * s, width: s*pad, height: s*pad)
    }
    
    private func indexForPoint(_ p: CGPoint) -> (r:Int,c:Int)? {
        guard boardView.bounds.contains(p) else { return nil }
        let s = cellSize > 0 ? cellSize : (boardView.bounds.width / CGFloat(NUMROW))
        let c = Int(floor(p.x / s))
        let r = Int(floor(p.y / s))
        guard (0..<NUMROW).contains(r), (0..<NUMROW).contains(c) else { return nil }
        return (r,c)
    }
    
    private func lockUI() {
        uiLockCount += 1
        view.isUserInteractionEnabled = false
        navigationController?.navigationBar.isUserInteractionEnabled = false
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    private func finishGame() {
        self.playSound("end")
        self.lockUI()
        
        UIView.animate(withDuration: 1.5,
                       delay: 0.0,
                       animations: {
            _ = self.pieceViews.map { $0.map {$0?.alpha = 0.0 } }
            _ = self.dropSlots.map { $0.alpha = 0.0  }
        }, completion: { _ in
            self.playSound("level")
            self.viewModel.showFinalView()
        })
        
        
        
    }
    
    
    private func unlockUI() {
        if viewModel.state.status == .gameOver {
            return
        }
        if viewModel.checkEnd() {
            finishGame()
            return
        }
        uiLockCount = max(0, uiLockCount - 1)
        guard uiLockCount == 0 else { return }
        view.isUserInteractionEnabled = true
        navigationController?.navigationBar.isUserInteractionEnabled = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    
    @objc private func bombDown() {
        UIView.animate(withDuration: 0.08) {
            self.bombButton.alpha = 0.8
            self.bombButton.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        }
    }
    
    @objc private func bombUp() {
        UIView.animate(withDuration: 0.12) {
            self.bombButton.alpha = 1.0
            self.bombButton.transform = .identity
        }
    }
    
    private func showBrush() {
        viewModel.bombTapped()
        lockUI()
        let h = view.frame.height
        
        let brush = UIImageView(image: UIImage(named: "brush"))
        //     brush.contentMode = .scaleAspectFill
        brush.bounds.size = CGSize(width: view.frame.width, height: view.frame.width + 110)
        brush.center = CGPoint(x: view.frame.midX, y: view.frame.midY - h)
        brush.alpha = 0.9
        brush.layer.zPosition = 2
        view.addSubview(brush)
        view.bringSubviewToFront(brush)
        self.playSound("sling")
        UIView.animate(withDuration: 1.2,
                       delay: 0.0,
                       usingSpringWithDamping: 0.9,
                       initialSpringVelocity: 0.0,
                       animations: {
            
            brush.transform = CGAffineTransform(translationX: 0, y: h+90)
            _ = self.pieceViews.map { $0.map {$0?.transform = CGAffineTransform(translationX: 0, y: 5) } }
        }) { _ in
            self.playSound("clear")
            self.render(state: self.state)
            _ = self.pieceViews.map { $0.map {$0?.transform = CGAffineTransform(translationX: 0, y: 5) } }
            
            UIView.animate(withDuration: 0.9,
                           delay: 0.0,
                           usingSpringWithDamping: 0.2,
                           initialSpringVelocity: 0.2,
                           animations: {
                brush.transform = CGAffineTransform(translationX: 0, y: h+420)
                _ = self.pieceViews.map { $0.map {$0?.transform = .identity } }
                
            }) { _ in
                brush.removeFromSuperview()
                self.unlockUI()
            }
        }
    }
    
    @objc private func bombTapped() {
        let bombs = viewModel.state.bomb
        if bombs > 0 {
            showBrush()
        } else {
            showNoBombInfo()
        }
    }
    
    private func updateBombButton(bombs: Int) {
        let hasBomb = bombs > 0
        let img = UIImage(named: hasBomb ? "bomb" : "nobomb")?.withRenderingMode(.alwaysOriginal)
        bombButton.setImage(img, for: .normal)
        bombLabel.text = bombs>2 ? "★\(bombs)" : bombs>1 ? "★★" : bombs>0 ? "★" : ""  //⭐
        bombButton.accessibilityValue = hasBomb ? "Available" : "Unavailable"
    }
    
    private func showNoBombInfo() {
        let msg =
        """
        You don’t have any bombs yet.
        
        How to earn 1 bomb:
        • Pass Bonus Bomb level
        • Clear all knights of any single color from the board
        """
        
        let alert = UIAlertController(title: "No Bombs 🚀", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        // gentle notice haptic
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
        
        present(alert, animated: true)
    }
    
    
}

private extension CGRect {
    var center: CGPoint { CGPoint(x: midX, y: midY) }
}

extension PlayViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ g: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer) -> Bool {
        guard g.view === other.view, g.view is KnightView else { return false }
        // Allow pan + long-press on the same knight
        let a = (g is UILongPressGestureRecognizer && other is UIPanGestureRecognizer)
        let b = (g is UIPanGestureRecognizer && other is UILongPressGestureRecognizer)
        return a || b
    }
}

