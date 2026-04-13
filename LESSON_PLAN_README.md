# Comprehensive Lesson Plan System

A thorough, data-driven lesson plan system for Japanese learning with natural skill tree progression, built from real curriculum data.

## Overview

This system transforms raw learning data (Duolingo units, JLPT grammar, vocabulary databases) into a comprehensive, structured curriculum with:

- **342 Complete Lessons** organized by difficulty and topic
- **Natural Prerequisites** that unlock lessons based on completion
- **3 Curated Learning Paths** for different goals (12-36 weeks)
- **227+ Hours** of structured learning content
- **Mixed Content Types**: vocabulary, grammar, dialogues, cultural notes
- **Swift-Ready Models** for iOS/macOS integration

## What Makes This Different

### From Network to Curriculum

**Before**: Random network connections between 6,000+ vocabulary items and 500+ grammar patterns
**After**: 342 structured lessons with clear learning objectives, examples, and progression

### Data-Driven Design

Every lesson is built from actual learning data:
- **Duolingo Units**: 221 lessons based on proven Duolingo curriculum structure
- **JLPT Grammar**: 104 grammar-focused lessons organized by proficiency level
- **Thematic Vocabulary**: 17 vocabulary lessons grouped by part of speech and topic

### Natural Progression

Lessons unlock based on prerequisites:
- **396 prerequisite relationships** ensure proper skill building
- **Required** prerequisites block progress until mastered (70%+)
- **Recommended** prerequisites guide but don't block
- **Helpful** prerequisites provide context

## Quick Start

### Generate the Lesson Plan

```bash
python3 pipeline/build_lesson_plan.py
```

This creates `lesson_plan_output/lesson_plan.json` with all 342 lessons.

### Use in Swift

```swift
import SwiftUI

@main
struct MyApp: App {
    @StateObject private var manager = LessonPlanManager()
    
    var body: some Scene {
        WindowGroup {
            LessonPlanView()
                .environmentObject(manager)
                .task {
                    manager.loadLessonPlan(fromFile: "/path/to/lesson_plan.json")
                }
        }
    }
}
```

## Lesson Structure

Each lesson includes:

### Core Information
- **Title & Description**: Clear learning goals
- **Difficulty Level**: 8 levels from Absolute Beginner to Proficient
- **Lesson Type**: Foundation, Vocabulary Theme, Grammar Focus, Mixed Skills, etc.
- **Duration**: Estimated time to complete (25-45 minutes)

### Learning Content
- **Vocabulary**: Key words with readings, meanings, and example sentences
- **Grammar Points**: Patterns with explanations and usage examples
- **Dialogues**: Practice conversations with context
- **Cultural Notes**: Important cultural context and tips
- **Learning Objectives**: Clear outcomes for the lesson

### Progress Tracking
- **Prerequisites**: Required/recommended lessons
- **Unlocks**: Lessons that become available after completion
- **Progress**: Completion %, mastery level, exercises completed
- **Metadata**: JLPT level, topic tags, source units

## Example Lesson

```json
{
  "lesson_id": "lesson_s1_u1_order_food_75c34d71",
  "title": {
    "en": "Order food",
    "native": null
  },
  "difficulty_level": "absolute_beginner",
  "lesson_type": "mixed_skills",
  "estimated_duration_minutes": 38,
  "learning_objectives": [
    "Understand and use vocabulary related to: order food",
    "Communicate in situations involving: order food",
    "Recognize and respond to common phrases about: order food"
  ],
  "vocabulary": [
    {
      "word": "すし",
      "reading": "",
      "meaning": "Sushi, please.",
      "part_of_speech": "unknown",
      "example_sentence": "すし、ください。"
    }
  ],
  "grammar_points": [
    {
      "pattern": "Order food",
      "explanation": "Welcome to Japanese!",
      "examples": [
        {
          "native": "すし、ください。",
          "romanization": "",
          "translation": "Sushi, please."
        }
      ]
    }
  ],
  "dialogues": [
    {
      "title": "Order food - Practice Dialogue",
      "context": "Practicing order food",
      "lines": [
        {
          "speaker": "A",
          "native": "すし、ください。",
          "translation": "Sushi, please."
        }
      ]
    }
  ]
}
```

