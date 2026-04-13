import Foundation

struct SkillNode: Codable, Identifiable {
    let id: String
    let skillType: SkillType
    let title: LocalizedText
    let description: LocalizedText?
    let difficultyTier: Int
    let estimatedHours: Double?
    let prerequisites: [Prerequisite]
    let unlocks: [String]
    let learningObjectives: [String]?
    let content: SkillContent?
    let metadata: SkillMetadata?
    var progressTracking: ProgressTracking?
    
    enum CodingKeys: String, CodingKey {
        case id
        case skillType = "skill_type"
        case title
        case description
        case difficultyTier = "difficulty_tier"
        case estimatedHours = "estimated_hours"
        case prerequisites
        case unlocks
        case learningObjectives = "learning_objectives"
        case content
        case metadata
        case progressTracking = "progress_tracking"
    }
}

enum SkillType: String, Codable {
    case foundation
    case grammar
    case vocabulary
    case phrase
    case conversation
    case cultural
    case advanced
}

struct LocalizedText: Codable {
    let en: String
    let native: String?
}

struct Prerequisite: Codable {
    let skillId: String
    let relationship: PrerequisiteRelationship
    let masteryThreshold: Double?
    
    enum CodingKeys: String, CodingKey {
        case skillId = "skill_id"
        case relationship
        case masteryThreshold = "mastery_threshold"
    }
}

enum PrerequisiteRelationship: String, Codable {
    case required
    case recommended
    case helpful
}

struct SkillContent: Codable {
    let examples: [Example]?
    let explanations: [Explanation]?
    let practiceExercises: [PracticeExercise]?
    
    enum CodingKeys: String, CodingKey {
        case examples
        case explanations
        case practiceExercises = "practice_exercises"
    }
}

struct Example: Codable {
    let native: String?
    let romanization: String?
    let translation: String?
    let context: String?
    let audioUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case native
        case romanization
        case translation
        case context
        case audioUrl = "audio_url"
    }
}

struct Explanation: Codable {
    let title: String?
    let content: String?
    let type: ExplanationType?
}

enum ExplanationType: String, Codable {
    case rule
    case tip
    case culturalNote = "cultural_note"
    case commonMistake = "common_mistake"
}

struct PracticeExercise: Codable {
    let exerciseType: ExerciseType?
    let prompt: String?
    let correctAnswer: String?
    let distractors: [String]?
    
    enum CodingKeys: String, CodingKey {
        case exerciseType = "exercise_type"
        case prompt
        case correctAnswer = "correct_answer"
        case distractors
    }
}

enum ExerciseType: String, Codable {
    case multipleChoice = "multiple_choice"
    case fillBlank = "fill_blank"
    case translation
    case listening
    case speaking
}

struct SkillMetadata: Codable {
    let tags: [String]?
    let proficiencyFramework: String?
    let topicAreas: [String]?
    let partOfSpeech: String?
    
    enum CodingKeys: String, CodingKey {
        case tags
        case proficiencyFramework = "proficiency_framework"
        case topicAreas = "topic_areas"
        case partOfSpeech = "part_of_speech"
    }
}

struct ProgressTracking: Codable {
    var masteryLevel: Double?
    var lastPracticed: Date?
    var practiceCount: Int?
    var isUnlocked: Bool?
    
    enum CodingKeys: String, CodingKey {
        case masteryLevel = "mastery_level"
        case lastPracticed = "last_practiced"
        case practiceCount = "practice_count"
        case isUnlocked = "is_unlocked"
    }
}

struct SkillTree: Codable {
    let treeId: String
    let language: Language
    let version: String
    let metadata: TreeMetadata?
    let nodes: [SkillNode]
    let pathways: [LearningPathway]
    let tiers: [DifficultyTier]?
    
    enum CodingKeys: String, CodingKey {
        case treeId = "tree_id"
        case language
        case version
        case metadata
        case nodes
        case pathways
        case tiers
    }
}

struct Language: Codable {
    let code: String
    let name: String
    let nativeName: String?
    
    enum CodingKeys: String, CodingKey {
        case code
        case name
        case nativeName = "native_name"
    }
}

struct TreeMetadata: Codable {
    let createdAt: Date?
    let updatedAt: Date?
    let author: String?
    let description: String?
    let totalEstimatedHours: Double?
    
    enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case author
        case description
        case totalEstimatedHours = "total_estimated_hours"
    }
}

struct LearningPathway: Codable, Identifiable {
    let pathwayId: String
    let name: String
    let description: String?
    let targetProficiency: String?
    let estimatedDurationWeeks: Int?
    let skillSequence: [String]
    
    var id: String { pathwayId }
    
    enum CodingKeys: String, CodingKey {
        case pathwayId = "pathway_id"
        case name
        case description
        case targetProficiency = "target_proficiency"
        case estimatedDurationWeeks = "estimated_duration_weeks"
        case skillSequence = "skill_sequence"
    }
}

struct DifficultyTier: Codable {
    let tier: Int
    let name: String?
    let description: String?
    let proficiencyLevel: String?
    
    enum CodingKeys: String, CodingKey {
        case tier
        case name
        case description
        case proficiencyLevel = "proficiency_level"
    }
}

extension SkillTree {
    func getUnlockedSkills(userProgress: [String: ProgressTracking]) -> [SkillNode] {
        return nodes.filter { node in
            if node.prerequisites.isEmpty {
                return true
            }
            
            return node.prerequisites.allSatisfy { prereq in
                guard let progress = userProgress[prereq.skillId] else {
                    return prereq.relationship != .required
                }
                
                let threshold = prereq.masteryThreshold ?? 0.7
                let mastery = progress.masteryLevel ?? 0.0
                
                switch prereq.relationship {
                case .required:
                    return mastery >= threshold
                case .recommended:
                    return true
                case .helpful:
                    return true
                }
            }
        }
    }
    
    func getSkillsByTier(_ tier: Int) -> [SkillNode] {
        return nodes.filter { $0.difficultyTier == tier }
    }
    
    func getSkillsByType(_ type: SkillType) -> [SkillNode] {
        return nodes.filter { $0.skillType == type }
    }
    
    func getNextRecommendedSkills(userProgress: [String: ProgressTracking], limit: Int = 5) -> [SkillNode] {
        let unlocked = getUnlockedSkills(userProgress: userProgress)
        let notMastered = unlocked.filter { node in
            let progress = userProgress[node.id]
            let mastery = progress?.masteryLevel ?? 0.0
            return mastery < 0.9
        }
        
        let sorted = notMastered.sorted { a, b in
            let progressA = userProgress[a.id]?.masteryLevel ?? 0.0
            let progressB = userProgress[b.id]?.masteryLevel ?? 0.0
            
            if a.difficultyTier != b.difficultyTier {
                return a.difficultyTier < b.difficultyTier
            }
            
            return progressA > progressB
        }
        
        return Array(sorted.prefix(limit))
    }
}
