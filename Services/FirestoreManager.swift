import Foundation
import FirebaseFirestore
import CryptoKit

// MARK: - User
struct User: Identifiable, Codable {
    var id: String
    var email: String
    var displayName: String?
    var authProvider: String?
    var pinHash: String?
    var createdAt: Date?
    var updatedAt: Date?
    // PIN lockout fields
    var pinFailedAttempts: Int?
    var pinLockoutUntil: Date?
    
    func toDict() -> [String: Any] {
        return [
            "email": email,
            "displayName": displayName as Any,
            "authProvider": authProvider as Any,
            "pinHash": pinHash as Any,
            "createdAt": createdAt ?? FieldValue.serverTimestamp(),
            "updatedAt": updatedAt ?? FieldValue.serverTimestamp(),
            "pinFailedAttempts": pinFailedAttempts as Any,
            "pinLockoutUntil": pinLockoutUntil as Any
        ]
    }
    
    static func fromDict(id: String, dict: [String: Any]) -> User? {
        guard let email = dict["email"] as? String else { return nil }
        let displayName = dict["displayName"] as? String
        let authProvider = dict["authProvider"] as? String
        let pinHash = dict["pinHash"] as? String
        let createdAt = (dict["createdAt"] as? Timestamp)?.dateValue()
        let updatedAt = (dict["updatedAt"] as? Timestamp)?.dateValue()
        let pinFailedAttempts = dict["pinFailedAttempts"] as? Int
        let pinLockoutUntil = (dict["pinLockoutUntil"] as? Timestamp)?.dateValue()
        return User(id: id, email: email, displayName: displayName, authProvider: authProvider, pinHash: pinHash, createdAt: createdAt, updatedAt: updatedAt, pinFailedAttempts: pinFailedAttempts, pinLockoutUntil: pinLockoutUntil)
    }
}

// MARK: - Kid
struct Kid: Identifiable, Codable {
    var id: String
    var name: String
    var createdAt: Date?
    var balance: Int
    
    func toDict() -> [String: Any] {
        return [
            "name": name,
            "createdAt": createdAt ?? FieldValue.serverTimestamp(),
            "balance": balance
        ]
    }
    
    static func fromDict(id: String, dict: [String: Any]) -> Kid? {
        guard let name = dict["name"] as? String,
              let balance = dict["balance"] as? Int else { return nil }
        let createdAt = (dict["createdAt"] as? Timestamp)?.dateValue()
        return Kid(id: id, name: name, createdAt: createdAt, balance: balance)
    }
}

// MARK: - Rule
struct Rule: Identifiable, Codable {
    var id: String
    var title: String
    var peanutValue: Int
    var isActive: Bool
    var completions: [Date] = []
    
    func toDict() -> [String: Any] {
        return [
            "title": title,
            "peanutValue": peanutValue,
            "isActive": isActive,
            "completions": completions.map { $0 }
        ]
    }
    
    static func fromDict(id: String, dict: [String: Any]) -> Rule? {
        guard let title = dict["title"] as? String,
              let peanutValue = dict["peanutValue"] as? Int,
              let isActive = dict["isActive"] as? Bool else { return nil }
        let completions = (dict["completions"] as? [Timestamp])?.map { $0.dateValue() } ?? []
        return Rule(id: id, title: title, peanutValue: peanutValue, isActive: isActive, completions: completions)
    }
}

// MARK: - Chore
struct Chore: Identifiable, Codable {
    var id: String
    var title: String
    var peanutValue: Int
    var isActive: Bool
    var completions: [Date] = []
    
    func toDict() -> [String: Any] {
        return [
            "title": title,
            "peanutValue": peanutValue,
            "isActive": isActive,
            "completions": completions.map { $0 }
        ]
    }
    
    static func fromDict(id: String, dict: [String: Any]) -> Chore? {
        guard let title = dict["title"] as? String,
              let peanutValue = dict["peanutValue"] as? Int,
              let isActive = dict["isActive"] as? Bool else { return nil }
        let completions = (dict["completions"] as? [Timestamp])?.map { $0.dateValue() } ?? []
        return Chore(id: id, title: title, peanutValue: peanutValue, isActive: isActive, completions: completions)
    }
}

