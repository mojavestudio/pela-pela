import Foundation

class SkillTreeAPI {
    private let decoder: JSONDecoder
    
    init() {
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
    }
    
    func loadSkillTree(from url: URL) async throws -> SkillTree {
        let (data, _) = try await URLSession.shared.data(from: url)
        return try decoder.decode(SkillTree.self, from: data)
    }
    
    func loadSkillTree(from jsonData: Data) throws -> SkillTree {
        return try decoder.decode(SkillTree.self, from: jsonData)
    }
    
    func loadSkillTree(fromFile path: String) throws -> SkillTree {
        let url = URL(fileURLWithPath: path)
        let data = try Data(contentsOf: url)
        return try decoder.decode(SkillTree.self, from: data)
    }
}

class SkillTreeManager: ObservableObject {
    @Published var skillTree: SkillTree?
    @Published var userProgress: [String: ProgressTracking] = [:]
    @Published var isLoading = false
    @Published var error: Error?
    
    private let api = SkillTreeAPI()
    private let progressKey = "user_skill_progress"
    
    func loadTree(from url: URL) async {
        isLoading = true
        error = nil
        
        do {
            skillTree = try await api.loadSkillTree(from: url)
            loadUserProgress()
            initializeProgress()
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    func loadTree(fromFile path: String) {
        isLoading = true
        error = nil
        
        do {
            skillTree = try api.loadSkillTree(fromFile: path)
            loadUserProgress()
            initializeProgress()
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    private func initializeProgress() {
        guard let tree = skillTree else { return }
        
        for node in tree.nodes {
            if userProgress[node.id] == nil {
                userProgress[node.id] = ProgressTracking(
                    masteryLevel: 0.0,
                    lastPracticed: nil,
                    practiceCount: 0,
                    isUnlocked: node.difficultyTier == 1
                )
            }
        }
        
        updateUnlockedSkills()
    }
    
    func updateProgress(for skillId: String, mastery: Double) {
        var progress = userProgress[skillId] ?? ProgressTracking(
            masteryLevel: 0.0,
            lastPracticed: nil,
            practiceCount: 0,
            isUnlocked: true
        )
        
        progress.masteryLevel = min(1.0, max(0.0, mastery))
        progress.lastPracticed = Date()
        progress.practiceCount = (progress.practiceCount ?? 0) + 1
        
        userProgress[skillId] = progress
        updateUnlockedSkills()
        saveUserProgress()
    }
    
    func completeExercise(for skillId: String, correct: Bool) {
        guard var progress = userProgress[skillId] else { return }
        
        let currentMastery = progress.masteryLevel ?? 0.0
        let delta = correct ? 0.05 : -0.02
        let newMastery = min(1.0, max(0.0, currentMastery + delta))
        
        updateProgress(for: skillId, mastery: newMastery)
    }
    
    private func updateUnlockedSkills() {
        guard let tree = skillTree else { return }
        
        for node in tree.nodes {
            let shouldBeUnlocked = node.prerequisites.allSatisfy { prereq in
                guard let progress = userProgress[prereq.skillId] else {
                    return prereq.relationship != .required
                }
                
                let threshold = prereq.masteryThreshold ?? 0.7
                let mastery = progress.masteryLevel ?? 0.0
                
                switch prereq.relationship {
                case .required:
                    return mastery >= threshold
                case .recommended, .helpful:
                    return true
                }
            }
            
            if var progress = userProgress[node.id] {
                progress.isUnlocked = shouldBeUnlocked
                userProgress[node.id] = progress
            }
        }
    }
    
    func getUnlockedSkills() -> [SkillNode] {
        guard let tree = skillTree else { return [] }
        return tree.getUnlockedSkills(userProgress: userProgress)
    }
    
    func getNextRecommendedSkills(limit: Int = 5) -> [SkillNode] {
        guard let tree = skillTree else { return [] }
        return tree.getNextRecommendedSkills(userProgress: userProgress, limit: limit)
    }
    
    func getSkillProgress(for skillId: String) -> ProgressTracking? {
        return userProgress[skillId]
    }
    
    func getMasteryPercentage(for skillId: String) -> Double {
        return (userProgress[skillId]?.masteryLevel ?? 0.0) * 100
    }
    
    func getTierProgress(tier: Int) -> (completed: Int, total: Int, percentage: Double) {
        guard let tree = skillTree else { return (0, 0, 0.0) }
        
        let tierSkills = tree.getSkillsByTier(tier)
        let total = tierSkills.count
        let completed = tierSkills.filter { skill in
            let mastery = userProgress[skill.id]?.masteryLevel ?? 0.0
            return mastery >= 0.9
        }.count
        
        let percentage = total > 0 ? Double(completed) / Double(total) * 100 : 0.0
        return (completed, total, percentage)
    }
    
    func getOverallProgress() -> (totalSkills: Int, mastered: Int, inProgress: Int, locked: Int) {
        guard let tree = skillTree else { return (0, 0, 0, 0) }
        
        let total = tree.nodes.count
        var mastered = 0
        var inProgress = 0
        var locked = 0
        
        for node in tree.nodes {
            let progress = userProgress[node.id]
            let mastery = progress?.masteryLevel ?? 0.0
            let isUnlocked = progress?.isUnlocked ?? false
            
            if mastery >= 0.9 {
                mastered += 1
            } else if isUnlocked && mastery > 0.0 {
                inProgress += 1
            } else if !isUnlocked {
                locked += 1
            }
        }
        
        return (total, mastered, inProgress, locked)
    }
    
    private func saveUserProgress() {
        if let encoded = try? JSONEncoder().encode(userProgress) {
            UserDefaults.standard.set(encoded, forKey: progressKey)
        }
    }
    
    private func loadUserProgress() {
        if let data = UserDefaults.standard.data(forKey: progressKey),
           let decoded = try? JSONDecoder().decode([String: ProgressTracking].self, from: data) {
            userProgress = decoded
        }
    }
    
    func resetProgress() {
        userProgress.removeAll()
        UserDefaults.standard.removeObject(forKey: progressKey)
        initializeProgress()
    }
}

extension SkillNode {
    var isLocked: Bool {
        return !(progressTracking?.isUnlocked ?? false)
    }
    
    var masteryPercentage: Double {
        return (progressTracking?.masteryLevel ?? 0.0) * 100
    }
    
    var isMastered: Bool {
        return (progressTracking?.masteryLevel ?? 0.0) >= 0.9
    }
    
    var statusEmoji: String {
        if isMastered { return "✅" }
        if isLocked { return "🔒" }
        if (progressTracking?.masteryLevel ?? 0.0) > 0.0 { return "📚" }
        return "⭐️"
    }
}
