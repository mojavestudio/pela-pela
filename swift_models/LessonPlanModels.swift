import Foundation

// MARK: - Lesson Models

struct Lesson: Codable, Identifiable {
    let lessonId: String
    let title: LocalizedText
    let description: LocalizedText?
    let difficultyLevel: DifficultyLevel
    let lessonType: LessonType
    let estimatedDurationMinutes: Int?
    let learningObjectives: [String]?
    let skills: [LessonSkill]
    let vocabulary: [VocabularyItem]?
    let grammarPoints: [GrammarPoint]?
    let dialogues: [Dialogue]?
    let culturalNotes: [CulturalNote]?
    let exercises: [Exercise]?
    let prerequisites: [LessonPrerequisite]
    let unlocks: [String]
    let metadata: LessonMetadata?
    var progress: LessonProgress?
    
    var id: String { lessonId }
    
    enum CodingKeys: String, CodingKey {
        case lessonId = "lesson_id"
        case title, description
        case difficultyLevel = "difficulty_level"
        case lessonType = "lesson_type"
        case estimatedDurationMinutes = "estimated_duration_minutes"
        case learningObjectives = "learning_objectives"
        case skills, vocabulary
        case grammarPoints = "grammar_points"
        case dialogues
        case culturalNotes = "cultural_notes"
        case exercises, prerequisites, unlocks, metadata, progress
    }
}

enum DifficultyLevel: String, Codable {
    case absoluteBeginner = "absolute_beginner"
    case beginner
    case elementary
    case preIntermediate = "pre_intermediate"
    case intermediate
    case upperIntermediate = "upper_intermediate"
    case advanced
    case proficient
    
    var displayName: String {
        switch self {
        case .absoluteBeginner: return "Absolute Beginner"
        case .beginner: return "Beginner"
        case .elementary: return "Elementary"
        case .preIntermediate: return "Pre-Intermediate"
        case .intermediate: return "Intermediate"
        case .upperIntermediate: return "Upper-Intermediate"
        case .advanced: return "Advanced"
        case .proficient: return "Proficient"
        }
    }
    
    var emoji: String {
        switch self {
        case .absoluteBeginner: return "🌱"
        case .beginner: return "🌿"
        case .elementary: return "🌳"
        case .preIntermediate: return "🏃"
        case .intermediate: return "🎯"
        case .upperIntermediate: return "🚀"
        case .advanced: return "⭐️"
        case .proficient: return "👑"
        }
    }
}

enum LessonType: String, Codable {
    case foundation
    case vocabularyTheme = "vocabulary_theme"
    case grammarFocus = "grammar_focus"
    case conversation
    case cultural
    case mixedSkills = "mixed_skills"
    case review
}

struct LessonSkill: Codable {
    let skillId: String
    let skillType: String
    let isCore: Bool?
    
    enum CodingKeys: String, CodingKey {
        case skillId = "skill_id"
        case skillType = "skill_type"
        case isCore = "is_core"
    }
}

struct VocabularyItem: Codable, Identifiable {
    let word: String?
    let reading: String?
    let meaning: String?
    let partOfSpeech: String?
    let exampleSentence: String?
    
    var id: String { word ?? UUID().uuidString }
    
    enum CodingKeys: String, CodingKey {
        case word, reading, meaning
        case partOfSpeech = "part_of_speech"
        case exampleSentence = "example_sentence"
    }
}

struct GrammarPoint: Codable, Identifiable {
    let pattern: String?
    let explanation: String?
    let usage: String?
    let examples: [Example]?
    
    var id: String { pattern ?? UUID().uuidString }
}

struct Example: Codable, Identifiable {
    let native: String?
    let romanization: String?
    let translation: String?
    
    var id: String { native ?? UUID().uuidString }
}

struct Dialogue: Codable, Identifiable {
    let title: String?
    let context: String?
    let lines: [DialogueLine]?
    
    var id: String { title ?? UUID().uuidString }
}

struct DialogueLine: Codable, Identifiable {
    let speaker: String?
    let native: String?
    let romanization: String?
    let translation: String?
    
    var id: String { "\(speaker ?? "")_\(native ?? UUID().uuidString)" }
}

struct CulturalNote: Codable, Identifiable {
    let title: String?
    let content: String?
    let examples: [String]?
    
    var id: String { title ?? UUID().uuidString }
}

struct Exercise: Codable, Identifiable {
    let exerciseId: String?
    let exerciseType: String?
    let prompt: String?
    let correctAnswer: String?
    let options: [String]?
    let explanation: String?
    
    var id: String { exerciseId ?? UUID().uuidString }
    
    enum CodingKeys: String, CodingKey {
        case exerciseId = "exercise_id"
        case exerciseType = "exercise_type"
        case prompt
        case correctAnswer = "correct_answer"
        case options, explanation
    }
}

struct LessonPrerequisite: Codable {
    let lessonId: String
    let relationship: PrerequisiteRelationship
    let completionThreshold: Double?
    
    enum CodingKeys: String, CodingKey {
        case lessonId = "lesson_id"
        case relationship
        case completionThreshold = "completion_threshold"
    }
}

struct LessonMetadata: Codable {
    let proficiencyFramework: String?
    let topicTags: [String]?
    let sourceUnits: [SourceUnit]?
    
    enum CodingKeys: String, CodingKey {
        case proficiencyFramework = "proficiency_framework"
        case topicTags = "topic_tags"
        case sourceUnits = "source_units"
    }
}

