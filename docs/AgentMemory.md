# PelaPela - Agent Memory

## Project Overview
Japanese learning network transformed into a natural, language-agnostic skill tree system with Swift frontend support.

## Current State (April 3, 2026)

### ✅ Completed Work

#### 1. Natural Skill Tree System
- **Created language-agnostic schemas** (`schemas/skill_node.schema.json`, `schemas/skill_tree.schema.json`)
- **Built skill tree generator** (`pipeline/build_skill_tree.py`)
- **Generated working skill tree** with 500 nodes (250 grammar + 250 vocabulary)
- **Implemented natural prerequisites** - 250 nodes have prerequisite relationships
- **10-tier difficulty system** aligned with JLPT/CEFR standards

#### 2. Swift Integration
- **Complete Swift models** (`swift_models/SkillTreeModels.swift`)
  - Codable support for all data structures
  - Enums for skill types, relationships, exercise types
  - Full type safety
- **API client & manager** (`swift_models/SkillTreeAPI.swift`)
  - Progress tracking with UserDefaults persistence
  - Automatic skill unlocking based on prerequisites
  - Mastery level calculations
  - Recommended skills algorithm
- **Example SwiftUI views** (`swift_models/ExampleViews.swift`)
  - Complete skill tree browser
  - Progress dashboard
  - Skill detail pages
  - Tier selector
  - Practice integration

