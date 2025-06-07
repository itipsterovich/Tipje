import Foundation
import Combine

@MainActor
class Store: ObservableObject {
    @Published var userId: String = ""
    @Published var selectedKid: Kid? = nil
    @Published var kids: [Kid] = []
    @Published var rules: [Rule] = []
    @Published var chores: [Chore] = []
    @Published var rewards: [Reward] = []
    @Published var rewardPurchases: [RewardPurchase] = []
    @Published var transactions: [Transaction] = []
    @Published var balance: Int = 0
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private var cancellables = Set<AnyCancellable>()

    init() {}

    func setUser(userId: String) {
        self.userId = userId
        fetchKids()
    }

    func selectKid(_ kid: Kid) {
        print("[DEBUG] selectKid: Selecting kid with id=\(kid.id), name=\(kid.name)")
        self.selectedKid = kid
        fetchAllDataForSelectedKid()
    }

    func fetchKids() {
        guard !userId.isEmpty else { return }
        isLoading = true
        FirestoreManager.shared.fetchKids(userId: userId) { [weak self] kids in
            Task { @MainActor in
                self?.kids = kids
                self?.isLoading = false
                if let firstKid = kids.first {
                    self?.selectKid(firstKid)
                }
            }
        }
    }

    func fetchAllDataForSelectedKid() {
        guard let kid = selectedKid else {
            print("[DEBUG] fetchAllDataForSelectedKid: No kid selected!")
            return
        }
        print("[DEBUG] fetchAllDataForSelectedKid: Loading data for kid id=\(kid.id), name=\(kid.name)")
        isLoading = true
        let group = DispatchGroup()
        var rules: [Rule] = []
        var chores: [Chore] = []
        var rewards: [Reward] = []
        var purchases: [RewardPurchase] = []
        var txns: [Transaction] = []
        var balance: Int = 0
        group.enter()
        FirestoreManager.shared.fetchRules(userId: userId, kidId: kid.id) { fetched in
            rules = fetched
            group.leave()
        }
        group.enter()
        FirestoreManager.shared.fetchChores(userId: userId, kidId: kid.id) { fetched in
            chores = fetched
            group.leave()
        }
        group.enter()
        FirestoreManager.shared.fetchRewards(userId: userId, kidId: kid.id) { fetched in
            rewards = fetched
            group.leave()
        }
        group.enter()
        FirestoreManager.shared.fetchRewardPurchases(userId: userId, kidId: kid.id) { fetched in
            purchases = fetched
            group.leave()
        }
        group.enter()
        FirestoreManager.shared.fetchTransactions(userId: userId, kidId: kid.id) { fetched in
            txns = fetched
            group.leave()
        }
        group.enter()
        FirestoreManager.shared.fetchKid(userId: userId, kidId: kid.id) { fetchedKid in
            balance = fetchedKid?.balance ?? 0
            group.leave()
        }
        group.notify(queue: .main) { [weak self] in
            self?.rules = rules
            self?.chores = chores
            self?.rewards = rewards
            self?.rewardPurchases = purchases
            self?.transactions = txns
            self?.balance = balance
            self?.isLoading = false
            print("[DEBUG] fetchAllDataForSelectedKid: Finished loading for kid id=\(kid.id), rules count=\(rules.count)")
        }
    }

