import Foundation

// MARK: - API Client

class PelaPelaAPIClient {
    let baseURL: String
    let session: URLSession
    
    init(baseURL: String = "https://pelapela-api.workers.dev") {
        self.baseURL = baseURL
        self.session = URLSession.shared
    }
    
    // MARK: - Network
    
    func getNetworkNodes(limit: Int = 100, offset: Int = 0, type: String? = nil) async throws -> NetworkNodesResponse {
        var components = URLComponents(string: "\(baseURL)/api/network/nodes")!
        components.queryItems = [
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "offset", value: "\(offset)")
        ]
        if let type = type {
            components.queryItems?.append(URLQueryItem(name: "type", value: type))
        }
        
        let (data, _) = try await session.data(from: components.url!)
        return try JSONDecoder().decode(NetworkNodesResponse.self, from: data)
    }
    
    func getFullNetwork() async throws -> FullNetworkResponse {
        let url = URL(string: "\(baseURL)/api/network/full")!
        let (data, _) = try await session.data(from: url)
        return try JSONDecoder().decode(FullNetworkResponse.self, from: data)
    }
    
    // MARK: - Skill Tree
    
    func getSkillTree() async throws -> SkillTree {
        let url = URL(string: "\(baseURL)/api/skill-tree")!
        let (data, _) = try await session.data(from: url)
        return try JSONDecoder().decode(SkillTree.self, from: data)
    }
    
    func getSkillNode(id: String) async throws -> SkillNode {
        let url = URL(string: "\(baseURL)/api/skill-tree/node/\(id)")!
        let (data, _) = try await session.data(from: url)
        return try JSONDecoder().decode(SkillNode.self, from: data)
    }
    
    // MARK: - Lessons
    
    func getLessons(difficulty: String? = nil, type: String? = nil, limit: Int = 50, offset: Int = 0) async throws -> LessonsResponse {
        var components = URLComponents(string: "\(baseURL)/api/lessons")!
        components.queryItems = [
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "offset", value: "\(offset)")
        ]
        if let difficulty = difficulty {
            components.queryItems?.append(URLQueryItem(name: "difficulty", value: difficulty))
        }
        if let type = type {
            components.queryItems?.append(URLQueryItem(name: "type", value: type))
        }
        
        let (data, _) = try await session.data(from: components.url!)
        return try JSONDecoder().decode(LessonsResponse.self, from: data)
    }
    
    func getLesson(id: String) async throws -> Lesson {
        let url = URL(string: "\(baseURL)/api/lessons/\(id)")!
        let (data, _) = try await session.data(from: url)
        return try JSONDecoder().decode(Lesson.self, from: data)
    }
    
    func getLearningPaths() async throws -> LearningPathsResponse {
        let url = URL(string: "\(baseURL)/api/learning-paths")!
        let (data, _) = try await session.data(from: url)
        return try JSONDecoder().decode(LearningPathsResponse.self, from: data)
    }
    
    // MARK: - Vocabulary & Grammar
    
    func getVocabulary(pos: String? = nil, limit: Int = 100, offset: Int = 0) async throws -> VocabularyResponse {
        var components = URLComponents(string: "\(baseURL)/api/vocabulary")!
        components.queryItems = [
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "offset", value: "\(offset)")
        ]
        if let pos = pos {
            components.queryItems?.append(URLQueryItem(name: "pos", value: pos))
        }
        
        let (data, _) = try await session.data(from: components.url!)
        return try JSONDecoder().decode(VocabularyResponse.self, from: data)
    }
    
    func getGrammar(level: String? = nil, limit: Int = 100, offset: Int = 0) async throws -> GrammarResponse {
        var components = URLComponents(string: "\(baseURL)/api/grammar")!
        components.queryItems = [
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "offset", value: "\(offset)")
        ]
        if let level = level {
            components.queryItems?.append(URLQueryItem(name: "level", value: level))
        }
        
        let (data, _) = try await session.data(from: components.url!)
        return try JSONDecoder().decode(GrammarResponse.self, from: data)
    }
}

