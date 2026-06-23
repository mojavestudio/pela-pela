#!/usr/bin/env python3
from __future__ import annotations
import json
from pathlib import Path
from typing import Any, Dict, List, Set
from collections import defaultdict
from datetime import datetime
import hashlib

ROOT = Path(__file__).resolve().parents[1]
DATA_CLEAN = ROOT / "data" / "clean"
OUT_DIR = ROOT / "skill_tree_output"
OUT_DIR.mkdir(exist_ok=True)

JLPT_TO_TIER = {
    "JLPT N5": 1,
    "JLPT N4": 2,
    "JLPT N3": 4,
    "JLPT N2": 6,
    "JLPT N1": 8,
}

TIER_DEFINITIONS = [
    {"tier": 1, "name": "Absolute Beginner", "description": "First steps in the language", "proficiency_level": "JLPT N5 / CEFR A1"},
    {"tier": 2, "name": "Beginner", "description": "Basic communication skills", "proficiency_level": "JLPT N4 / CEFR A1-A2"},
    {"tier": 3, "name": "Elementary", "description": "Everyday conversations", "proficiency_level": "CEFR A2"},
    {"tier": 4, "name": "Pre-Intermediate", "description": "More complex topics", "proficiency_level": "JLPT N3 / CEFR B1"},
    {"tier": 5, "name": "Intermediate", "description": "Comfortable in most situations", "proficiency_level": "CEFR B1-B2"},
    {"tier": 6, "name": "Upper-Intermediate", "description": "Nuanced expression", "proficiency_level": "JLPT N2 / CEFR B2"},
    {"tier": 7, "name": "Advanced", "description": "Near-native fluency", "proficiency_level": "CEFR C1"},
    {"tier": 8, "name": "Proficient", "description": "Professional competence", "proficiency_level": "JLPT N1 / CEFR C1"},
    {"tier": 9, "name": "Expert", "description": "Specialized mastery", "proficiency_level": "CEFR C2"},
    {"tier": 10, "name": "Native-Level", "description": "Complete mastery", "proficiency_level": "CEFR C2+"},
]

def load_json(path: Path) -> List[Dict[str, Any]]:
    if not path.exists():
        return []
    return json.loads(path.read_text(encoding="utf-8"))

def generate_skill_id(base: str, skill_type: str) -> str:
    """Generate a clean, deterministic skill ID."""
    content = f"{skill_type}:{base}"
    hash_suffix = hashlib.md5(content.encode()).hexdigest()[:8]
    clean_base = base.lower().replace(" ", "_").replace("-", "_")[:30]
    return f"{skill_type}_{clean_base}_{hash_suffix}"

def infer_skill_type(item: Dict[str, Any]) -> str:
    """Infer the skill type from item properties."""
    item_type = item.get("type", "")
    tags = item.get("tags", [])
    
    if item_type == "grammar_pattern":
        return "grammar"
    
    if item_type == "vocabulary_entry":
        pos = item.get("pos", "").lower()
        if "verb" in pos:
            return "vocabulary"
        elif "particle" in pos or "conjunction" in pos:
            return "grammar"
        else:
            return "vocabulary"
    
    if "foundation" in tags or "basic" in tags:
        return "foundation"
    if "conversation" in tags or "dialogue" in tags:
        return "conversation"
    if "cultural" in tags or "culture" in tags:
        return "cultural"
    
    return "vocabulary"

def get_difficulty_tier(item: Dict[str, Any]) -> int:
    """Determine difficulty tier from JLPT level or other indicators."""
    jlpt_level = item.get("jlpt_level", "")
    if jlpt_level in JLPT_TO_TIER:
        return JLPT_TO_TIER[jlpt_level]
    
    tags = item.get("tags", [])
    for tag in tags:
        if "jlpt_n5" in tag.lower():
            return 1
        elif "jlpt_n4" in tag.lower():
            return 2
        elif "jlpt_n3" in tag.lower():
            return 4
        elif "jlpt_n2" in tag.lower():
            return 6
        elif "jlpt_n1" in tag.lower():
            return 8
    
    return 3

