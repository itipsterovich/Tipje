import Foundation
import Combine
import SwiftUI

@MainActor
class TipjeStore: ObservableObject {
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
    @AppStorage("activeKidId") var activeKidId: String?
    @Published var customRules: [CatalogRule] = []
    @Published var customChores: [CatalogChore] = []
    @Published var customRewards: [CatalogReward] = []

    private var cancellables = Set<AnyCancellable>()

    init() {}

    func setUser(userId: String) {
        print("[Store] setUser called with userId: \(userId)")
        self.userId = userId
        fetchKids()
    }

    func selectKid(_ kid: Kid) {
        print("[Store] selectKid called with kid: \(kid)")
        self.selectedKid = kid
        self.activeKidId = kid.id
        fetchAllDataForSelectedKid()
    }

    func selectFirstKidIfAvailable() {
        if let activeId = activeKidId, let found = kids.first(where: { $0.id == activeId }) {
            selectKid(found)
        } else if let firstKid = kids.first {
            selectKid(firstKid)
        }
    }

    func fetchKids() {
        print("[Store] fetchKids called with userId: \(userId)")
        guard !userId.isEmpty else { return }
        isLoading = true
        FirestoreManager.shared.fetchKids(userId: userId) { [weak self] kids in
            Task { @MainActor in
                print("[Store] fetchKids Firestore returned: \(kids.map { $0.name })")
                self?.kids = kids
                self?.isLoading = false
                self?.selectFirstKidIfAvailable()
            }
        }
    }

    func fetchAllDataForSelectedKid() {
        guard let kid = selectedKid else { return }
        print("[Store] fetchAllDataForSelectedKid for userId: \(userId), kidId: \(kid.id), kidName: \(kid.name)")
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
            print("[Store] fetchRules returned: \(fetched.map { $0.title }) for kidId: \(kid.id)")
            rules = fetched
            group.leave()
        }
        group.enter()
        FirestoreManager.shared.fetchChores(userId: userId, kidId: kid.id) { fetched in
            print("[Store] fetchChores returned: \(fetched.map { $0.title }) for kidId: \(kid.id)")
            chores = fetched
            group.leave()
        }
        group.enter()
        FirestoreManager.shared.fetchRewards(userId: userId, kidId: kid.id) { fetched in
            print("[Store] fetchRewards returned: \(fetched.map { $0.title }) for kidId: \(kid.id)")
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
        // Fetch custom rules, chores, rewards for catalog-driven display
        group.enter()
        FirestoreManager.shared.fetchCustomRules(userId: userId) { fetched in
            Task { @MainActor in
                self.customRules = fetched
                group.leave()
            }
        }
        group.enter()
        FirestoreManager.shared.fetchCustomChores(userId: userId) { fetched in
            Task { @MainActor in
                self.customChores = fetched
                group.leave()
            }
        }
        group.enter()
        FirestoreManager.shared.fetchCustomRewards(userId: userId) { fetched in
            Task { @MainActor in
                self.customRewards = fetched
                group.leave()
            }
        }
        group.notify(queue: .main) { [weak self] in
            print("[Store] fetchAllDataForSelectedKid complete. Rules: \(rules.map { $0.title }), Chores: \(chores.map { $0.title }), Rewards: \(rewards.map { $0.title })")
            self?.rules = rules
            self?.chores = chores
            self?.rewards = rewards
            self?.rewardPurchases = purchases
            self?.transactions = txns
            self?.balance = balance
            self?.isLoading = false
        }
    }

