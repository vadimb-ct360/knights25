import UIKit
final class AppCoordinator {
    private let window: UIWindow
    private let gameService: GameService
    private var nav: UINavigationController?
    
    init(window: UIWindow, gameService: GameService) {
        self.window = window
        self.gameService = gameService
    }
    
    
    func start() {
        SFX.shared.preload()
        print("AppCoordinator. started with Audio support")
        
        let vm = PlayViewModel(gameService: gameService)
        let vc = PlayViewController(viewModel: vm)
        // Start set
        
        bindVM(vm)
        vm.start(levelNumber: 1)
        
        
         
        let nav = UINavigationController(rootViewController: vc)
        self.nav = nav
        window.rootViewController = nav
        window.makeKeyAndVisible()
    }
    
    
    func bindVM(_ vm: PlayViewModel) {
        
        
        vm.onShowBest = { [weak self] in
            let uid = UserDefaults.standard.string(forKey: "userId")
            self?.showBest(userId: uid)
        }
        
        vm.onShowHelp = { [weak self]  in
             self?.showHelp()
        }
        
        vm.onShowLevelView = { [weak self] level, totalScore in
            guard let self = self else { return }
            let userId  = UserDefaults.standard.string(forKey: "userId")
            let levelVM = LevelViewModel(level: level, totalScore: totalScore, bestLevelScore: level.bestScore, userId: userId )
            let levelVC = LevelViewController(viewModel: levelVM)
            levelVC.onContinue = { [weak vm, weak self] best in
                vm?.nextLevel(best)
                self?.nav?.popViewController(animated: true) // back to Play
            }
            nav?.pushViewController(levelVC, animated: true)
        }
        
        vm.onShowFinalView = { [weak self] summary in
            guard let self = self else { return }
            let userId = UserDefaults.standard.string(forKey: "userId")
            let finalVM = FinalViewModel(summary: summary, userId: userId)
            let finalVC = FinalViewController(viewModel: finalVM )
            finalVC.onBest = { [weak self] userId in
                self?.showBest(userId: userId)
            }
            
            nav?.pushViewController(finalVC, animated: true)
        }
    }
    
    func showBest(userId: String?) {
        let vm = BestViewModel(userId: userId)
        let vc = BestViewController(viewModel: vm)
        vc.onExitToPlay = { [weak self] in
            self?.restartPlay()
        }
        nav?.pushViewController(vc, animated: true)
    }
    
    func showHelp() {
        let vm = HelpViewModel()
        let vc = HelpViewController(viewModel: vm)
        nav?.pushViewController(vc, animated: true)
    }
    
    private func restartPlay() {
        // If PlayVC already on the stack, reset it; otherwise recreate it.
        if let play = nav?.viewControllers.first(where: { $0 is PlayViewController }) as? PlayViewController {
            play.restartGame()
            _ = nav?.popToViewController(play, animated: true)
        } else {
            // Fallback: recreate Play
            let playVM = PlayViewModel(gameService: gameService)
            let playVC = PlayViewController(viewModel: playVM)
            nav?.setViewControllers([playVC], animated: true)
            playVC.restartGame()
        }
    }
}