def estimate_learning_hours(item: Dict[str, Any], tier: int) -> float:
    """Estimate hours needed to master this skill."""
    base_hours = {
        "foundation": 0.5,
        "vocabulary": 0.25,
        "grammar": 1.0,
        "phrase": 0.5,
        "conversation": 1.5,
        "cultural": 1.0,
        "advanced": 2.0,
    }
    
    skill_type = infer_skill_type(item)
    hours = base_hours.get(skill_type, 1.0)
    
    tier_multiplier = 1.0 + (tier - 1) * 0.2
    hours *= tier_multiplier
    
    examples = item.get("examples", [])
    if len(examples) > 5:
        hours *= 1.2
    
    return round(hours, 2)

def create_natural_prerequisites(
    node_id: str,
    tier: int,
    skill_type: str,
    all_nodes: List[Dict[str, Any]],
    tier_groups: Dict[int, List[str]]
) -> List[Dict[str, Any]]:
    """Create natural prerequisite relationships based on learning progression."""
    prerequisites = []
    
    if tier == 1:
        return prerequisites
    
    if tier == 2:
        tier_1_skills = [n for n in all_nodes if n["difficulty_tier"] == 1 and n["id"] != node_id]
        if tier_1_skills:
            same_type = [n for n in tier_1_skills if n["skill_type"] == skill_type]
            if same_type:
                prerequisites.append({
                    "skill_id": same_type[0]["id"],
                    "relationship": "required",
                    "mastery_threshold": 0.7
                })
            elif tier_1_skills:
                prerequisites.append({
                    "skill_id": tier_1_skills[0]["id"],
                    "relationship": "recommended",
                    "mastery_threshold": 0.6
                })
    
    if tier >= 3:
        prev_tier = tier - 1
        prev_tier_same_type = [
            n for n in all_nodes 
            if n["difficulty_tier"] == prev_tier 
            and n["skill_type"] == skill_type
            and n["id"] != node_id
        ]
        
        if prev_tier_same_type:
            prerequisites.append({
                "skill_id": prev_tier_same_type[0]["id"],
                "relationship": "required",
                "mastery_threshold": 0.65
            })
        else:
            prev_tier_any = [
                n for n in all_nodes
                if n["difficulty_tier"] == prev_tier
                and n["id"] != node_id
            ]
            if prev_tier_any:
                prerequisites.append({
                    "skill_id": prev_tier_any[0]["id"],
                    "relationship": "recommended",
                    "mastery_threshold": 0.5
                })
    
    if skill_type == "grammar" and tier >= 2:
        lower_tier_vocab = [
            n for n in all_nodes
            if n["difficulty_tier"] < tier
            and n["skill_type"] == "vocabulary"
            and n["id"] != node_id
        ]
        if lower_tier_vocab and len(prerequisites) < 3:
            prerequisites.append({
                "skill_id": lower_tier_vocab[0]["id"],
                "relationship": "helpful",
                "mastery_threshold": 0.4
            })
    
    if skill_type == "vocabulary" and tier >= 3:
        lower_tier_grammar = [
            n for n in all_nodes
            if n["difficulty_tier"] <= tier - 1
            and n["skill_type"] == "grammar"
            and n["id"] != node_id
        ]
        if lower_tier_grammar and len(prerequisites) < 2:
            prerequisites.append({
                "skill_id": lower_tier_grammar[0]["id"],
                "relationship": "helpful",
                "mastery_threshold": 0.3
            })
    
    return prerequisites

def create_unlocks(
    node_id: str,
    tier: int,
    skill_type: str,
    all_nodes: List[Dict[str, Any]]
) -> List[str]:
    """Determine which skills this node unlocks."""
    unlocks = []
    
    for node in all_nodes:
        if node["id"] == node_id:
            continue
        
        for prereq in node.get("prerequisites", []):
            if prereq["skill_id"] == node_id:
                unlocks.append(node["id"])
    
    return unlocks