## Learning Paths

### 1. Beginner's Foundation (12 weeks)
- **Target**: JLPT N5 / CEFR A1
- **Lessons**: 20 carefully selected beginner lessons
- **Focus**: Essential basics, greetings, food, daily life
- **Milestones**:
  - Lesson 5: First Conversations
  - Lesson 10: Daily Life
  - Lesson 15: Getting Around

### 2. Intermediate Fluency (24 weeks)
- **Target**: JLPT N3 / CEFR B1
- **Lessons**: 30 elementary to pre-intermediate lessons
- **Focus**: Conversational fluency, complex grammar
- **Milestones**:
  - Lesson 10: Complex Conversations
  - Lesson 20: Nuanced Expression

### 3. Advanced Mastery (36 weeks)
- **Target**: JLPT N1 / CEFR C1
- **Lessons**: 40 intermediate to advanced lessons
- **Focus**: Professional competence, advanced patterns
- **Milestones**:
  - Lesson 15: Professional Communication
  - Lesson 30: Near-Native Fluency

## Difficulty Levels

| Level | Name | Lessons | Proficiency | Description |
|-------|------|---------|-------------|-------------|
| 1 | Absolute Beginner | 10 | JLPT N5 / CEFR A1 | First steps in Japanese |
| 2 | Beginner | 72 | JLPT N4 / CEFR A2 | Basic communication |
| 3 | Elementary | 135 | JLPT N3 / CEFR B1 | Everyday conversations |
| 4 | Pre-Intermediate | 85 | JLPT N3 / CEFR B1 | More complex topics |
| 5 | Intermediate | 40 | JLPT N2 / CEFR B2 | Comfortable in most situations |
| 6 | Advanced | 0 | JLPT N1 / CEFR C1 | Near-native fluency |

## Swift API Usage

### Loading the Lesson Plan

```swift
let manager = LessonPlanManager()

// From URL
await manager.loadLessonPlan(from: URL(string: "https://api.example.com/lesson_plan.json")!)

// From local file
manager.loadLessonPlan(fromFile: "/path/to/lesson_plan.json")
```

### Tracking Progress

```swift
// Update lesson completion
manager.updateLessonProgress(lessonId: "lesson_id", completion: 75.0)

// Complete an exercise
manager.completeExercise(lessonId: "lesson_id", correct: true)

// Mark lesson complete
manager.markLessonComplete(lessonId: "lesson_id")
```

### Querying Lessons

```swift
// Get unlocked lessons
let unlocked = manager.getUnlockedLessons()

// Get next recommended lessons
let next = manager.getNextRecommendedLessons(limit: 5)

// Get lessons by difficulty
let beginnerLessons = manager.getLessons(byDifficulty: .beginner)

// Get lessons by type
let grammarLessons = manager.getLessons(byType: .grammarFocus)
```

### Learning Paths

```swift
// Select a learning path
if let path = manager.lessonPlan?.learningPaths.first {
    manager.selectLearningPath(path)
}

// Get path progress
let (completed, total, percentage) = manager.getPathProgress()

// Get next lesson in path
if let nextLesson = manager.getNextLessonInPath() {
    print("Next: \(nextLesson.title.en)")
}
```

### Statistics

```swift
// Overall progress
let stats = manager.getOverallProgress()
print("Completed: \(stats.completed)/\(stats.totalLessons)")

// Difficulty progress
let (completed, total, pct) = manager.getDifficultyProgress(difficulty: .beginner)

// Study time
let hoursStudied = manager.getTotalStudyTime()
let hoursRemaining = manager.getEstimatedRemainingTime()
```

## Data Sources

The lesson plan consolidates data from:

