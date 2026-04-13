import SwiftUI

struct SkillTreeView: View {
    @StateObject private var manager = SkillTreeManager()
    @State private var selectedTier: Int = 1
    
    var body: some View {
        NavigationView {
            VStack {
                if manager.isLoading {
                    ProgressView("Loading skill tree...")
                } else if let error = manager.error {
                    ErrorView(error: error)
                } else if let tree = manager.skillTree {
                    ScrollView {
                        VStack(spacing: 20) {
                            ProgressOverviewCard(manager: manager)
                            
                            TierSelector(selectedTier: $selectedTier, tiers: tree.tiers ?? [])
                            
                            SkillGridView(
                                skills: tree.getSkillsByTier(selectedTier),
                                manager: manager
                            )
                        }
                        .padding()
                    }
                } else {
                    Text("No skill tree loaded")
                }
            }
            .navigationTitle("Skill Tree")
            .task {
                await manager.loadTree(from: URL(string: "https://your-api.com/skill_tree.json")!)
            }
        }
    }
}

struct ProgressOverviewCard: View {
    @ObservedObject var manager: SkillTreeManager
    
    var body: some View {
        let stats = manager.getOverallProgress()
        
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Progress")
                .font(.headline)
            
            HStack(spacing: 20) {
                StatBadge(
                    icon: "✅",
                    label: "Mastered",
                    value: "\(stats.mastered)"
                )
                
                StatBadge(
                    icon: "📚",
                    label: "In Progress",
                    value: "\(stats.inProgress)"
                )
                
                StatBadge(
                    icon: "🔒",
                    label: "Locked",
                    value: "\(stats.locked)"
                )
            }
            
            ProgressView(
                value: Double(stats.mastered),
                total: Double(stats.totalSkills)
            )
            .tint(.green)
            
            Text("\(Int(Double(stats.mastered) / Double(stats.totalSkills) * 100))% Complete")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct StatBadge: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        VStack {
            Text(icon)
                .font(.title2)
            Text(value)
                .font(.title3)
                .bold()
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct TierSelector: View {
    @Binding var selectedTier: Int
    let tiers: [DifficultyTier]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(tiers, id: \.tier) { tier in
                    Button(action: {
                        selectedTier = tier.tier
                    }) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Tier \(tier.tier)")
                                .font(.caption)
                                .bold()
                            Text(tier.name ?? "")
                                .font(.caption2)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(selectedTier == tier.tier ? Color.blue : Color(.systemGray5))
                        .foregroundColor(selectedTier == tier.tier ? .white : .primary)
                        .cornerRadius(8)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct SkillGridView: View {
    let skills: [SkillNode]
    @ObservedObject var manager: SkillTreeManager
    
    let columns = [
        GridItem(.adaptive(minimum: 150))
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(skills) { skill in
                NavigationLink(destination: SkillDetailView(skill: skill, manager: manager)) {
                    SkillCard(skill: skill, manager: manager)
                }
            }
        }
    }
}

struct SkillCard: View {
    let skill: SkillNode
    @ObservedObject var manager: SkillTreeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(skill.statusEmoji)
                    .font(.title2)
                Spacer()
                Text("\(Int(skill.masteryPercentage))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(skill.title.en)
                .font(.headline)
                .lineLimit(2)
                .foregroundColor(.primary)
            
            if let native = skill.title.native {
                Text(native)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Label("\(skill.difficultyTier)", systemImage: "chart.bar.fill")
                    .font(.caption)
                Spacer()
                if let hours = skill.estimatedHours {
                    Text("\(String(format: "%.1f", hours))h")
                        .font(.caption)
                }
            }
            .foregroundColor(.secondary)
            
            if skill.isLocked {
                Text("🔒 Locked")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .opacity(skill.isLocked ? 0.6 : 1.0)
    }
}

struct SkillDetailView: View {
    let skill: SkillNode
    @ObservedObject var manager: SkillTreeManager
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(skill.statusEmoji)
                            .font(.largeTitle)
                        Spacer()
                        Text("Tier \(skill.difficultyTier)")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(4)
                    }
                    
                    Text(skill.title.en)
                        .font(.title)
                        .bold()
                    
                    if let native = skill.title.native {
                        Text(native)
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    
                    if let description = skill.description?.en {
                        Text(description)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
                
                ProgressView(
                    value: skill.progressTracking?.masteryLevel ?? 0.0,
                    total: 1.0
                ) {
                    Text("Mastery: \(Int(skill.masteryPercentage))%")
                        .font(.headline)
                }
                .tint(.green)
                
                if let objectives = skill.learningObjectives {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Learning Objectives")
                            .font(.headline)
                        ForEach(objectives, id: \.self) { objective in
                            HStack(alignment: .top) {
                                Text("•")
                                Text(objective)
                            }
                            .font(.body)
                        }
                    }
                }
                
                if let examples = skill.content?.examples {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Examples")
                            .font(.headline)
                        ForEach(examples.indices, id: \.self) { index in
                            ExampleCard(example: examples[index])
                        }
                    }
                }
                
                if !skill.prerequisites.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Prerequisites")
                            .font(.headline)
                        ForEach(skill.prerequisites, id: \.skillId) { prereq in
                            PrerequisiteRow(prereq: prereq, manager: manager)
                        }
                    }
                }
                
                Button(action: {
                    manager.completeExercise(for: skill.id, correct: true)
                }) {
                    Text("Practice This Skill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(skill.isLocked ? Color.gray : Color.blue)
                        .cornerRadius(12)
                }
                .disabled(skill.isLocked)
            }
            .padding()
        }
        .navigationTitle("Skill Details")
    }
}

struct ExampleCard: View {
    let example: Example
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let native = example.native {
                Text(native)
                    .font(.body)
                    .bold()
            }
            if let translation = example.translation {
                Text(translation)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            if let context = example.context {
                Text(context)
                    .font(.caption)
                    .italic()
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct PrerequisiteRow: View {
    let prereq: Prerequisite
    @ObservedObject var manager: SkillTreeManager
    
    var body: some View {
        HStack {
            let progress = manager.getSkillProgress(for: prereq.skillId)
            let mastery = progress?.masteryLevel ?? 0.0
            let threshold = prereq.masteryThreshold ?? 0.7
            let isMet = mastery >= threshold
            
            Image(systemName: isMet ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isMet ? .green : .gray)
            
            Text(prereq.skillId)
                .font(.body)
            
            Spacer()
            
            Text(prereq.relationship.rawValue.capitalized)
                .font(.caption)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(relationshipColor(prereq.relationship).opacity(0.2))
                .foregroundColor(relationshipColor(prereq.relationship))
                .cornerRadius(4)
        }
    }
    
    func relationshipColor(_ relationship: PrerequisiteRelationship) -> Color {
        switch relationship {
        case .required: return .red
        case .recommended: return .orange
        case .helpful: return .blue
        }
    }
}

struct ErrorView: View {
    let error: Error
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.red)
            Text("Error Loading Skill Tree")
                .font(.headline)
            Text(error.localizedDescription)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}