def convert_to_skill_node(item: Dict[str, Any], all_nodes: List[Dict[str, Any]], tier_groups: Dict[int, List[str]]) -> Dict[str, Any]:
    """Convert legacy data format to new skill node format."""
    skill_type = infer_skill_type(item)
    tier = get_difficulty_tier(item)
    
    skill_id = generate_skill_id(
        item.get("title") or item.get("lemma") or item.get("id"),
        skill_type
    )
    
    title_text = item.get("title") or item.get("lemma") or "Untitled"
    native_title = item.get("title_ja") or item.get("lemma") or ""
    
    description_text = item.get("description", "")
    meanings = item.get("meanings", [])
    if meanings and not description_text:
        description_text = ", ".join(str(m) for m in meanings[:3])
    
    examples = []
    for ex in item.get("examples", [])[:5]:
        if isinstance(ex, dict):
            examples.append({
                "native": ex.get("ja", ""),
                "romanization": None,
                "translation": ex.get("en", ""),
                "context": None,
                "audio_url": None
            })
    
    learning_objectives = []
    if skill_type == "vocabulary":
        learning_objectives.append(f"Recognize and use '{title_text}' in context")
        learning_objectives.append(f"Understand the meaning: {description_text}")
    elif skill_type == "grammar":
        learning_objectives.append(f"Understand the grammar pattern: {title_text}")
        learning_objectives.append(f"Apply this pattern in sentences")
    
    proficiency_framework = item.get("jlpt_level", "")
    if not proficiency_framework:
        for tag in item.get("tags", []):
            if "jlpt" in tag.lower():
                proficiency_framework = tag.upper().replace("_", " ")
                break
    
    skill_node = {
        "id": skill_id,
        "skill_type": skill_type,
        "title": {
            "en": title_text,
            "native": native_title if native_title else None
        },
        "description": {
            "en": description_text,
            "native": None
        } if description_text else None,
        "difficulty_tier": tier,
        "estimated_hours": estimate_learning_hours(item, tier),
        "prerequisites": [],
        "unlocks": [],
        "learning_objectives": learning_objectives if learning_objectives else None,
        "content": {
            "examples": examples if examples else None,
            "explanations": None,
            "practice_exercises": None
        } if examples else None,
        "metadata": {
            "tags": item.get("tags", []),
            "proficiency_framework": proficiency_framework if proficiency_framework else None,
            "topic_areas": item.get("topics", None),
            "part_of_speech": item.get("pos", None)
        },
        "progress_tracking": {
            "mastery_level": 0.0,
            "last_practiced": None,
            "practice_count": 0,
            "is_unlocked": tier == 1
        }
    }
    
    return skill_node