    // MARK: - CRUD for Rules
    func addRule(_ rule: Rule) {
        guard let kid = selectedKid else {
            print("[DEBUG] addRule: No kid selected! Rule id=\(rule.id)")
            return
        }
        print("[DEBUG] addRule: Adding rule id=\(rule.id), title=\(rule.title) for kid id=\(kid.id), name=\(kid.name)")
        isLoading = true
        FirestoreManager.shared.addRule(userId: userId, kidId: kid.id, rule: rule) { [weak self] error in
            Task { @MainActor in
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    print("[DEBUG] addRule: Error adding rule id=\(rule.id): \(error.localizedDescription)")
                } else {
                    print("[DEBUG] addRule: Successfully added rule id=\(rule.id) for kid id=\(kid.id)")
                    self?.fetchAllDataForSelectedKid()
                }
            }
        }
    }
    func archiveRule(_ rule: Rule) {
        var archived = rule
        archived.isActive = false
        addRule(archived)
    }
    // MARK: - CRUD for Chores
    func addChore(_ chore: Chore) {
        guard let kid = selectedKid else { return }
        isLoading = true
        FirestoreManager.shared.addChore(userId: userId, kidId: kid.id, chore: chore) { [weak self] error in
            Task { @MainActor in
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.fetchAllDataForSelectedKid()
                }
            }
        }
    }
    func archiveChore(_ chore: Chore) {
        var archived = chore
        archived.isActive = false
        addChore(archived)
    }
    // MARK: - CRUD for Rewards
    func addReward(_ reward: Reward) {
        guard let kid = selectedKid else { return }
        isLoading = true
        FirestoreManager.shared.addReward(userId: userId, kidId: kid.id, reward: reward) { [weak self] error in
            Task { @MainActor in
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.fetchAllDataForSelectedKid()
                }
            }
        }
    }
    func archiveReward(_ reward: Reward) {
        var archived = reward
        archived.isActive = false
        addReward(archived)
    }
    // MARK: - Complete Rule/Chore
    func completeRule(_ rule: Rule) {
        guard let kid = selectedKid else { return }
        var updated = rule
        updated.completions.append(Date())
        let txn = Transaction(id: UUID().uuidString, type: "EARN_RULE", refId: rule.id, amount: rule.peanutValue, timestamp: Date(), note: "Completed rule: \(rule.id)")
        FirestoreManager.shared.updateBalanceAndLog(userId: userId, kidId: kid.id, delta: rule.peanutValue, txn: txn) { [weak self] error in
            if error == nil {
                self?.addRule(updated)
            } else {
                self?.errorMessage = error?.localizedDescription
            }
        }
    }
    func uncompleteRule(_ rule: Rule) {
        guard let kid = selectedKid else { return }
        var updated = rule
        if let last = updated.completions.last, Calendar.current.isDateInToday(last) {
            updated.completions.removeLast()
            let txn = Transaction(id: UUID().uuidString, type: "UNCOMPLETE_RULE", refId: rule.id, amount: -rule.peanutValue, timestamp: Date(), note: "Uncompleted rule: \(rule.id)")
            FirestoreManager.shared.updateBalanceAndLog(userId: userId, kidId: kid.id, delta: -rule.peanutValue, txn: txn) { [weak self] error in
                if error == nil {
                    self?.addRule(updated)
                } else {
                    self?.errorMessage = error?.localizedDescription
                }
            }
        }
    }
    func completeChore(_ chore: Chore) {
        guard let kid = selectedKid else { return }
        var updated = chore
        updated.completions.append(Date())
        let txn = Transaction(id: UUID().uuidString, type: "EARN_CHORE", refId: chore.id, amount: chore.peanutValue, timestamp: Date(), note: "Completed chore: \(chore.id)")
        FirestoreManager.shared.updateBalanceAndLog(userId: userId, kidId: kid.id, delta: chore.peanutValue, txn: txn) { [weak self] error in
            if error == nil {
                self?.addChore(updated)
            } else {
                self?.errorMessage = error?.localizedDescription
            }
        }
    }
    func uncompleteChore(_ chore: Chore) {
        guard let kid = selectedKid else { return }
        var updated = chore
        if let last = updated.completions.last, Calendar.current.isDateInToday(last) {
            updated.completions.removeLast()
            let txn = Transaction(id: UUID().uuidString, type: "UNCOMPLETE_CHORE", refId: chore.id, amount: -chore.peanutValue, timestamp: Date(), note: "Uncompleted chore: \(chore.id)")
            FirestoreManager.shared.updateBalanceAndLog(userId: userId, kidId: kid.id, delta: -chore.peanutValue, txn: txn) { [weak self] error in
                if error == nil {
                    self?.addChore(updated)
                } else {
                    self?.errorMessage = error?.localizedDescription
                }
            }
        }
    }
    // MARK: - Purchase Reward
    func purchaseReward(_ reward: Reward) {
        guard let kid = selectedKid, balance >= reward.cost else { return }
        let purchaseId = UUID().uuidString
        let rewardRef = FirestoreManager.shared.rewardRef(userId: userId, kidId: kid.id, rewardId: reward.id)
        let purchase = RewardPurchase(id: purchaseId, rewardRef: rewardRef, status: "IN_BASKET", purchasedAt: Date(), givenAt: nil)
        let txn = Transaction(id: UUID().uuidString, type: "SPEND_REWARD", refId: purchaseId, amount: -reward.cost, timestamp: Date(), note: "Purchased reward: \(reward.title)")
        FirestoreManager.shared.updateBalanceAndLog(userId: userId, kidId: kid.id, delta: -reward.cost, txn: txn) { [weak self] error in
            if error == nil {
                FirestoreManager.shared.addRewardPurchase(userId: self?.userId ?? "", kidId: kid.id, purchase: purchase) { err in
                    if err == nil {
                        self?.fetchAllDataForSelectedKid()
                    } else {
                        self?.errorMessage = err?.localizedDescription
                    }
                }
            } else {
                self?.errorMessage = error?.localizedDescription
            }
        }
    }
    // MARK: - Confirm Reward Given
    func confirmRewardGiven(_ purchase: RewardPurchase) {
        guard let kid = selectedKid else { return }
        var updated = purchase
        updated.status = "GIVEN"
        updated.givenAt = Date()
        FirestoreManager.shared.addRewardPurchase(userId: userId, kidId: kid.id, purchase: updated) { [weak self] error in
            if error == nil {
                self?.fetchAllDataForSelectedKid()
            } else {
                self?.errorMessage = error?.localizedDescription
            }
        }
    }
    // MARK: - Delete Kid (Cascade)
    func deleteKid(_ kid: Kid, completion: @escaping (Bool) -> Void) {
        FirestoreManager.shared.cascadeDeleteKid(userId: userId, kidId: kid.id) { error in
            if error == nil {
                // Remove from local state
                Task { @MainActor in
                    self.kids.removeAll { $0.id == kid.id }
                    if self.selectedKid?.id == kid.id {
                        self.selectedKid = self.kids.first
                        self.fetchAllDataForSelectedKid()
                    }
                    completion(true)
                }
            } else {
                completion(false)
            }
        }
    }
    // MARK: - Firestore Cleanup for Catalog Consistency
    func cleanupNonCatalogItemsForSelectedKid() {
        guard let kid = selectedKid else { print("[DEBUG] No kid selected for cleanup"); return }
        // Define the current catalog IDs (should match AdminView)
        let rulesCatalogIds = ["rule1", "rule2", "rule3", "rule4", "rule5"]
        let choresCatalogIds = ["chore1", "chore2", "chore3", "chore4", "chore5"]
        let rewardsCatalogIds = ["reward1", "reward2", "reward3", "reward4", "reward5"]
        FirestoreManager.shared.cleanupNonCatalogItems(userId: userId, kidId: kid.id, validRuleIds: rulesCatalogIds, validChoreIds: choresCatalogIds, validRewardIds: rewardsCatalogIds) { error in
            if let error = error {
                print("[DEBUG] Firestore cleanup error: \(error.localizedDescription)")
            } else {
                print("[DEBUG] Firestore cleanup completed successfully.")
                self.fetchAllDataForSelectedKid()
            }
        }
    }
} 