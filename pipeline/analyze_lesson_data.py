#!/usr/bin/env python3
"""
Analyze existing data to understand natural lesson groupings and create comprehensive lesson plans.
"""
from __future__ import annotations
import json
from pathlib import Path
from typing import Any, Dict, List, Set
from collections import defaultdict

ROOT = Path(__file__).resolve().parents[1]
DATA_CLEAN = ROOT / "data" / "clean"
DATA_RAW = ROOT / "data" / "raw"

def load_json(path: Path) -> List[Dict[str, Any]]:
    if not path.exists():
        return []
    with open(path, 'r', encoding='utf-8') as f:
        return json.load(f)

def analyze_duolingo_structure():
    """Analyze Duolingo guidebook structure."""
    duo = load_json(DATA_RAW / "duo_raw.json")
    
    print("=" * 60)
    print("DUOLINGO GUIDEBOOK ANALYSIS")
    print("=" * 60)
    print(f"Total lessons: {len(duo)}\n")
    
    sections = defaultdict(list)
    for lesson in duo:
        section = lesson.get('section', 0)
        unit = lesson.get('unit', 0)
        sections[section].append({
            'unit': unit,
            'meaning': lesson.get('meaning', ''),
            'difficulty': lesson.get('difficulty', ''),
            'examples': len(lesson.get('examples', [])),
            'tips': len(lesson.get('tips', ''))
        })
    
    for section_num in sorted(sections.keys()):
        units = sections[section_num]
        print(f"\nSection {section_num} ({len(units)} units):")
        for unit_info in sorted(units, key=lambda x: x['unit']):
            print(f"  Unit {unit_info['unit']:2d}: {unit_info['meaning']:30s} "
                  f"[{unit_info['difficulty']:10s}] "
                  f"({unit_info['examples']} examples)")
    
    return sections

def analyze_jlpt_distribution():
    """Analyze JLPT level distribution."""
    grammar = load_json(DATA_CLEAN / "grammar_pattern.json")
    vocab = load_json(DATA_CLEAN / "vocabulary_entry.json")
    
    print("\n" + "=" * 60)
    print("JLPT LEVEL DISTRIBUTION")
    print("=" * 60)
    
    grammar_levels = defaultdict(int)
    for g in grammar:
        level = g.get('jlpt_level', 'unknown')
        grammar_levels[level] += 1
    
    print("\nGrammar Patterns:")
    for level in sorted(grammar_levels.keys()):
        print(f"  {level:15s}: {grammar_levels[level]:4d} patterns")
    
    vocab_levels = defaultdict(int)
    for v in vocab:
        tags = v.get('tags', [])
        level = 'unknown'
        for tag in tags:
            if 'jlpt_n' in tag.lower():
                level = tag.upper().replace('_', ' ')
                break
        vocab_levels[level] += 1
    
    print("\nVocabulary:")
    for level in sorted(vocab_levels.keys()):
        print(f"  {level:15s}: {vocab_levels[level]:4d} words")
    
    return grammar_levels, vocab_levels

def analyze_vocabulary_topics():
    """Analyze vocabulary by part of speech and semantic topics."""
    vocab = load_json(DATA_CLEAN / "vocabulary_entry.json")
    
    print("\n" + "=" * 60)
    print("VOCABULARY ANALYSIS")
    print("=" * 60)
    
    pos_counts = defaultdict(int)
    semantic_groups = defaultdict(list)
    
    for v in vocab:
        pos = v.get('pos', 'unknown')
        pos_counts[pos] += 1
        
        meanings = v.get('meanings', [])
        if meanings:
            first_meaning = str(meanings[0]).lower()
            
            if any(word in first_meaning for word in ['food', 'eat', 'drink', 'meal', 'restaurant']):
                semantic_groups['food_dining'].append(v.get('lemma', ''))
            elif any(word in first_meaning for word in ['family', 'mother', 'father', 'brother', 'sister', 'parent', 'child']):
                semantic_groups['family'].append(v.get('lemma', ''))
            elif any(word in first_meaning for word in ['time', 'day', 'week', 'month', 'year', 'hour', 'minute']):
                semantic_groups['time'].append(v.get('lemma', ''))
            elif any(word in first_meaning for word in ['place', 'location', 'city', 'country', 'building', 'room']):
                semantic_groups['places'].append(v.get('lemma', ''))
            elif any(word in first_meaning for word in ['work', 'job', 'office', 'business', 'company']):
                semantic_groups['work'].append(v.get('lemma', ''))
            elif any(word in first_meaning for word in ['color', 'red', 'blue', 'green', 'yellow', 'black', 'white']):
                semantic_groups['colors'].append(v.get('lemma', ''))
            elif any(word in first_meaning for word in ['number', 'one', 'two', 'three', 'count']):
                semantic_groups['numbers'].append(v.get('lemma', ''))
    
    print("\nPart of Speech Distribution:")
    for pos, count in sorted(pos_counts.items(), key=lambda x: -x[1])[:10]:
        print(f"  {pos:20s}: {count:4d}")
    
    print("\nSemantic Topic Groups:")
    for topic, words in sorted(semantic_groups.items(), key=lambda x: -len(x[1])):
        print(f"  {topic:20s}: {len(words):4d} words")
        if len(words) <= 10:
            print(f"    Examples: {', '.join(words[:10])}")
    
    return pos_counts, semantic_groups