    // MARK: - CRUD for Rules
    func addRule(_ rule: Rule) {
        guard let kid = selectedKid else { return }
        print("[Store] addRule: \(rule) for userId: \(userId), kidId: \(kid.id)")
        isLoading = true
        FirestoreManager.shared.addRule(userId: userId, kidId: kid.id, rule: rule) { [weak self] error in
            Task { @MainActor in
                self?.isLoading = false
                if let error = error {
                    print("[Store] addRule error: \(error)")
                    self?.errorMessage = error.localizedDescription
                } else {
                    print("[Store] addRule success for rule: \(rule.title)")
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
        print("[Store] addChore: \(chore) for userId: \(userId), kidId: \(kid.id)")
        isLoading = true
        FirestoreManager.shared.addChore(userId: userId, kidId: kid.id, chore: chore) { [weak self] error in
            Task { @MainActor in
                self?.isLoading = false
                if let error = error {
                    print("[Store] addChore error: \(error)")
                    self?.errorMessage = error.localizedDescription
                } else {
                    print("[Store] addChore success for chore: \(chore.title)")
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
        print("[Store] addReward: \(reward) for userId: \(userId), kidId: \(kid.id)")
        isLoading = true
        FirestoreManager.shared.addReward(userId: userId, kidId: kid.id, reward: reward) { [weak self] error in
            Task { @MainActor in
                self?.isLoading = false
                if let error = error {
                    print("[Store] addReward error: \(error)")
                    self?.errorMessage = error.localizedDescription
                } else {
                    print("[Store] addReward success for reward: \(reward.title)")
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
        // Check if reward is already in basket
        if let existing = rewardPurchases.first(where: { $0.status == "IN_BASKET" && $0.rewardRef.documentID == reward.id }) {
            // Increment quantity atomically
            var updated = existing
            updated.quantity += 1
            FirestoreManager.shared.addRewardPurchase(userId: userId, kidId: kid.id, purchase: updated) { [weak self] err in
                if err == nil {
                    self?.fetchAllDataForSelectedKid()
                } else {
                    self?.errorMessage = err?.localizedDescription
                }
            }
            // Deduct peanuts and log transaction
            let txn = Transaction(id: UUID().uuidString, type: "SPEND_REWARD", refId: existing.id, amount: -reward.cost, timestamp: Date(), note: "Purchased reward: \(reward.title)")
            FirestoreManager.shared.updateBalanceAndLog(userId: userId, kidId: kid.id, delta: -reward.cost, txn: txn) { _ in }
        } else {
            let purchaseId = UUID().uuidString
            let rewardRef = FirestoreManager.shared.rewardRef(userId: userId, kidId: kid.id, rewardId: reward.id)
            let purchase = RewardPurchase(id: purchaseId, rewardRef: rewardRef, status: "IN_BASKET", purchasedAt: Date(), givenAt: nil, quantity: 1)
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
        guard !userId.isEmpty else { completion(false); return }
        FirestoreManager.shared.cascadeDeleteKid(userId: userId, kidId: kid.id) { [weak self] error in
            Task { @MainActor in
                if let error = error {
                    completion(false)
                } else {
                    self?.fetchKids()
                    // If the deleted kid was selected, select the remaining kid (if any)
                    if self?.selectedKid?.id == kid.id {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            self?.selectFirstKidIfAvailable()
                        }
                    }
                    completion(true)
                }
            }
        }
    }
    // MARK: - Firestore Cleanup for Catalog Consistency
    func cleanupChoresToCatalog() {
        guard let kid = selectedKid else { return }
        let choresCatalogIds = choresCatalog.map { $0.id }
        FirestoreManager.shared.cleanupNonCatalogItems(userId: userId, kidId: kid.id, validRuleIds: [], validChoreIds: choresCatalogIds, validRewardIds: []) { error in
            if let error = error {
            } else {
                self.fetchAllDataForSelectedKid()
            }
        }
    }
    func decrementOrRemovePurchase(purchase: RewardPurchase) {
        guard let kid = selectedKid else { return }
        if purchase.quantity > 1 {
            var updated = purchase
            updated.quantity -= 1
            FirestoreManager.shared.addRewardPurchase(userId: userId, kidId: kid.id, purchase: updated) { [weak self] err in
                if err == nil {
                    self?.fetchAllDataForSelectedKid()
                } else {
                    self?.errorMessage = err?.localizedDescription
                }
            }
        } else {
            var updated = purchase
            updated.status = "GIVEN"
            updated.givenAt = Date()
            FirestoreManager.shared.addRewardPurchase(userId: userId, kidId: kid.id, purchase: updated) { [weak self] err in
                if err == nil {
                    self?.fetchAllDataForSelectedKid()
                } else {
                    self?.errorMessage = err?.localizedDescription
                }
            }
        }
    }
} 