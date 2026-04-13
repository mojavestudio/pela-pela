# Natural Skill Tree System

A language-agnostic skill tree framework designed for natural learning progression, with full Swift frontend support.

## Overview

This system transforms traditional language learning networks into intuitive skill trees with:

- **Natural Prerequisites**: Skills unlock based on mastery of foundational concepts
- **Progressive Difficulty**: 10-tier system from absolute beginner to native-level mastery
- **Multiple Learning Paths**: Curated pathways for different goals and timelines
- **Language-Agnostic Design**: Works with any language (Japanese, Spanish, French, etc.)
- **Swift-Ready**: Complete Swift models and API for iOS/macOS apps

## Key Improvements Over Original Network

### 1. **Natural Progression**
- **Before**: Random connections based on JLPT levels and tags
- **After**: Intelligent prerequisite chains that mirror real learning progression
- Foundation skills unlock vocabulary → vocabulary unlocks grammar → grammar enables conversation

### 2. **Clear Difficulty Tiers**
- **Before**: Flat "Level 1" for everything
- **After**: 10 progressive tiers aligned with international standards (JLPT, CEFR)

### 3. **Actionable Learning Paths**
- **Before**: No guidance on what to learn next
- **After**: Curated pathways (Beginner's Journey, Intermediate Mastery, Advanced Proficiency)

### 4. **Progress Tracking**
- **Before**: Static network visualization
- **After**: Dynamic mastery levels, unlock states, practice tracking

### 5. **Swift Integration**
- **Before**: Web-only visualization
- **After**: Native Swift models with Codable support, ready for iOS/macOS apps

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Skill Tree System                        │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────┐      ┌──────────────┐                    │
│  │ Raw Data     │─────▶│ Skill Tree   │                    │
│  │ (JLPT, etc.) │      │ Generator    │                    │
│  └──────────────┘      └──────┬───────┘                    │
│                               │                             │
│                               ▼                             │
│                    ┌──────────────────┐                    │
│                    │  skill_tree.json │                    │
│                    └────────┬─────────┘                    │
│                             │                               │
│              ┌──────────────┼──────────────┐               │
│              ▼              ▼              ▼               │
│         ┌────────┐    ┌─────────┐    ┌────────┐          │
│         │  Web   │    │  Swift  │    │  API   │          │
│         │  App   │    │   App   │    │ Server │          │
│         └────────┘    └─────────┘    └────────┘          │
└─────────────────────────────────────────────────────────────┘
```

## Quick Start

### 1. Generate Skill Tree

```bash
# Run the skill tree builder
python3 pipeline/build_skill_tree.py
```

This creates `skill_tree_output/skill_tree.json` with:
- 500+ skill nodes
- Natural prerequisite relationships
- 3 curated learning pathways
- 10 difficulty tiers

### 2. Use in Swift

```swift
import SwiftUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            SkillTreeView()
        }
    }
}
```

The `SkillTreeView` provides a complete UI with:
- Progress overview dashboard
- Tier-based skill browsing
- Detailed skill pages with examples
- Automatic unlock management
- Progress persistence

## Data Schema

### Skill Node

Each skill represents a learnable concept:

```json
{
  "id": "vocabulary_hello_a1b2c3d4",
  "skill_type": "vocabulary",
  "title": {
    "en": "Hello",
    "native": "こんにちは"
  },
  "difficulty_tier": 1,
  "estimated_hours": 0.5,
  "prerequisites": [],
  "unlocks": ["vocabulary_goodbye_e5f6g7h8"],
  "learning_objectives": [
    "Recognize and use 'Hello' in context",
    "Understand the meaning: greeting"
  ],
  "content": {
    "examples": [
      {
        "native": "こんにちは、元気ですか？",
        "translation": "Hello, how are you?"
      }
    ]
  },
  "metadata": {
    "proficiency_framework": "JLPT N5",
    "topic_areas": ["greetings"]
  }
}
```

### Prerequisites

Three relationship types control skill unlocking:

- **Required** (0.7 mastery): Must complete before unlocking
- **Recommended** (0.5 mastery): Helpful but not blocking
- **Helpful** (0.4 mastery): Nice to have, doesn't block

### Progress Tracking

```json
{
  "mastery_level": 0.75,
  "last_practiced": "2024-04-03T08:55:00Z",
  "practice_count": 12,
  "is_unlocked": true
}
```

## Difficulty Tiers

| Tier | Name | Proficiency | Description |
|------|------|-------------|-------------|
| 1 | Absolute Beginner | JLPT N5 / CEFR A1 | First steps in the language |
| 2 | Beginner | JLPT N4 / CEFR A1-A2 | Basic communication skills |
| 3 | Elementary | CEFR A2 | Everyday conversations |
| 4 | Pre-Intermediate | JLPT N3 / CEFR B1 | More complex topics |
| 5 | Intermediate | CEFR B1-B2 | Comfortable in most situations |
| 6 | Upper-Intermediate | JLPT N2 / CEFR B2 | Nuanced expression |
| 7 | Advanced | CEFR C1 | Near-native fluency |
| 8 | Proficient | JLPT N1 / CEFR C1 | Professional competence |
| 9 | Expert | CEFR C2 | Specialized mastery |
| 10 | Native-Level | CEFR C2+ | Complete mastery |

## Learning Pathways

### Beginner's Journey
- **Target**: JLPT N4 / CEFR A2
- **Duration**: 24 weeks
- **Focus**: Foundation skills, basic vocabulary, essential grammar

### Intermediate Mastery
- **Target**: JLPT N3 / CEFR B1
- **Duration**: 36 weeks
- **Focus**: Conversational fluency, complex grammar, topic-specific vocabulary

### Advanced Proficiency
- **Target**: JLPT N1 / CEFR C1
- **Duration**: 52 weeks
- **Focus**: Professional competence, cultural nuances, specialized topics

## Swift API Usage

### Loading the Skill Tree

```swift
let manager = SkillTreeManager()

