import Foundation
import Combine

class LessonPlanManager: ObservableObject {
    @Published var lessonPlan: LessonPlan?
    @Published var userProgress: [String: LessonProgress] = [:]
    @Published var currentPath: LearningPath?
    @Published var isLoading = false
    @Published var error: Error?
    
    private let decoder: JSONDecoder
    private let progressKey = "user_lesson_progress"
    
    init() {
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
    }
    
    // MARK: - Loading
    
    func loadLessonPlan(from url: URL) async {
        isLoading = true
        error = nil
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            lessonPlan = try decoder.decode(LessonPlan.self, from: data)
            loadUserProgress()
            initializeProgress()
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    func loadLessonPlan(fromFile path: String) {
        isLoading = true
        error = nil
        
        do {
            let url = URL(fileURLWithPath: path)
            let data = try Data(contentsOf: url)
            lessonPlan = try decoder.decode(LessonPlan.self, from: data)
            loadUserProgress()
            initializeProgress()
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    // MARK: - Progress Management
    
    private func initializeProgress() {
        guard let plan = lessonPlan else { return }
        
        for lesson in plan.lessons {
            if userProgress[lesson.lessonId] == nil {
                userProgress[lesson.lessonId] = LessonProgress(
                    completionPercentage: 0.0,
                    masteryLevel: 0.0,
                    exercisesCompleted: 0,
                    lastStudied: nil,
                    isUnlocked: lesson.prerequisites.isEmpty
                )
            }
        }
        
        updateUnlockedLessons()
    }
    
    func updateLessonProgress(lessonId: String, completion: Double) {
        var progress = userProgress[lessonId] ?? LessonProgress(
            completionPercentage: 0.0,
            masteryLevel: 0.0,
            exercisesCompleted: 0,
            lastStudied: nil,
            isUnlocked: true
        )
        
        progress.completionPercentage = min(100.0, max(0.0, completion))
        progress.masteryLevel = progress.completionPercentage / 100.0
        progress.lastStudied = Date()
        
        userProgress[lessonId] = progress
        updateUnlockedLessons()
        saveUserProgress()
    }
    
    func completeExercise(lessonId: String, correct: Bool) {
        guard var progress = userProgress[lessonId] else { return }
        
        progress.exercisesCompleted = (progress.exercisesCompleted ?? 0) + 1
        
        let currentCompletion = progress.completionPercentage ?? 0.0
        let delta = correct ? 5.0 : -2.0
        let newCompletion = min(100.0, max(0.0, currentCompletion + delta))
        
        updateLessonProgress(lessonId: lessonId, completion: newCompletion)
    }
    
    func markLessonComplete(lessonId: String) {
        updateLessonProgress(lessonId: lessonId, completion: 100.0)
    }
    
    private func updateUnlockedLessons() {
        guard let plan = lessonPlan else { return }
        
        for lesson in plan.lessons {
            let shouldBeUnlocked = lesson.prerequisites.allSatisfy { prereq in
                guard let progress = userProgress[prereq.lessonId] else {
                    return prereq.relationship != .required
                }
                
                let threshold = prereq.completionThreshold ?? 0.7
                let completion = (progress.completionPercentage ?? 0.0) / 100.0
                
                switch prereq.relationship {
                case .required:
                    return completion >= threshold
                case .recommended, .helpful:
                    return true
                }
            }
            
            if var progress = userProgress[lesson.lessonId] {
                progress.isUnlocked = shouldBeUnlocked
                userProgress[lesson.lessonId] = progress
            }
        }
    }
    
    // MARK: - Querying
    
    func getUnlockedLessons() -> [Lesson] {
        guard let plan = lessonPlan else { return [] }
        return plan.getUnlockedLessons(userProgress: userProgress)
    }
    
    func getNextRecommendedLessons(limit: Int = 5) -> [Lesson] {
        guard let plan = lessonPlan else { return [] }
        return plan.getNextRecommendedLessons(userProgress: userProgress, limit: limit)
    }
    
    func getLessons(byDifficulty difficulty: DifficultyLevel) -> [Lesson] {
        guard let plan = lessonPlan else { return [] }
        return plan.getLessons(byDifficulty: difficulty)
    }
    
    func getLessons(byType type: LessonType) -> [Lesson] {
        guard let plan = lessonPlan else { return [] }
        return plan.getLessons(byType: type)
    }
    
    func getLesson(byId id: String) -> Lesson? {
        return lessonPlan?.getLesson(byId: id)
    }
    
    // MARK: - Learning Paths
    
    func selectLearningPath(_ path: LearningPath) {
        currentPath = path
        UserDefaults.standard.set(path.pathId, forKey: "selected_path")
    }
    
    func getPathProgress() -> (completed: Int, total: Int, percentage: Double) {
        guard let path = currentPath else { return (0, 0, 0.0) }
        
        let total = path.lessonSequence.count
        let completed = path.lessonSequence.filter { lessonId in
            let progress = userProgress[lessonId]
            return (progress?.completionPercentage ?? 0.0) >= 90.0
        }.count
        
        let percentage = total > 0 ? Double(completed) / Double(total) * 100 : 0.0
        return (completed, total, percentage)
    }
    
    func getNextLessonInPath() -> Lesson? {
        guard let path = currentPath,
              let plan = lessonPlan else { return nil }
        
        for lessonId in path.lessonSequence {
            if let progress = userProgress[lessonId],
               (progress.completionPercentage ?? 0.0) < 90.0,
               progress.isUnlocked ?? false {
                return plan.getLesson(byId: lessonId)
            }
        }
        
        return nil
    }
    
    // MARK: - Statistics
    
    func getOverallProgress() -> (totalLessons: Int, completed: Int, inProgress: Int, locked: Int) {
        guard let plan = lessonPlan else { return (0, 0, 0, 0) }
        
        let total = plan.lessons.count
        var completed = 0
        var inProgress = 0
        var locked = 0
        
        for lesson in plan.lessons {
            let progress = userProgress[lesson.lessonId]
            let completion = progress?.completionPercentage ?? 0.0
            let isUnlocked = progress?.isUnlocked ?? false
            
            if completion >= 90.0 {
                completed += 1
            } else if isUnlocked && completion > 0.0 {
                inProgress += 1
            } else if !isUnlocked {
                locked += 1
            }
        }
        
        return (total, completed, inProgress, locked)
    }
    
    func getDifficultyProgress(difficulty: DifficultyLevel) -> (completed: Int, total: Int, percentage: Double) {
        guard let plan = lessonPlan else { return (0, 0, 0.0) }
        
        let difficultyLessons = plan.getLessons(byDifficulty: difficulty)
        let total = difficultyLessons.count
        let completed = difficultyLessons.filter { lesson in
            let progress = userProgress[lesson.lessonId]
            return (progress?.completionPercentage ?? 0.0) >= 90.0
        }.count
        
        let percentage = total > 0 ? Double(completed) / Double(total) * 100 : 0.0
        return (completed, total, percentage)
    }
    
    func getTotalStudyTime() -> Double {
        guard let plan = lessonPlan else { return 0.0 }
        
        var totalMinutes = 0.0
        for lesson in plan.lessons {
            if let progress = userProgress[lesson.lessonId],
               (progress.completionPercentage ?? 0.0) > 0 {
                totalMinutes += Double(lesson.estimatedDurationMinutes ?? 30)
            }
        }
        
        return totalMinutes / 60.0
    }
    
    func getEstimatedRemainingTime() -> Double {
        guard let plan = lessonPlan else { return 0.0 }
        
        var remainingMinutes = 0.0
        for lesson in plan.lessons {
            let progress = userProgress[lesson.lessonId]
            let completion = progress?.completionPercentage ?? 0.0
            
            if completion < 90.0 {
                let duration = Double(lesson.estimatedDurationMinutes ?? 30)
                let remaining = duration * (1.0 - completion / 100.0)
                remainingMinutes += remaining
            }
        }
        
        return remainingMinutes / 60.0
    }
    
    // MARK: - Persistence
    
    private func saveUserProgress() {
        if let encoded = try? JSONEncoder().encode(userProgress) {
            UserDefaults.standard.set(encoded, forKey: progressKey)
        }
    }
    
    private func loadUserProgress() {
        if let data = UserDefaults.standard.data(forKey: progressKey),
           let decoded = try? JSONDecoder().decode([String: LessonProgress].self, from: data) {
            userProgress = decoded
        }
    }
    
    func resetProgress() {
        userProgress.removeAll()
        UserDefaults.standard.removeObject(forKey: progressKey)
        UserDefaults.standard.removeObject(forKey: "selected_path")
        currentPath = nil
        initializeProgress()
    }
    
    func exportProgress() -> Data? {
        return try? JSONEncoder().encode(userProgress)
    }
    
    func importProgress(from data: Data) {
        if let imported = try? JSONDecoder().decode([String: LessonProgress].self, from: data) {
            userProgress = imported
            updateUnlockedLessons()
            saveUserProgress()
        }
    }
}