// MARK: - Response Models

struct Pagination: Codable {
    let total: Int
    let limit: Int
    let offset: Int
    let hasMore: Bool
    
    enum CodingKeys: String, CodingKey {
        case total, limit, offset
        case hasMore = "hasMore"
    }
}

struct NetworkNodesResponse: Codable {
    let data: [NetworkNode]
    let pagination: Pagination
}

struct NetworkNode: Codable {
    let id: String
    let label: String
    let type: String
}

struct FullNetworkResponse: Codable {
    let nodes: [NetworkNode]
    let edges: [NetworkEdge]
    let metadata: NetworkMetadata
}

struct NetworkEdge: Codable {
    let source: String
    let target: String
    let relation: String
    let weight: Double
}

struct NetworkMetadata: Codable {
    let nodeCount: Int
    let edgeCount: Int
    let generated: String
    
    enum CodingKeys: String, CodingKey {
        case nodeCount, edgeCount, generated
    }
}

struct LessonsResponse: Codable {
    let data: [Lesson]
    let pagination: Pagination
    let metadata: LessonPlanMetadata?
}

struct Lesson: Codable {
    let lessonId: String
    let title: LocalizedText
    let difficultyLevel: String
    let lessonType: String
    
    enum CodingKeys: String, CodingKey {
        case lessonId = "lesson_id"
        case title
        case difficultyLevel = "difficulty_level"
        case lessonType = "lesson_type"
    }
}

struct LocalizedText: Codable {
    let en: String
    let native: String?
}

struct LessonPlanMetadata: Codable {
    let totalLessons: Int?
    let totalEstimatedHours: Double?
    
    enum CodingKeys: String, CodingKey {
        case totalLessons = "total_lessons"
        case totalEstimatedHours = "total_estimated_hours"
    }
}

struct LearningPathsResponse: Codable {
    let paths: [LearningPath]
    let difficultyLevels: [DifficultyLevel]?
    let topicCategories: [TopicCategory]?
    
    enum CodingKeys: String, CodingKey {
        case paths
        case difficultyLevels = "difficulty_levels"
        case topicCategories = "topic_categories"
    }
}

struct LearningPath: Codable {
    let pathId: String
    let name: String
    let description: String?
    
    enum CodingKeys: String, CodingKey {
        case pathId = "path_id"
        case name, description
    }
}

struct DifficultyLevel: Codable {
    let levelId: String
    let name: String?
    
    enum CodingKeys: String, CodingKey {
        case levelId = "level_id"
        case name
    }
}

struct TopicCategory: Codable {
    let categoryId: String
    let name: String?
    
    enum CodingKeys: String, CodingKey {
        case categoryId = "category_id"
        case name
    }
}

struct VocabularyResponse: Codable {
    let data: [VocabularyEntry]
    let pagination: Pagination
}

struct VocabularyEntry: Codable {
    let id: String
    let lemma: String
    let meanings: [String]
}

struct GrammarResponse: Codable {
    let data: [GrammarPattern]
    let pagination: Pagination
}

struct GrammarPattern: Codable {
    let id: String
    let title: String
    let description: String
}

// MARK: - Usage Example

func exampleUsage() async {
    let client = PelaPelaAPIClient()
    
    do {
        // Get beginner lessons
        let lessons = try await client.getLessons(difficulty: "beginner", limit: 10)
        print("Found \(lessons.data.count) beginner lessons")
        
        // Get learning paths
        let paths = try await client.getLearningPaths()
        print("Available paths: \(paths.paths.count)")
        
        // Get vocabulary
        let vocab = try await client.getVocabulary(pos: "Noun", limit: 20)
        print("Found \(vocab.data.count) nouns")
        
    } catch {
        print("Error: \(error)")
    }
}
