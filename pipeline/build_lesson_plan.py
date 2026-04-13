#!/usr/bin/env python3
"""
Build comprehensive lesson plans from existing Japanese learning data.
Consolidates vocabulary, grammar, and Duolingo content into logical skill tree progressions.
"""
from __future__ import annotations
import json
from pathlib import Path
from typing import Any, Dict, List, Set, Tuple
from collections import defaultdict
from datetime import datetime
import hashlib
import re

ROOT = Path(__file__).resolve().parents[1]
DATA_CLEAN = ROOT / "data" / "clean"
DATA_RAW = ROOT / "data" / "raw"
OUT_DIR = ROOT / "lesson_plan_output"
OUT_DIR.mkdir(exist_ok=True)

DIFFICULTY_MAPPING = {
    "beginner": "absolute_beginner",
    "elementary": "beginner",
    "intermediate": "elementary",
    "advanced": "pre_intermediate",
}

JLPT_TO_DIFFICULTY = {
    "JLPT N5": "absolute_beginner",
    "JLPT N4": "beginner",
    "JLPT N3": "elementary",
    "JLPT N2": "intermediate",
    "JLPT N1": "advanced",
}

def load_json(path: Path) -> Any:
    if not path.exists():
        return []
    with open(path, 'r', encoding='utf-8') as f:
        return json.load(f)

def generate_lesson_id(title: str, section: int = 0, unit: int = 0) -> str:
    """Generate unique lesson ID."""
    if section and unit:
        base = f"lesson_s{section}_u{unit}_{title.lower().replace(' ', '_')}"
    else:
        base = f"lesson_{title.lower().replace(' ', '_')}"
    
    hash_suffix = hashlib.md5(base.encode()).hexdigest()[:8]
    return f"{base[:40]}_{hash_suffix}"