struct SourceUnit: Codable {
    let source: String?
    let unitId: String?
    
    enum CodingKeys: String, CodingKey {
        case source
        case unitId = "unit_id"
    }
}

struct LessonProgress: Codable {
    var completionPercentage: Double?
    var masteryLevel: Double?
    var exercisesCompleted: Int?
    var lastStudied: Date?
    var isUnlocked: Bool?
    
    enum CodingKeys: String, CodingKey {
        case completionPercentage = "completion_percentage"
        case masteryLevel = "mastery_level"
        case exercisesCompleted = "exercises_completed"
        case lastStudied = "last_studied"
        case isUnlocked = "is_unlocked"
    }
}

// MARK: - Lesson Plan Models

struct LessonPlan: Codable {
    let planId: String
    let language: Language
    let version: String
    let metadata: PlanMetadata?
    let lessons: [Lesson]
    let learningPaths: [LearningPath]
    let difficultyLevels: [DifficultyLevelInfo]?
    let topicCategories: [TopicCategory]?
    
    enum CodingKeys: String, CodingKey {
        case planId = "plan_id"
        case language, version, metadata, lessons
        case learningPaths = "learning_paths"
        case difficultyLevels = "difficulty_levels"
        case topicCategories = "topic_categories"
    }
}

struct PlanMetadata: Codable {
    let createdAt: Date?
    let updatedAt: Date?
    let author: String?
    let description: String?
    let totalLessons: Int?
    let totalEstimatedHours: Double?
    
    enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case author, description
        case totalLessons = "total_lessons"
        case totalEstimatedHours = "total_estimated_hours"
    }
}

struct LearningPath: Codable, Identifiable {
    let pathId: String
    let name: String
    let description: String?
    let targetProficiency: String?
    let estimatedDurationWeeks: Int?
    let lessonSequence: [String]
    let milestones: [Milestone]?
    
    var id: String { pathId }
    
    enum CodingKeys: String, CodingKey {
        case pathId = "path_id"
        case name, description
        case targetProficiency = "target_proficiency"
        case estimatedDurationWeeks = "estimated_duration_weeks"
        case lessonSequence = "lesson_sequence"
        case milestones
    }
}

struct Milestone: Codable, Identifiable {
    let lessonIndex: Int?
    let title: String?
    let description: String?
    
    var id: String { "\(lessonIndex ?? 0)_\(title ?? UUID().uuidString)" }
    
    enum CodingKeys: String, CodingKey {
        case lessonIndex = "lesson_index"
        case title, description
    }
}

struct DifficultyLevelInfo: Codable, Identifiable {
    let levelId: String
    let name: String?
    let description: String?
    let proficiencyFramework: String?
    let lessonCount: Int?
    
    var id: String { levelId }
    
    enum CodingKeys: String, CodingKey {
        case levelId = "level_id"
        case name, description
        case proficiencyFramework = "proficiency_framework"
        case lessonCount = "lesson_count"
    }
}

struct TopicCategory: Codable, Identifiable {
    let categoryId: String
    let name: String?
    let description: String?
    let lessonIds: [String]?
    
    var id: String { categoryId }
    
    enum CodingKeys: String, CodingKey {
        case categoryId = "category_id"
        case name, description
        case lessonIds = "lesson_ids"
    }
}

// MARK: - Extensions

extension Lesson {
    var isLocked: Bool {
        return !(progress?.isUnlocked ?? false)
    }
    
    var completionPercentage: Double {
        return progress?.completionPercentage ?? 0.0
    }
    
    var isCompleted: Bool {
        return completionPercentage >= 90.0
    }
    
    var statusEmoji: String {
        if isCompleted { return "✅" }
        if isLocked { return "🔒" }
        if completionPercentage > 0 { return "📖" }
        return "⭐️"
    }
    
    var estimatedHours: Double {
        return Double(estimatedDurationMinutes ?? 30) / 60.0
    }
}

extension LessonPlan {
    func getLesson(byId id: String) -> Lesson? {
        return lessons.first { $0.lessonId == id }
    }
    
    func getLessons(byDifficulty difficulty: DifficultyLevel) -> [Lesson] {
        return lessons.filter { $0.difficultyLevel == difficulty }
    }
    
    func getLessons(byType type: LessonType) -> [Lesson] {
        return lessons.filter { $0.lessonType == type }
    }
    
    func getUnlockedLessons(userProgress: [String: LessonProgress]) -> [Lesson] {
        return lessons.filter { lesson in
            if lesson.prerequisites.isEmpty {
                return true
            }
            
            return lesson.prerequisites.allSatisfy { prereq in
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
        }
    }
    
    func getNextRecommendedLessons(userProgress: [String: LessonProgress], limit: Int = 5) -> [Lesson] {
        let unlocked = getUnlockedLessons(userProgress: userProgress)
        let notCompleted = unlocked.filter { lesson in
            let progress = userProgress[lesson.lessonId]
            return (progress?.completionPercentage ?? 0.0) < 90.0
        }
        
        let sorted = notCompleted.sorted { a, b in
            let progressA = userProgress[a.lessonId]?.completionPercentage ?? 0.0
            let progressB = userProgress[b.lessonId]?.completionPercentage ?? 0.0
            
            if a.difficultyLevel != b.difficultyLevel {
                return a.difficultyLevel.rawValue < b.difficultyLevel.rawValue
            }
            
            return progressA > progressB
        }
        
        return Array(sorted.prefix(limit))
    }
}