// MARK: - Reward
struct Reward: Identifiable, Codable {
    var id: String
    var title: String
    var cost: Int
    var isActive: Bool
    var inBasket: Bool? // Optional, for UI logic
    
    func toDict() -> [String: Any] {
        return [
            "title": title,
            "cost": cost,
            "isActive": isActive
        ]
    }
    
    static func fromDict(id: String, dict: [String: Any]) -> Reward? {
        guard let title = dict["title"] as? String,
              let cost = dict["cost"] as? Int,
              let isActive = dict["isActive"] as? Bool else { return nil }
        return Reward(id: id, title: title, cost: cost, isActive: isActive)
    }
}

// MARK: - RewardPurchase
struct RewardPurchase: Identifiable, Codable {
    var id: String
    var rewardRef: DocumentReference
    var status: String // "IN_BASKET" | "GIVEN"
    var purchasedAt: Date
    var givenAt: Date?
    
    func toDict() -> [String: Any] {
        return [
            "rewardRef": rewardRef,
            "status": status,
            "purchasedAt": purchasedAt,
            "givenAt": givenAt as Any
        ]
    }
    
    static func fromDict(id: String, dict: [String: Any]) -> RewardPurchase? {
        guard let rewardRef = dict["rewardRef"] as? DocumentReference,
              let status = dict["status"] as? String,
              let purchasedAt = (dict["purchasedAt"] as? Timestamp)?.dateValue() else { return nil }
        let givenAt = (dict["givenAt"] as? Timestamp)?.dateValue()
        return RewardPurchase(id: id, rewardRef: rewardRef, status: status, purchasedAt: purchasedAt, givenAt: givenAt)
    }
}

// MARK: - Transaction
struct Transaction: Identifiable, Codable {
    var id: String
    var type: String // "EARN_RULE" | "EARN_CHORE" | "SPEND_REWARD"
    var refId: String
    var amount: Int
    var timestamp: Date
    var note: String?
    
    func toDict() -> [String: Any] {
        return [
            "type": type,
            "refId": refId,
            "amount": amount,
            "timestamp": timestamp,
            "note": note as Any
        ]
    }
    
    static func fromDict(id: String, dict: [String: Any]) -> Transaction? {
        guard let type = dict["type"] as? String,
              let refId = dict["refId"] as? String,
              let amount = dict["amount"] as? Int,
              let timestamp = (dict["timestamp"] as? Timestamp)?.dateValue() else { return nil }
        let note = dict["note"] as? String
        return Transaction(id: id, type: type, refId: refId, amount: amount, timestamp: timestamp, note: note)
    }
}

class FirestoreManager {
    static let shared = FirestoreManager()
    private let db = Firestore.firestore()

    // MARK: - User
    func createUser(_ user: User, completion: @escaping (Error?) -> Void) {
        db.collection("users").document(user.id).setData(user.toDict(), merge: true) { error in
            completion(error)
        }
    }

    func fetchUser(userId: String, completion: @escaping (User?) -> Void) {
        db.collection("users").document(userId).getDocument { snapshot, error in
            guard let doc = snapshot, let data = doc.data() else {
                completion(nil)
                return
            }
            completion(User.fromDict(id: doc.documentID, dict: data))
        }
    }

    // MARK: - Kid
    func createKid(userId: String, kid: Kid, completion: @escaping (Error?) -> Void) {
        let kidsRef = db.collection("users").document(userId).collection("kids")
        kidsRef.getDocuments { snapshot, error in
            if let error = error {
                completion(error)
                return
            }
            let count = snapshot?.documents.count ?? 0
            if count >= 2 {
                let limitError = NSError(domain: "FirestoreManager", code: 400, userInfo: [NSLocalizedDescriptionKey: "Maximum of 2 kids allowed."])
                completion(limitError)
                return
            }
            kidsRef.document(kid.id).setData(kid.toDict(), merge: true) { error in
                completion(error)
            }
        }
    }