def create_learning_pathways(nodes: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """Create recommended learning pathways through the skill tree."""
    pathways = []
    
    beginner_path = {
        "pathway_id": "beginner_path",
        "name": "Beginner's Journey",
        "description": "Start from zero and build a solid foundation",
        "target_proficiency": "JLPT N4 / CEFR A2",
        "estimated_duration_weeks": 24,
        "skill_sequence": []
    }
    
    tier_1_2_nodes = [n for n in nodes if n["difficulty_tier"] <= 2]
    tier_1_2_nodes.sort(key=lambda x: (x["difficulty_tier"], x["skill_type"]))
    beginner_path["skill_sequence"] = [n["id"] for n in tier_1_2_nodes[:30]]
    pathways.append(beginner_path)
    
    intermediate_path = {
        "pathway_id": "intermediate_path",
        "name": "Intermediate Mastery",
        "description": "Build on basics and achieve conversational fluency",
        "target_proficiency": "JLPT N3 / CEFR B1",
        "estimated_duration_weeks": 36,
        "skill_sequence": []
    }
    
    tier_3_5_nodes = [n for n in nodes if 3 <= n["difficulty_tier"] <= 5]
    tier_3_5_nodes.sort(key=lambda x: (x["difficulty_tier"], x["skill_type"]))
    intermediate_path["skill_sequence"] = [n["id"] for n in tier_3_5_nodes[:40]]
    pathways.append(intermediate_path)
    
    advanced_path = {
        "pathway_id": "advanced_path",
        "name": "Advanced Proficiency",
        "description": "Achieve near-native fluency and professional competence",
        "target_proficiency": "JLPT N1 / CEFR C1",
        "estimated_duration_weeks": 52,
        "skill_sequence": []
    }
    
    tier_6_plus_nodes = [n for n in nodes if n["difficulty_tier"] >= 6]
    tier_6_plus_nodes.sort(key=lambda x: (x["difficulty_tier"], x["skill_type"]))
    advanced_path["skill_sequence"] = [n["id"] for n in tier_6_plus_nodes[:50]]
    pathways.append(advanced_path)
    
    return pathways

def main() -> None:
    print("Building natural skill tree...")
    
    grammar = load_json(DATA_CLEAN / "grammar_pattern.json")
    vocab = load_json(DATA_CLEAN / "vocabulary_entry.json")
    
    print(f"Loaded {len(grammar)} grammar patterns and {len(vocab)} vocabulary entries")
    
    all_items = []
    
    for g in grammar[:250]:
        all_items.append(g)
    for v in vocab[:250]:
        all_items.append(v)
    
    tier_groups: Dict[int, List[str]] = defaultdict(list)
    type_tier_groups: Dict[tuple, List[str]] = defaultdict(list)
    
    skill_nodes = []
    for item in all_items:
        node = convert_to_skill_node(item, [], tier_groups)
        skill_nodes.append(node)
        tier_groups[node["difficulty_tier"]].append(node["id"])
        type_tier_groups[(node["skill_type"], node["difficulty_tier"])].append(node["id"])
    
    print(f"Created {len(skill_nodes)} skill nodes")
    
    for i, node in enumerate(skill_nodes):
        prerequisites = create_natural_prerequisites(
            node["id"],
            node["difficulty_tier"],
            node["skill_type"],
            skill_nodes,
            tier_groups
        )
        skill_nodes[i]["prerequisites"] = prerequisites
    
    for i, node in enumerate(skill_nodes):
        unlocks = create_unlocks(
            node["id"],
            node["difficulty_tier"],
            node["skill_type"],
            skill_nodes
        )
        skill_nodes[i]["unlocks"] = unlocks
    
    pathways = create_learning_pathways(skill_nodes)
    
    total_hours = sum(n.get("estimated_hours", 0) for n in skill_nodes)
    
    skill_tree = {
        "tree_id": "japanese_skill_tree_v1",
        "language": {
            "code": "ja",
            "name": "Japanese",
            "native_name": "日本語"
        },
        "version": "1.0.0",
        "metadata": {
            "created_at": datetime.utcnow().isoformat() + "Z",
            "updated_at": datetime.utcnow().isoformat() + "Z",
            "author": "PelaPela Skill Tree Generator",
            "description": "Natural skill tree for learning Japanese with progressive difficulty tiers",
            "total_estimated_hours": round(total_hours, 2)
        },
        "nodes": skill_nodes,
        "pathways": pathways,
        "tiers": TIER_DEFINITIONS
    }
    
    output_file = OUT_DIR / "skill_tree.json"
    output_file.write_text(
        json.dumps(skill_tree, ensure_ascii=False, indent=2),
        encoding="utf-8"
    )
    
    print(f"\n✅ Skill tree written to {output_file}")
    print(f"   Total nodes: {len(skill_nodes)}")
    print(f"   Total pathways: {len(pathways)}")
    print(f"   Estimated total hours: {total_hours:.1f}")
    
    tier_distribution = defaultdict(int)
    type_distribution = defaultdict(int)
    
    for node in skill_nodes:
        tier_distribution[node["difficulty_tier"]] += 1
        type_distribution[node["skill_type"]] += 1
    
    print("\n📊 Distribution:")
    print("   By tier:", dict(sorted(tier_distribution.items())))
    print("   By type:", dict(type_distribution))
    
    nodes_with_prereqs = sum(1 for n in skill_nodes if n["prerequisites"])
    print(f"\n🔗 Connections:")
    print(f"   Nodes with prerequisites: {nodes_with_prereqs}")
    print(f"   Average prerequisites per node: {sum(len(n['prerequisites']) for n in skill_nodes) / len(skill_nodes):.2f}")

if __name__ == "__main__":
    main()