1. **Duolingo Guidebook** (221 units)
   - 5 sections covering beginner to advanced
   - Structured progression with examples and tips
   - Cultural notes and explanations

2. **JLPT Grammar Database** (510 patterns)
   - JLPT N4: 131 patterns
   - JLPT N3: 182 patterns
   - JLPT N2: 197 patterns

3. **Vocabulary Database** (6,362 entries)
   - Organized by part of speech
   - Semantic topic groupings
   - Example sentences and readings

## Lesson Types

- **Foundation**: Core building blocks (hiragana, basic particles)
- **Vocabulary Theme**: Thematic word groups (food, family, time)
- **Grammar Focus**: Grammar pattern clusters by JLPT level
- **Mixed Skills**: Integrated lessons from Duolingo units
- **Conversation**: Dialogue-focused practice
- **Cultural**: Cultural context and etiquette
- **Review**: Consolidation and practice

## File Structure

```
pela-pela/
├── schemas/
│   ├── lesson.schema.json              # Lesson schema
│   └── lesson_plan.schema.json         # Complete plan schema
├── pipeline/
│   ├── analyze_lesson_data.py          # Data analysis tool
│   └── build_lesson_plan.py            # Lesson plan generator
├── swift_models/
│   ├── LessonPlanModels.swift          # Swift data models
│   └── LessonPlanManager.swift         # Manager with progress tracking
├── lesson_plan_output/
│   └── lesson_plan.json                # Generated 342-lesson plan
└── LESSON_PLAN_README.md               # This file
```

## Benefits

### For Learners
- ✅ Clear progression from beginner to advanced
- ✅ Structured lessons with specific goals
- ✅ Natural unlocking based on mastery
- ✅ Multiple learning paths for different goals
- ✅ Rich content: vocab, grammar, dialogues, culture

### For Developers
- ✅ Complete Swift models with Codable support
- ✅ Progress tracking and persistence
- ✅ Flexible querying and filtering
- ✅ JSON schema validation
- ✅ Easy integration with iOS/macOS apps

### For Educators
- ✅ Data-driven curriculum design
- ✅ Aligned with JLPT/CEFR standards
- ✅ Prerequisite enforcement
- ✅ Progress analytics
- ✅ Customizable learning paths

## Customization

### Adding New Lessons

Lessons can be added programmatically:

```python
new_lesson = {
    'lesson_id': generate_lesson_id('custom_lesson'),
    'title': {'en': 'Custom Lesson', 'native': None},
    'difficulty_level': 'beginner',
    'lesson_type': 'mixed_skills',
    # ... other fields
}
```

### Creating Custom Paths

```python
custom_path = {
    'path_id': 'custom_path',
    'name': 'My Learning Path',
    'lesson_sequence': ['lesson_1', 'lesson_2', 'lesson_3'],
    'estimated_duration_weeks': 8
}
```

### Modifying Prerequisites

Prerequisites can be adjusted to change the unlock flow:

```python
lesson['prerequisites'].append({
    'lesson_id': 'prerequisite_lesson_id',
    'relationship': 'required',
    'completion_threshold': 0.8
})
```

## Analytics & Insights

The system tracks:
- **Completion rates** by difficulty level
- **Time spent** per lesson and overall
- **Mastery levels** for each lesson
- **Path progress** with milestones
- **Unlock status** based on prerequisites

## Future Enhancements

Potential additions:
- **Spaced Repetition**: SRS algorithm for optimal review
- **Adaptive Difficulty**: Adjust based on performance
- **Exercise Generation**: Auto-generate practice from content
- **Audio Integration**: Add pronunciation guides
- **Gamification**: Points, streaks, achievements
- **Social Features**: Study groups, leaderboards

## License

This lesson plan system is part of the PelaPela project. See main README for licensing details.

---

**Total Learning Content**: 342 lessons, 227+ hours, 3 learning paths
**Built from**: 221 Duolingo units, 510 JLPT grammar patterns, 6,362 vocabulary entries
**Ready for**: iOS, macOS, web, or any platform supporting JSON