    func fetchKid(userId: String, kidId: String, completion: @escaping (Kid?) -> Void) {
        db.collection("users").document(userId).collection("kids").document(kidId).getDocument { snapshot, error in
            guard let doc = snapshot, let data = doc.data() else {
                completion(nil)
                return
            }
            completion(Kid.fromDict(id: doc.documentID, dict: data))
        }
    }

    func fetchKids(userId: String, completion: @escaping ([Kid]) -> Void) {
        db.collection("users").document(userId).collection("kids").getDocuments { snapshot, error in
            let kids = snapshot?.documents.compactMap { doc in
                Kid.fromDict(id: doc.documentID, dict: doc.data())
            } ?? []
            completion(kids)
        }
    }

    // MARK: - Rule
    func addRule(userId: String, kidId: String, rule: Rule, completion: @escaping (Error?) -> Void) {
        db.collection("users").document(userId).collection("kids").document(kidId).collection("rules").document(rule.id).setData(rule.toDict(), merge: true) { error in
            print("[DEBUG] Firestore addRule completed for \(rule.id), error: \(String(describing: error))")
            completion(error)
        }
    }

    func fetchRules(userId: String, kidId: String, completion: @escaping ([Rule]) -> Void) {
        db.collection("users").document(userId).collection("kids").document(kidId).collection("rules").getDocuments(source: .server) { snapshot, error in
            let rules = snapshot?.documents.compactMap { doc in
                Rule.fromDict(id: doc.documentID, dict: doc.data())
            } ?? []
            print("[DEBUG] Firestore fetchRules fetched: " + rules.map { "id=\($0.id), isActive=\($0.isActive)" }.joined(separator: ", "))
            completion(rules)
        }
    }

    // MARK: - Chore
    func addChore(userId: String, kidId: String, chore: Chore, completion: @escaping (Error?) -> Void) {
        db.collection("users").document(userId).collection("kids").document(kidId).collection("chores").document(chore.id).setData(chore.toDict(), merge: true) { error in
            completion(error)
        }
    }

    func fetchChores(userId: String, kidId: String, completion: @escaping ([Chore]) -> Void) {
        db.collection("users").document(userId).collection("kids").document(kidId).collection("chores").getDocuments { snapshot, error in
            let chores = snapshot?.documents.compactMap { doc in
                Chore.fromDict(id: doc.documentID, dict: doc.data())
            } ?? []
            completion(chores)
        }
    }

    // MARK: - Reward
    func addReward(userId: String, kidId: String, reward: Reward, completion: @escaping (Error?) -> Void) {
        db.collection("users").document(userId).collection("kids").document(kidId).collection("rewards").document(reward.id).setData(reward.toDict(), merge: true) { error in
            completion(error)
        }
    }

    func fetchRewards(userId: String, kidId: String, completion: @escaping ([Reward]) -> Void) {
        db.collection("users").document(userId).collection("kids").document(kidId).collection("rewards").getDocuments { snapshot, error in
            let rewards = snapshot?.documents.compactMap { doc in
                Reward.fromDict(id: doc.documentID, dict: doc.data())
            } ?? []
            completion(rewards)
        }
    }

    // MARK: - RewardPurchase
    func addRewardPurchase(userId: String, kidId: String, purchase: RewardPurchase, completion: @escaping (Error?) -> Void) {
        db.collection("users").document(userId).collection("kids").document(kidId).collection("rewardPurchases").document(purchase.id).setData(purchase.toDict(), merge: true) { error in
            completion(error)
        }
    }

    func fetchRewardPurchases(userId: String, kidId: String, completion: @escaping ([RewardPurchase]) -> Void) {
        db.collection("users").document(userId).collection("kids").document(kidId).collection("rewardPurchases").getDocuments { snapshot, error in
            let purchases = snapshot?.documents.compactMap { doc in
                RewardPurchase.fromDict(id: doc.documentID, dict: doc.data())
            } ?? []
            completion(purchases)
        }
    }