#### 3. Documentation
- **Comprehensive README** (`SKILL_TREE_README.md`)
- **Learning pathways** (Beginner's Journey, Intermediate Mastery, Advanced Proficiency)
- **Usage examples** for Swift integration

### Key Improvements Over Original Network

| Aspect | Before | After |
|--------|--------|-------|
| **Structure** | Flat network with random connections | Hierarchical skill tree with natural progression |
| **Difficulty** | Single "Level 1" for everything | 10 progressive tiers (Beginner → Native) |
| **Prerequisites** | None | Intelligent prerequisite chains (required/recommended/helpful) |
| **Learning Paths** | No guidance | 3 curated pathways with time estimates |
| **Progress** | Static visualization | Dynamic mastery tracking with unlocks |
| **Platform** | Web-only | Swift-ready for iOS/macOS |
| **Language Support** | Japanese-specific | Language-agnostic design |

### Generated Skill Tree Stats
- **Total nodes**: 500 (250 grammar + 250 vocabulary)
- **Nodes with prerequisites**: 250 (50%)
- **Average prerequisites per node**: 0.61
- **Total estimated learning hours**: 566.3 hours
- **Tier distribution**: Tier 3 (250), Tier 4 (53), Tier 6 (197)
- **Pathways**: 3 curated learning paths

### File Structure
```
pela-pela/
├── schemas/
│   ├── skill_node.schema.json          # NEW: Skill node schema
│   ├── skill_tree.schema.json          # NEW: Complete tree schema
│   ├── grammar_pattern.schema.json     # Original
│   └── vocabulary_entry.schema.json    # Original
├── pipeline/
│   ├── build_skill_tree.py             # NEW: Natural skill tree generator
│   ├── build_network.py                # Original network builder
│   └── data_pipeline.py                # Original data processor
├── swift_models/                        # NEW: Swift integration
│   ├── SkillTreeModels.swift           # Data models
│   ├── SkillTreeAPI.swift              # API client & manager
│   └── ExampleViews.swift              # SwiftUI examples
├── skill_tree_output/                   # NEW: Generated skill tree
│   └── skill_tree.json                 # 500-node skill tree
├── network_output/                      # Original network output
│   ├── nodes.json
│   ├── edges.json
│   └── index.html
├── SKILL_TREE_README.md                # NEW: Comprehensive documentation
└── README.md                           # Original project README
```

## Design Decisions

### 1. Prerequisite Relationships
- **Required** (0.7 mastery): Blocks skill unlock until mastered
- **Recommended** (0.5 mastery): Suggested but not blocking
- **Helpful** (0.4 mastery): Nice to have, doesn't block

### 2. Tier Mapping
- JLPT N5 → Tier 1 (Absolute Beginner)
- JLPT N4 → Tier 2 (Beginner)
- JLPT N3 → Tier 4 (Pre-Intermediate)
- JLPT N2 → Tier 6 (Upper-Intermediate)
- JLPT N1 → Tier 8 (Proficient)

### 3. Skill Types
- **Foundation**: Basic building blocks
- **Grammar**: Grammar patterns and structures
- **Vocabulary**: Words and phrases
- **Phrase**: Common expressions
- **Conversation**: Dialogue skills
- **Cultural**: Cultural context
- **Advanced**: Specialized topics

### 4. Natural Progression Logic
- Tier 1 skills have no prerequisites (entry points)
- Tier 2+ requires mastery of previous tier same-type skills
- Grammar skills benefit from vocabulary prerequisites
- Vocabulary skills benefit from grammar prerequisites
- Creates natural learning flow

## Usage

### Generate Skill Tree
```bash
python3 pipeline/build_skill_tree.py
```

### Swift Integration
```swift
let manager = SkillTreeManager()
await manager.loadTree(from: url)
let nextSkills = manager.getNextRecommendedSkills(limit: 5)
```

## Adapting to Other Languages

1. Update language metadata in `build_skill_tree.py`
2. Adjust tier mappings for different proficiency frameworks (CEFR, HSK, etc.)
3. Customize skill types if needed
4. Run generator with new data

## Comprehensive Lesson Plan System (April 3, 2026)

### ✅ Major Addition: Complete Curriculum

Built a thorough, data-driven lesson plan system that consolidates all learning data into structured lessons:

#### Generated Content
- **342 Complete Lessons** with full learning content
- **227+ Hours** of structured curriculum
- **3 Curated Learning Paths** (12-36 weeks)
- **396 Prerequisite Relationships** for natural progression

#### Lesson Breakdown
- **221 Duolingo-based lessons**: From proven curriculum structure
- **104 Grammar-focused lessons**: Organized by JLPT level (N4, N3, N2)
- **17 Vocabulary-themed lessons**: Grouped by part of speech

#### Difficulty Distribution
- Absolute Beginner: 10 lessons
- Beginner: 72 lessons
- Elementary: 135 lessons
- Pre-Intermediate: 85 lessons
- Intermediate: 40 lessons

#### Each Lesson Includes
- **Vocabulary**: Words with readings, meanings, examples
- **Grammar Points**: Patterns with explanations and usage
- **Dialogues**: Practice conversations with context
- **Cultural Notes**: Important cultural context
- **Learning Objectives**: Clear, measurable outcomes
- **Prerequisites**: Required/recommended prior lessons
- **Progress Tracking**: Completion %, mastery, exercises

#### Swift Integration
- `LessonPlanModels.swift`: Complete data models
- `LessonPlanManager.swift`: Progress tracking, querying, path management
- Full Codable support for JSON serialization
- UserDefaults persistence

#### Files Created
```
schemas/
  ├── lesson.schema.json
  └── lesson_plan.schema.json
pipeline/
  ├── analyze_lesson_data.py
  └── build_lesson_plan.py
swift_models/
  ├── LessonPlanModels.swift
  └── LessonPlanManager.swift
lesson_plan_output/
  └── lesson_plan.json (342 lessons)
LESSON_PLAN_README.md
```

## Next Steps (If Continuing)

1. **Add practice exercises**: Generate exercises from lesson content
2. **Implement spaced repetition**: SRS algorithm for optimal review
3. **Add audio/pronunciation**: Integrate audio for all examples
4. **Create API server**: REST API for lesson plan distribution
5. **Build iOS app**: Full native app using Swift models
6. **Add gamification**: Achievements, streaks, leaderboards
7. **Multi-language support**: Expand to Spanish, French, Chinese, etc.

## Known Limitations

### Skill Tree System
- Current implementation uses first 250 grammar + 250 vocab items
- Prerequisites are simplified (could be more sophisticated)
- Tier distribution is uneven (most items in tiers 3, 4, 6)

### Lesson Plan System
- Vocabulary extraction from examples is basic (regex-based)
- Some lessons lack romanization (data quality issue)
- Exercise generation not yet implemented
- No audio files yet (schema ready)

## Technical Notes

- All schemas use JSON Schema Draft 2020-12
- Swift models use Codable for automatic JSON serialization
- Progress tracking persists to UserDefaults
- ISO 8601 date format for timestamps
- Mastery/completion levels are 0.0-1.0 (0-100%)
- Lesson plan consolidates 3 data sources (Duolingo, JLPT, Vocabulary DB)