def extract_vocabulary_from_examples(examples: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """Extract vocabulary items from example sentences."""
    vocab_items = []
    
    for ex in examples:
        japanese = ex.get('japanese', ex.get('ja', ''))
        english = ex.get('english', ex.get('en', ''))
        
        if japanese and english:
            words = re.findall(r'[\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FFF]+', japanese)
            
            for word in words[:3]:
                vocab_items.append({
                    'word': word,
                    'reading': '',
                    'meaning': english,
                    'part_of_speech': 'unknown',
                    'example_sentence': japanese
                })
    
    return vocab_items[:10]

def create_lesson_from_duolingo(duo_unit: Dict[str, Any], vocab_db: List[Dict], grammar_db: List[Dict]) -> Dict[str, Any]:
    """Create a comprehensive lesson from a Duolingo unit."""
    
    section = duo_unit.get('section', 1)
    unit = duo_unit.get('unit', 1)
    title = duo_unit.get('meaning', f"Unit {unit}")
    difficulty = DIFFICULTY_MAPPING.get(duo_unit.get('difficulty', 'beginner'), 'beginner')
    
    lesson_id = generate_lesson_id(title, section, unit)
    
    examples = duo_unit.get('examples', [])
    tips = duo_unit.get('tips', '')
    
    vocab_items = extract_vocabulary_from_examples(examples)
    
    grammar_points = []
    if tips:
        tip_sections = tips.split('|')
        for tip in tip_sections[:3]:
            tip = tip.strip()
            if len(tip) > 10:
                grammar_points.append({
                    'pattern': title,
                    'explanation': tip,
                    'usage': '',
                    'examples': [{
                        'native': ex.get('japanese', ''),
                        'romanization': '',
                        'translation': ex.get('english', '')
                    } for ex in examples[:3]]
                })
    
    dialogues = []
    if len(examples) >= 2:
        dialogues.append({
            'title': f"{title} - Practice Dialogue",
            'context': f"Practicing {title.lower()}",
            'lines': [{
                'speaker': 'A' if i % 2 == 0 else 'B',
                'native': ex.get('japanese', ''),
                'romanization': '',
                'translation': ex.get('english', '')
            } for i, ex in enumerate(examples[:6])]
        })
    
    cultural_notes = []
    if tips and '|' in tips:
        note_parts = [t.strip() for t in tips.split('|') if len(t.strip()) > 20]
        for note in note_parts[:2]:
            cultural_notes.append({
                'title': 'Cultural Note',
                'content': note,
                'examples': []
            })
    
    learning_objectives = [
        f"Understand and use vocabulary related to: {title.lower()}",
        f"Communicate in situations involving: {title.lower()}",
        f"Recognize and respond to common phrases about: {title.lower()}"
    ]
    
    lesson = {
        'lesson_id': lesson_id,
        'title': {
            'en': title,
            'native': None
        },
        'description': {
            'en': f"Learn how to {title.lower()} in Japanese",
            'native': None
        },
        'difficulty_level': difficulty,
        'lesson_type': 'mixed_skills',
        'estimated_duration_minutes': 30 + (len(examples) * 2),
        'learning_objectives': learning_objectives,
        'skills': [],
        'vocabulary': vocab_items,
        'grammar_points': grammar_points if grammar_points else None,
        'dialogues': dialogues if dialogues else None,
        'cultural_notes': cultural_notes if cultural_notes else None,
        'exercises': [],
        'prerequisites': [],
        'unlocks': [],
        'metadata': {
            'proficiency_framework': None,
            'topic_tags': [title.lower(), duo_unit.get('difficulty', 'beginner')],
            'source_units': [{
                'source': 'Duolingo Guidebook',
                'unit_id': duo_unit.get('id', '')
            }]
        },
        'progress': {
            'completion_percentage': 0,
            'mastery_level': 0.0,
            'exercises_completed': 0,
            'last_studied': None,
            'is_unlocked': section == 1 and unit == 1
        }
    }
    
    return lesson

def create_grammar_lesson(grammar_items: List[Dict[str, Any]], level: str, theme: str) -> Dict[str, Any]:
    """Create a grammar-focused lesson from related grammar patterns."""
    
    lesson_id = generate_lesson_id(f"grammar_{theme}_{level}")
    difficulty = JLPT_TO_DIFFICULTY.get(level, 'intermediate')
    
    grammar_points = []
    all_examples = []
    
    for item in grammar_items[:5]:
        examples = []
        for ex in item.get('examples', [])[:3]:
            if isinstance(ex, dict):
                examples.append({
                    'native': ex.get('ja', ''),
                    'romanization': '',
                    'translation': ex.get('en', '')
                })
        
        grammar_points.append({
            'pattern': item.get('title', ''),
            'explanation': item.get('description', ''),
            'usage': '',
            'examples': examples
        })
        
        all_examples.extend(examples)
    
    lesson = {
        'lesson_id': lesson_id,
        'title': {
            'en': f"{theme} ({level})",
            'native': None
        },
        'description': {
            'en': f"Master {theme.lower()} grammar patterns at {level} level",
            'native': None
        },
        'difficulty_level': difficulty,
        'lesson_type': 'grammar_focus',
        'estimated_duration_minutes': 45,
        'learning_objectives': [
            f"Understand {len(grammar_items)} grammar patterns related to {theme.lower()}",
            f"Apply these patterns in sentences",
            f"Recognize these patterns in context"
        ],
        'skills': [],
        'vocabulary': [],
        'grammar_points': grammar_points,
        'dialogues': None,
        'cultural_notes': None,
        'exercises': [],
        'prerequisites': [],
        'unlocks': [],
        'metadata': {
            'proficiency_framework': level,
            'topic_tags': [theme.lower(), 'grammar', level.lower()],
            'source_units': [{
                'source': 'JLPT Grammar Database',
                'unit_id': level
            }]
        },
        'progress': {
            'completion_percentage': 0,
            'mastery_level': 0.0,
            'exercises_completed': 0,
            'last_studied': None,
            'is_unlocked': False
        }
    }
    
    return lesson

def create_vocabulary_lesson(vocab_items: List[Dict[str, Any]], theme: str, difficulty: str) -> Dict[str, Any]:
    """Create a vocabulary-themed lesson."""
    
    lesson_id = generate_lesson_id(f"vocab_{theme}")
    
    vocabulary = []
    for item in vocab_items[:20]:
        meanings = item.get('meanings', [])
        meaning = meanings[0] if meanings else ''
        
        examples = item.get('examples', [])
        example_sentence = ''
        if examples and isinstance(examples[0], dict):
            example_sentence = examples[0].get('ja', '')
        
        vocabulary.append({
            'word': item.get('lemma', ''),
            'reading': item.get('reading', ''),
            'meaning': meaning,
            'part_of_speech': item.get('pos', 'unknown'),
            'example_sentence': example_sentence
        })
    
    lesson = {
        'lesson_id': lesson_id,
        'title': {
            'en': f"{theme} Vocabulary",
            'native': None
        },
        'description': {
            'en': f"Essential vocabulary for {theme.lower()}",
            'native': None
        },
        'difficulty_level': difficulty,
        'lesson_type': 'vocabulary_theme',
        'estimated_duration_minutes': 25,
        'learning_objectives': [
            f"Learn {len(vocabulary)} essential words related to {theme.lower()}",
            f"Use these words in context",
            f"Build vocabulary for everyday situations"
        ],
        'skills': [],
        'vocabulary': vocabulary,
        'grammar_points': None,
        'dialogues': None,
        'cultural_notes': None,
        'exercises': [],
        'prerequisites': [],
        'unlocks': [],
        'metadata': {
            'proficiency_framework': None,
            'topic_tags': [theme.lower(), 'vocabulary'],
            'source_units': [{
                'source': 'Vocabulary Database',
                'unit_id': theme
            }]
        },
        'progress': {
            'completion_percentage': 0,
            'mastery_level': 0.0,
            'exercises_completed': 0,
            'last_studied': None,
            'is_unlocked': False
        }
    }
    
    return lesson

def create_prerequisites(lessons: List[Dict[str, Any]]) -> None:
    """Add prerequisite relationships between lessons."""
    
    lessons_by_id = {l['lesson_id']: l for l in lessons}
    lessons_by_difficulty = defaultdict(list)
    
    for lesson in lessons:
        diff = lesson['difficulty_level']
        lessons_by_difficulty[diff].append(lesson)
    
    difficulty_order = [
        'absolute_beginner',
        'beginner',
        'elementary',
        'pre_intermediate',
        'intermediate',
        'upper_intermediate',
        'advanced',
        'proficient'
    ]
    
    for i, current_level in enumerate(difficulty_order[1:], 1):
        prev_level = difficulty_order[i - 1]
        
        current_lessons = lessons_by_difficulty[current_level]
        prev_lessons = lessons_by_difficulty[prev_level]
        
        for lesson in current_lessons:
            if prev_lessons:
                prereq_lesson = prev_lessons[0]
                lesson['prerequisites'].append({
                    'lesson_id': prereq_lesson['lesson_id'],
                    'relationship': 'recommended',
                    'completion_threshold': 0.6
                })
                
                prereq_lesson['unlocks'].append(lesson['lesson_id'])
    
    for lesson in lessons:
        lesson_type = lesson['lesson_type']
        difficulty = lesson['difficulty_level']
        
        if lesson_type == 'grammar_focus':
            vocab_lessons = [
                l for l in lessons_by_difficulty[difficulty]
                if l['lesson_type'] == 'vocabulary_theme'
                and l['lesson_id'] != lesson['lesson_id']
            ]
            
            if vocab_lessons and len(lesson['prerequisites']) < 2:
                lesson['prerequisites'].append({
                    'lesson_id': vocab_lessons[0]['lesson_id'],
                    'relationship': 'helpful',
                    'completion_threshold': 0.5
                })

def create_learning_paths(lessons: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """Create curated learning paths through the lessons."""
    
    paths = []
    
    beginner_lessons = [
        l for l in lessons
        if l['difficulty_level'] in ['absolute_beginner', 'beginner']
    ]
    beginner_lessons.sort(key=lambda x: (x['difficulty_level'], x['lesson_id']))
    
    paths.append({
        'path_id': 'beginner_foundation',
        'name': "Beginner's Foundation",
        'description': "Start your Japanese journey with essential basics",
        'target_proficiency': "JLPT N5 / CEFR A1",
        'estimated_duration_weeks': 12,
        'lesson_sequence': [l['lesson_id'] for l in beginner_lessons[:20]],
        'milestones': [
            {
                'lesson_index': 5,
                'title': "First Conversations",
                'description': "You can now introduce yourself and order food!"
            },
            {
                'lesson_index': 10,
                'title': "Daily Life",
                'description': "You can talk about your daily routine and hobbies"
            },
            {
                'lesson_index': 15,
                'title': "Getting Around",
                'description': "You can navigate and ask for directions"
            }
        ]
    })
    
    intermediate_lessons = [
        l for l in lessons
        if l['difficulty_level'] in ['elementary', 'pre_intermediate']
    ]
    intermediate_lessons.sort(key=lambda x: (x['difficulty_level'], x['lesson_id']))
    
    paths.append({
        'path_id': 'intermediate_fluency',
        'name': "Intermediate Fluency",
        'description': "Build conversational fluency and complex grammar skills",
        'target_proficiency': "JLPT N3 / CEFR B1",
        'estimated_duration_weeks': 24,
        'lesson_sequence': [l['lesson_id'] for l in intermediate_lessons[:30]],
        'milestones': [
            {
                'lesson_index': 10,
                'title': "Complex Conversations",
                'description': "You can discuss past events and future plans"
            },
            {
                'lesson_index': 20,
                'title': "Nuanced Expression",
                'description': "You can express opinions and preferences clearly"
            }
        ]
    })
    
    advanced_lessons = [
        l for l in lessons
        if l['difficulty_level'] in ['intermediate', 'upper_intermediate', 'advanced']
    ]
    advanced_lessons.sort(key=lambda x: (x['difficulty_level'], x['lesson_id']))
    
    paths.append({
        'path_id': 'advanced_mastery',
        'name': "Advanced Mastery",
        'description': "Achieve professional-level Japanese proficiency",
        'target_proficiency': "JLPT N1 / CEFR C1",
        'estimated_duration_weeks': 36,
        'lesson_sequence': [l['lesson_id'] for l in advanced_lessons[:40]],
        'milestones': [
            {
                'lesson_index': 15,
                'title': "Professional Communication",
                'description': "You can handle business situations confidently"
            },
            {
                'lesson_index': 30,
                'title': "Near-Native Fluency",
                'description': "You can understand and use advanced expressions"
            }
        ]
    })
    
    return paths

def main() -> None:
    print("\n" + "=" * 70)
    print("BUILDING COMPREHENSIVE JAPANESE LESSON PLAN")
    print("=" * 70 + "\n")
    
    duo_data = load_json(DATA_RAW / "duo_raw.json")
    grammar_data = load_json(DATA_CLEAN / "grammar_pattern.json")
    vocab_data = load_json(DATA_CLEAN / "vocabulary_entry.json")
    
    print(f"Loaded data:")
    print(f"  - {len(duo_data)} Duolingo units")
    print(f"  - {len(grammar_data)} grammar patterns")
    print(f"  - {len(vocab_data)} vocabulary entries\n")
    
    lessons = []
    
    print("Creating lessons from Duolingo units...")
    for duo_unit in duo_data:
        lesson = create_lesson_from_duolingo(duo_unit, vocab_data, grammar_data)
        lessons.append(lesson)
    print(f"  ✓ Created {len(lessons)} Duolingo-based lessons")
    
    print("\nCreating grammar-focused lessons...")
    grammar_by_level = defaultdict(list)
    for g in grammar_data:
        level = g.get('jlpt_level', 'unknown')
        grammar_by_level[level].append(g)
    
    grammar_lesson_count = 0
    for level, items in grammar_by_level.items():
        if level != 'unknown':
            for i in range(0, len(items), 5):
                chunk = items[i:i+5]
                theme = f"Grammar Patterns {i//5 + 1}"
                lesson = create_grammar_lesson(chunk, level, theme)
                lessons.append(lesson)
                grammar_lesson_count += 1
    
    print(f"  ✓ Created {grammar_lesson_count} grammar lessons")
    
    print("\nCreating vocabulary-themed lessons...")
    vocab_by_pos = defaultdict(list)
    for v in vocab_data[:1000]:
        pos = v.get('pos', 'unknown')
        vocab_by_pos[pos].append(v)
    
    vocab_themes = {
        'Noun': ('Essential Nouns', 'beginner'),
        'Verb': ('Common Verbs', 'beginner'),
        'Adjective': ('Descriptive Adjectives', 'elementary'),
        'Adverb': ('Useful Adverbs', 'elementary'),
    }
    
    vocab_lesson_count = 0
    for pos, (theme, difficulty) in vocab_themes.items():
        items = vocab_by_pos.get(pos, [])
        if items:
            for i in range(0, min(len(items), 100), 20):
                chunk = items[i:i+20]
                lesson = create_vocabulary_lesson(chunk, f"{theme} {i//20 + 1}", difficulty)
                lessons.append(lesson)
                vocab_lesson_count += 1
    
    print(f"  ✓ Created {vocab_lesson_count} vocabulary lessons")
    
    print(f"\nTotal lessons created: {len(lessons)}")
    
    print("\nBuilding prerequisite relationships...")
    create_prerequisites(lessons)
    prereq_count = sum(len(l['prerequisites']) for l in lessons)
    print(f"  ✓ Created {prereq_count} prerequisite relationships")
    
    print("\nCreating learning paths...")
    learning_paths = create_learning_paths(lessons)
    print(f"  ✓ Created {len(learning_paths)} curated learning paths")
    
    difficulty_levels = [
        {
            'level_id': 'absolute_beginner',
            'name': 'Absolute Beginner',
            'description': 'First steps in Japanese',
            'proficiency_framework': 'JLPT N5 / CEFR A1',
            'lesson_count': len([l for l in lessons if l['difficulty_level'] == 'absolute_beginner'])
        },
        {
            'level_id': 'beginner',
            'name': 'Beginner',
            'description': 'Basic communication skills',
            'proficiency_framework': 'JLPT N4 / CEFR A2',
            'lesson_count': len([l for l in lessons if l['difficulty_level'] == 'beginner'])
        },
        {
            'level_id': 'elementary',
            'name': 'Elementary',
            'description': 'Everyday conversations',
            'proficiency_framework': 'JLPT N3 / CEFR B1',
            'lesson_count': len([l for l in lessons if l['difficulty_level'] == 'elementary'])
        },
        {
            'level_id': 'pre_intermediate',
            'name': 'Pre-Intermediate',
            'description': 'More complex topics',
            'proficiency_framework': 'JLPT N3 / CEFR B1',
            'lesson_count': len([l for l in lessons if l['difficulty_level'] == 'pre_intermediate'])
        },
        {
            'level_id': 'intermediate',
            'name': 'Intermediate',
            'description': 'Comfortable in most situations',
            'proficiency_framework': 'JLPT N2 / CEFR B2',
            'lesson_count': len([l for l in lessons if l['difficulty_level'] == 'intermediate'])
        },
        {
            'level_id': 'advanced',
            'name': 'Advanced',
            'description': 'Near-native fluency',
            'proficiency_framework': 'JLPT N1 / CEFR C1',
            'lesson_count': len([l for l in lessons if l['difficulty_level'] == 'advanced'])
        }
    ]
    
    topic_categories = [
        {
            'category_id': 'daily_life',
            'name': 'Daily Life',
            'description': 'Everyday situations and activities',
            'lesson_ids': [l['lesson_id'] for l in lessons if any(tag in l['metadata']['topic_tags'] for tag in ['food', 'family', 'hobbies'])]
        },
        {
            'category_id': 'communication',
            'name': 'Communication',
            'description': 'Greetings, introductions, and conversations',
            'lesson_ids': [l['lesson_id'] for l in lessons if any(tag in l['metadata']['topic_tags'] for tag in ['greet', 'introduce', 'talk'])]
        },
        {
            'category_id': 'travel',
            'name': 'Travel & Directions',
            'description': 'Getting around and traveling',
            'lesson_ids': [l['lesson_id'] for l in lessons if any(tag in l['metadata']['topic_tags'] for tag in ['directions', 'travel', 'countries'])]
        }
    ]
    
    total_hours = sum(l['estimated_duration_minutes'] for l in lessons) / 60
    
    lesson_plan = {
        'plan_id': 'japanese_comprehensive_v1',
        'language': {
            'code': 'ja',
            'name': 'Japanese',
            'native_name': '日本語'
        },
        'version': '1.0.0',
        'metadata': {
            'created_at': datetime.utcnow().isoformat() + 'Z',
            'updated_at': datetime.utcnow().isoformat() + 'Z',
            'author': 'PelaPela Lesson Plan Generator',
            'description': 'Comprehensive Japanese lesson plan with skill tree progression',
            'total_lessons': len(lessons),
            'total_estimated_hours': round(total_hours, 1)
        },
        'lessons': lessons,
        'learning_paths': learning_paths,
        'difficulty_levels': difficulty_levels,
        'topic_categories': topic_categories
    }
    
    output_file = OUT_DIR / "lesson_plan.json"
    output_file.write_text(
        json.dumps(lesson_plan, ensure_ascii=False, indent=2),
        encoding='utf-8'
    )
    
    print("\n" + "=" * 70)
    print("✅ LESSON PLAN GENERATION COMPLETE")
    print("=" * 70)
    print(f"\nOutput: {output_file}")
    print(f"\n📊 Summary:")
    print(f"  Total Lessons: {len(lessons)}")
    print(f"  Total Hours: {total_hours:.1f}")
    print(f"  Learning Paths: {len(learning_paths)}")
    print(f"  Difficulty Levels: {len(difficulty_levels)}")
    print(f"\n📚 Lessons by Difficulty:")
    for level in difficulty_levels:
        print(f"  {level['name']:20s}: {level['lesson_count']:3d} lessons")
    print(f"\n🎯 Learning Paths:")
    for path in learning_paths:
        print(f"  {path['name']:25s}: {len(path['lesson_sequence']):3d} lessons, {path['estimated_duration_weeks']} weeks")
    print()

if __name__ == "__main__":
    main()