    // MARK: - Transaction
    func addTransaction(userId: String, kidId: String, txn: Transaction, completion: @escaping (Error?) -> Void) {
        db.collection("users").document(userId).collection("kids").document(kidId).collection("transactions").document(txn.id).setData(txn.toDict(), merge: true) { error in
            completion(error)
        }
    }

    func fetchTransactions(userId: String, kidId: String, completion: @escaping ([Transaction]) -> Void) {
        db.collection("users").document(userId).collection("kids").document(kidId).collection("transactions").getDocuments { snapshot, error in
            let txns = snapshot?.documents.compactMap { doc in
                Transaction.fromDict(id: doc.documentID, dict: doc.data())
            } ?? []
            completion(txns)
        }
    }

    // MARK: - Atomic Balance Update (with Transaction)
    func updateBalanceAndLog(userId: String, kidId: String, delta: Int, txn: Transaction, completion: @escaping (Error?) -> Void) {
        let kidRef = db.collection("users").document(userId).collection("kids").document(kidId)
        let txnRef = kidRef.collection("transactions").document(txn.id)
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let kidDoc: DocumentSnapshot
            do {
                try kidDoc = transaction.getDocument(kidRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            guard var kidData = kidDoc.data(), let currentBalance = kidData["balance"] as? Int else {
                errorPointer?.pointee = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Kid not found or missing balance"])
                return nil
            }
            let newBalance = currentBalance + delta
            transaction.updateData(["balance": newBalance], forDocument: kidRef)
            transaction.setData(txn.toDict(), forDocument: txnRef)
            return nil
        }) { (_, error) in
            completion(error)
        }
    }