def analyze_network_relationships():
    """Analyze the existing network relationships."""
    edges_file = ROOT / "network_output" / "edges.json"
    if not edges_file.exists():
        print("\nNo network edges file found")
        return
    
    edges = load_json(edges_file)
    
    print("\n" + "=" * 60)
    print("NETWORK RELATIONSHIP ANALYSIS")
    print("=" * 60)
    print(f"Total edges: {len(edges)}\n")
    
    relation_types = defaultdict(int)
    for edge in edges:
        relation = edge.get('relation', 'unknown')
        relation_types[relation] += 1
    
    print("Top Relationship Types:")
    for rel_type, count in sorted(relation_types.items(), key=lambda x: -x[1])[:15]:
        print(f"  {rel_type:30s}: {count:6d}")
    
    return relation_types

def identify_lesson_themes():
    """Identify natural lesson themes from the data."""
    print("\n" + "=" * 60)
    print("RECOMMENDED LESSON THEMES")
    print("=" * 60)
    
    themes = {
        "Absolute Beginner": [
            "Hiragana & Katakana Basics",
            "Greetings & Self-Introduction",
            "Numbers & Counting",
            "Basic Food & Drink Vocabulary",
            "This/That Demonstratives (これ/それ/あれ)",
            "Basic Particles (は/を/の)",
        ],
        "Beginner": [
            "Ordering Food & Drink",
            "Describing People & Occupations",
            "Countries & Nationalities",
            "Asking for Directions",
            "Possessives & Belongings",
            "Time & Daily Schedule",
            "Family Members",
            "Hobbies & Activities",
            "Colors & Adjectives",
            "Basic Verbs (ます-form)",
        ],
        "Elementary": [
            "Past Tense Basics",
            "Location Markers (に/で/へ)",
            "Existence Verbs (いる/ある)",
            "Frequency Adverbs",
            "Shopping & Money",
            "Weather & Seasons",
            "Body Parts & Health",
            "Transportation",
            "Polite Requests",
            "Negative Forms",
        ],
        "Pre-Intermediate": [
            "Te-form Verbs",
            "Giving & Receiving",
            "Potential Form",
            "Comparative & Superlative",
            "Conditional Forms",
            "Volitional Form",
            "Passive Voice",
            "Causative Form",
            "Keigo (Honorific Language) Basics",
        ],
        "Intermediate": [
            "Advanced Particles",
            "Compound Sentences",
            "Reported Speech",
            "Advanced Conditionals",
            "Causative-Passive",
            "Formal Writing Patterns",
            "Business Japanese Basics",
            "Cultural Expressions",
        ],
        "Advanced": [
            "Classical Grammar Patterns",
            "Literary Expressions",
            "Advanced Keigo",
            "Specialized Vocabulary",
            "Idiomatic Expressions",
            "News & Media Language",
        ]
    }
    
    for level, topics in themes.items():
        print(f"\n{level} Level ({len(topics)} themes):")
        for i, topic in enumerate(topics, 1):
            print(f"  {i:2d}. {topic}")
    
    return themes

def main():
    print("\n" + "=" * 60)
    print("COMPREHENSIVE DATA ANALYSIS FOR LESSON PLANNING")
    print("=" * 60 + "\n")
    
    duo_sections = analyze_duolingo_structure()
    grammar_levels, vocab_levels = analyze_jlpt_distribution()
    pos_counts, semantic_groups = analyze_vocabulary_topics()
    relation_types = analyze_network_relationships()
    themes = identify_lesson_themes()
    
    print("\n" + "=" * 60)
    print("ANALYSIS COMPLETE")
    print("=" * 60)
    print("\nKey Findings:")
    print(f"  - {len(duo_sections)} Duolingo sections with structured progression")
    print(f"  - {sum(grammar_levels.values())} grammar patterns across JLPT levels")
    print(f"  - {sum(vocab_levels.values())} vocabulary entries")
    print(f"  - {len(semantic_groups)} identified semantic topic groups")
    print(f"  - {len(relation_types)} types of relationships in network")
    print("\nRecommendation: Create lesson plans that:")
    print("  1. Follow Duolingo's proven progression structure")
    print("  2. Group content by JLPT levels for difficulty scaling")
    print("  3. Organize vocabulary by semantic topics")
    print("  4. Build on prerequisite relationships from network")
    print("  5. Include grammar patterns with related vocabulary")

if __name__ == "__main__":
    main()