// From URL
await manager.loadTree(from: URL(string: "https://api.example.com/skill_tree.json")!)

// From local file
manager.loadTree(fromFile: "/path/to/skill_tree.json")
```

### Tracking Progress

```swift
// Update mastery level
manager.updateProgress(for: "skill_id", mastery: 0.8)

// Record exercise completion
manager.completeExercise(for: "skill_id", correct: true)

// Get recommended next skills
let nextSkills = manager.getNextRecommendedSkills(limit: 5)
```

### Querying Skills

```swift
// Get all unlocked skills
let unlocked = manager.getUnlockedSkills()

// Get skills by tier
let tier1Skills = skillTree.getSkillsByTier(1)

// Get skills by type
let grammarSkills = skillTree.getSkillsByType(.grammar)

// Get tier progress
let (completed, total, percentage) = manager.getTierProgress(tier: 3)
```

### Overall Progress

```swift
let stats = manager.getOverallProgress()
print("Total: \(stats.totalSkills)")
print("Mastered: \(stats.mastered)")
print("In Progress: \(stats.inProgress)")
print("Locked: \(stats.locked)")
```

## Adapting to Other Languages

The system is designed to work with any language. To create a skill tree for Spanish, French, etc.:

1. **Update language metadata**:
```python
skill_tree = {
    "tree_id": "spanish_skill_tree_v1",
    "language": {
        "code": "es",
        "name": "Spanish",
        "native_name": "Español"
    },
    # ... rest of tree
}
```

2. **Adjust tier mappings** (if using different proficiency frameworks):
```python
CEFR_TO_TIER = {
    "A1": 1,
    "A2": 3,
    "B1": 5,
    "B2": 6,
    "C1": 8,
    "C2": 9,
}
```

3. **Customize skill types** (if needed):
```python
# Add language-specific types
skill_types = ["foundation", "grammar", "vocabulary", "pronunciation", "idioms"]
```

## API Endpoints (Optional)

If hosting the skill tree as a web service:

```
GET  /api/v1/skill-tree/{language_code}
GET  /api/v1/skill-tree/{language_code}/nodes
GET  /api/v1/skill-tree/{language_code}/pathways
GET  /api/v1/skill-tree/{language_code}/tiers
POST /api/v1/progress/sync
```

## File Structure

```
pela-pela/
├── schemas/
│   ├── skill_node.schema.json       # Skill node JSON schema
│   └── skill_tree.schema.json       # Complete tree schema
├── pipeline/
│   └── build_skill_tree.py          # Skill tree generator
├── swift_models/
│   ├── SkillTreeModels.swift        # Swift data models
│   ├── SkillTreeAPI.swift           # API client & manager
│   └── ExampleViews.swift           # SwiftUI example views
├── skill_tree_output/
│   └── skill_tree.json              # Generated skill tree
└── SKILL_TREE_README.md             # This file
```

## Benefits

### For Learners
- ✅ Clear progression path
- ✅ Visible progress tracking
- ✅ Automatic skill unlocking
- ✅ Personalized recommendations
- ✅ Estimated time commitments

### For Developers
- ✅ Language-agnostic design
- ✅ Swift-ready models
- ✅ JSON schema validation
- ✅ Extensible architecture
- ✅ Progress persistence

### For Educators
- ✅ Curated learning pathways
- ✅ Difficulty-based organization
- ✅ Learning objective tracking
- ✅ Prerequisite enforcement
- ✅ Analytics-ready structure

## Next Steps

1. **Generate your skill tree**: `python3 pipeline/build_skill_tree.py`
2. **Integrate Swift models**: Copy `swift_models/` into your Xcode project
3. **Customize pathways**: Edit pathway definitions in `build_skill_tree.py`
4. **Add content**: Enhance nodes with more examples, exercises, and explanations
5. **Deploy**: Host `skill_tree.json` on your API server or bundle with app

## License

This skill tree system is part of the PelaPela project. See main README for licensing details.