    // MARK: - User PIN
    /// Hashes a PIN using SHA256
    private func hashPin(_ pin: String) -> String {
        let data = Data(pin.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }

    /// Stores the hashed PIN in Firestore under 'pinHash'
    func setUserPin(userId: String, pinCode: String, completion: @escaping (Error?) -> Void) {
        let pinHash = hashPin(pinCode)
        db.collection("users").document(userId).updateData([
            "pinHash": pinHash,
            "pinFailedAttempts": 0,
            "pinLockoutUntil": FieldValue.delete()
        ]) { error in
            completion(error)
        }
    }

    /// Verifies a PIN by comparing its hash to the stored hash, with lockout logic
    func verifyUserPin(userId: String, pinCode: String, completion: @escaping (Bool) -> Void) {
        let userRef = db.collection("users").document(userId)
        userRef.getDocument { snapshot, error in
            guard let doc = snapshot, let data = doc.data() else {
                completion(false)
                return
            }
            let pinHash = data["pinHash"] as? String
            let failedAttempts = data["pinFailedAttempts"] as? Int ?? 0
            let lockoutUntil = (data["pinLockoutUntil"] as? Timestamp)?.dateValue()
            let now = Date()
            // Check lockout
            if let lockoutUntil = lockoutUntil, now < lockoutUntil {
                completion(false)
                return
            }
            // Check PIN
            let inputHash = self.hashPin(pinCode)
            if inputHash == pinHash {
                // Success: reset failed attempts and lockout
                userRef.updateData([
                    "pinFailedAttempts": 0,
                    "pinLockoutUntil": FieldValue.delete()
                ])
                completion(true)
            } else {
                // Fail: increment attempts
                let newAttempts = failedAttempts + 1
                if newAttempts >= 5 {
                    // Lockout for 5 minutes
                    let lockoutDate = Calendar.current.date(byAdding: .minute, value: 5, to: now) ?? now.addingTimeInterval(300)
                    userRef.updateData([
                        "pinFailedAttempts": newAttempts,
                        "pinLockoutUntil": lockoutDate
                    ])
                } else {
                    userRef.updateData([
                        "pinFailedAttempts": newAttempts
                    ])
                }
                completion(false)
            }
        }
    }

    /// Cascade delete all subcollections for a kid, then delete the kid document
    func cascadeDeleteKid(userId: String, kidId: String, completion: @escaping (Error?) -> Void) {
        let kidRef = db.collection("users").document(userId).collection("kids").document(kidId)
        let subcollections = ["rules", "chores", "rewards", "rewardPurchases", "transactions"]
        let group = DispatchGroup()
        var firstError: Error? = nil
        for sub in subcollections {
            group.enter()
            kidRef.collection(sub).getDocuments { snapshot, error in
                if let error = error {
                    if firstError == nil { firstError = error }
                    group.leave()
                    return
                }
                let batch = self.db.batch()
                snapshot?.documents.forEach { batch.deleteDocument($0.reference) }
                batch.commit { err in
                    if let err = err, firstError == nil { firstError = err }
                    group.leave()
                }
            }
        }
        group.notify(queue: .main) {
            if let error = firstError {
                completion(error)
                return
            }
            kidRef.delete { error in
                completion(error)
            }
        }
    }

    // MARK: - Firestore Reference Helpers
    func rewardRef(userId: String, kidId: String, rewardId: String) -> DocumentReference {
        db.collection("users").document(userId).collection("kids").document(kidId).collection("rewards").document(rewardId)
    }
    func ruleRef(userId: String, kidId: String, ruleId: String) -> DocumentReference {
        db.collection("users").document(userId).collection("kids").document(kidId).collection("rules").document(ruleId)
    }
    func choreRef(userId: String, kidId: String, choreId: String) -> DocumentReference {
        db.collection("users").document(userId).collection("kids").document(kidId).collection("chores").document(choreId)
    }
    func transactionRef(userId: String, kidId: String, txnId: String) -> DocumentReference {
        db.collection("users").document(userId).collection("kids").document(kidId).collection("transactions").document(txnId)
    }
    func rewardPurchaseRef(userId: String, kidId: String, purchaseId: String) -> DocumentReference {
        db.collection("users").document(userId).collection("kids").document(kidId).collection("rewardPurchases").document(purchaseId)
    }

    // MARK: - Firestore Cleanup for Catalog Consistency
    /// Deletes all rules, chores, and rewards for a kid that are not present in the provided catalog IDs.
    func cleanupNonCatalogItems(userId: String, kidId: String, validRuleIds: [String], validChoreIds: [String], validRewardIds: [String], completion: @escaping (Error?) -> Void) {
        let group = DispatchGroup()
        var firstError: Error? = nil
        // Cleanup rules
        group.enter()
        db.collection("users").document(userId).collection("kids").document(kidId).collection("rules").getDocuments { snapshot, error in
            if let error = error { firstError = error; group.leave(); return }
            let batch = self.db.batch()
            snapshot?.documents.forEach { doc in
                if !validRuleIds.contains(doc.documentID) {
                    batch.deleteDocument(doc.reference)
                }
            }
            batch.commit { err in if let err = err, firstError == nil { firstError = err }; group.leave() }
        }
        // Cleanup chores
        group.enter()
        db.collection("users").document(userId).collection("kids").document(kidId).collection("chores").getDocuments { snapshot, error in
            if let error = error { firstError = error; group.leave(); return }
            let batch = self.db.batch()
            snapshot?.documents.forEach { doc in
                if !validChoreIds.contains(doc.documentID) {
                    batch.deleteDocument(doc.reference)
                }
            }
            batch.commit { err in if let err = err, firstError == nil { firstError = err }; group.leave() }
        }
        // Cleanup rewards
        group.enter()
        db.collection("users").document(userId).collection("kids").document(kidId).collection("rewards").getDocuments { snapshot, error in
            if let error = error { firstError = error; group.leave(); return }
            let batch = self.db.batch()
            snapshot?.documents.forEach { doc in
                if !validRewardIds.contains(doc.documentID) {
                    batch.deleteDocument(doc.reference)
                }
            }
            batch.commit { err in if let err = err, firstError == nil { firstError = err }; group.leave() }
        }
        group.notify(queue: .main) {
            completion(firstError)
        }
    }
} 
