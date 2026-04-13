/**
 * PelaPela API - Cloudflare Workers
 * Serves Japanese learning network and lesson plan data
 */

export default {
  async fetch(request, env, ctx) {
    return handleRequest(request, env, ctx);
  }
};

async function handleRequest(request, env, ctx) {
  const url = new URL(request.url);
  const path = url.pathname;

  // CORS headers
  const corsHeaders = {
    'Access-Control-Allow-Origin': env.CORS_ORIGIN || '*',
    'Access-Control-Allow-Methods': 'GET, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
    'Access-Control-Max-Age': '86400',
  };

  // Handle CORS preflight
  if (request.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders });
  }

  // Only allow GET requests
  if (request.method !== 'GET') {
    return jsonResponse({ error: 'Method not allowed' }, 405, corsHeaders);
  }

  try {
    // Route handling
    if (path === '/' || path === '') {
      return handleRoot(env, corsHeaders);
    }
    
    if (path === '/health') {
      return handleHealth(env, corsHeaders);
    }

    // Network endpoints
    if (path === '/api/network/nodes') {
      return handleNetworkNodes(request, env, corsHeaders);
    }
    
    if (path === '/api/network/edges') {
      return handleNetworkEdges(request, env, corsHeaders);
    }
    
    if (path === '/api/network/full') {
      return handleFullNetwork(request, env, corsHeaders);
    }

    // Skill tree endpoints
    if (path === '/api/skill-tree') {
      return handleSkillTree(request, env, corsHeaders);
    }
    
    if (path.startsWith('/api/skill-tree/node/')) {
      const nodeId = path.split('/').pop();
      return handleSkillNode(nodeId, env, corsHeaders);
    }

    // Lesson plan endpoints
    if (path === '/api/lessons') {
      return handleLessons(request, env, corsHeaders);
    }
    
    if (path.startsWith('/api/lessons/')) {
      const lessonId = path.split('/').pop();
      return handleLesson(lessonId, env, corsHeaders);
    }
    
    if (path === '/api/learning-paths') {
      return handleLearningPaths(request, env, corsHeaders);
    }

    // Vocabulary and grammar endpoints
    if (path === '/api/vocabulary') {
      return handleVocabulary(request, env, corsHeaders);
    }
    
    if (path === '/api/grammar') {
      return handleGrammar(request, env, corsHeaders);
    }

    // 404
    return jsonResponse({ error: 'Not found' }, 404, corsHeaders);

  } catch (error) {
    console.error('Error handling request:', error);
    return jsonResponse(
      { error: 'Internal server error', message: error.message },
      500,
      corsHeaders
    );
  }
}

// Handler functions

async function handleRoot(env, corsHeaders) {
  const apiInfo = {
    name: 'PelaPela API',
    version: env.API_VERSION || '1.0.0',
    description: 'Japanese learning network and lesson plan API',
    endpoints: {
      health: '/health',
      network: {
        nodes: '/api/network/nodes',
        edges: '/api/network/edges',
        full: '/api/network/full'
      },
      skillTree: {
        tree: '/api/skill-tree',
        node: '/api/skill-tree/node/:id'
      },
      lessons: {
        all: '/api/lessons',
        single: '/api/lessons/:id',
        paths: '/api/learning-paths'
      },
      data: {
        vocabulary: '/api/vocabulary',
        grammar: '/api/grammar'
      }
    },
    documentation: 'https://github.com/yourusername/pelapela-api'
  };
  
  return jsonResponse(apiInfo, 200, corsHeaders);
}

async function handleHealth(env, corsHeaders) {
  return jsonResponse({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    version: env.API_VERSION || '1.0.0'
  }, 200, corsHeaders);
}

async function handleNetworkNodes(request, env, corsHeaders) {
  const url = new URL(request.url);
  const limit = parseInt(url.searchParams.get('limit')) || 100;
  const offset = parseInt(url.searchParams.get('offset')) || 0;
  const type = url.searchParams.get('type'); // 'grammar' or 'vocabulary'
  
  const data = await getDataFromR2(env, 'network_output/nodes.json');
  
  if (!data) {
    return jsonResponse({ error: 'Network nodes not found' }, 404, corsHeaders);
  }
  
  let nodes = data;
  
  // Filter by type if specified
  if (type) {
    nodes = nodes.filter(node => node.type === type);
  }
  
  // Pagination
  const total = nodes.length;
  const paginatedNodes = nodes.slice(offset, offset + limit);
  
  return jsonResponse({
    data: paginatedNodes,
    pagination: {
      total,
      limit,
      offset,
      hasMore: offset + limit < total
    }
  }, 200, corsHeaders);
}

async function handleNetworkEdges(request, env, corsHeaders) {
  const url = new URL(request.url);
  const limit = parseInt(url.searchParams.get('limit')) || 100;
  const offset = parseInt(url.searchParams.get('offset')) || 0;
  const sourceId = url.searchParams.get('source');
  
  const data = await getDataFromR2(env, 'network_output/edges.json');
  
  if (!data) {
    return jsonResponse({ error: 'Network edges not found' }, 404, corsHeaders);
  }
  
  let edges = data;
  
  // Filter by source if specified
  if (sourceId) {
    edges = edges.filter(edge => edge.source === sourceId);
  }
  
  // Pagination
  const total = edges.length;
  const paginatedEdges = edges.slice(offset, offset + limit);
  
  return jsonResponse({
    data: paginatedEdges,
    pagination: {
      total,
      limit,
      offset,
      hasMore: offset + limit < total
    }
  }, 200, corsHeaders);
}

async function handleFullNetwork(request, env, corsHeaders) {
  const [nodes, edges] = await Promise.all([
    getDataFromR2(env, 'network_output/nodes.json'),
    getDataFromR2(env, 'network_output/edges.json')
  ]);
  
  if (!nodes || !edges) {
    return jsonResponse({ error: 'Network data not found' }, 404, corsHeaders);
  }
  
  return jsonResponse({
    nodes,
    edges,
    metadata: {
      nodeCount: nodes.length,
      edgeCount: edges.length,
      generated: new Date().toISOString()
    }
  }, 200, corsHeaders);
}

async function handleSkillTree(request, env, corsHeaders) {
  const data = await getDataFromR2(env, 'skill_tree_output/skill_tree.json');
  
  if (!data) {
    return jsonResponse({ error: 'Skill tree not found' }, 404, corsHeaders);
  }
  
  return jsonResponse(data, 200, corsHeaders);
}

async function handleSkillNode(nodeId, env, corsHeaders) {
  const data = await getDataFromR2(env, 'skill_tree_output/skill_tree.json');
  
  if (!data) {
    return jsonResponse({ error: 'Skill tree not found' }, 404, corsHeaders);
  }
  
  const node = data.nodes?.find(n => n.id === nodeId);
  
  if (!node) {
    return jsonResponse({ error: 'Node not found' }, 404, corsHeaders);
  }
  
  return jsonResponse(node, 200, corsHeaders);
}

async function handleLessons(request, env, corsHeaders) {
  const url = new URL(request.url);
  const difficulty = url.searchParams.get('difficulty');
  const type = url.searchParams.get('type');
  const limit = parseInt(url.searchParams.get('limit')) || 50;
  const offset = parseInt(url.searchParams.get('offset')) || 0;
  
  const data = await getDataFromR2(env, 'lesson_plan_output/lesson_plan.json');
  
  if (!data) {
    return jsonResponse({ error: 'Lesson plan not found' }, 404, corsHeaders);
  }
  
  let lessons = data.lessons || [];
  
  // Filter by difficulty
  if (difficulty) {
    lessons = lessons.filter(l => l.difficulty_level === difficulty);
  }
  
  // Filter by type
  if (type) {
    lessons = lessons.filter(l => l.lesson_type === type);
  }
  
  // Pagination
  const total = lessons.length;
  const paginatedLessons = lessons.slice(offset, offset + limit);
  
  return jsonResponse({
    data: paginatedLessons,
    pagination: {
      total,
      limit,
      offset,
      hasMore: offset + limit < total
    },
    metadata: data.metadata
  }, 200, corsHeaders);
}

async function handleLesson(lessonId, env, corsHeaders) {
  const data = await getDataFromR2(env, 'lesson_plan_output/lesson_plan.json');
  
  if (!data) {
    return jsonResponse({ error: 'Lesson plan not found' }, 404, corsHeaders);
  }
  
  const lesson = data.lessons?.find(l => l.lesson_id === lessonId);
  
  if (!lesson) {
    return jsonResponse({ error: 'Lesson not found' }, 404, corsHeaders);
  }
  
  return jsonResponse(lesson, 200, corsHeaders);
}

async function handleLearningPaths(request, env, corsHeaders) {
  const data = await getDataFromR2(env, 'lesson_plan_output/lesson_plan.json');
  
  if (!data) {
    return jsonResponse({ error: 'Lesson plan not found' }, 404, corsHeaders);
  }
  
  return jsonResponse({
    paths: data.learning_paths || [],
    difficulty_levels: data.difficulty_levels || [],
    topic_categories: data.topic_categories || []
  }, 200, corsHeaders);
}

async function handleVocabulary(request, env, corsHeaders) {
  const url = new URL(request.url);
  const limit = parseInt(url.searchParams.get('limit')) || 100;
  const offset = parseInt(url.searchParams.get('offset')) || 0;
  const pos = url.searchParams.get('pos'); // part of speech
  
  const data = await getDataFromR2(env, 'data/clean/vocabulary_entry.json');
  
  if (!data) {
    return jsonResponse({ error: 'Vocabulary data not found' }, 404, corsHeaders);
  }
  
  let vocab = data;
  
  // Filter by part of speech
  if (pos) {
    vocab = vocab.filter(v => v.pos === pos);
  }
  
  // Pagination
  const total = vocab.length;
  const paginatedVocab = vocab.slice(offset, offset + limit);
  
  return jsonResponse({
    data: paginatedVocab,
    pagination: {
      total,
      limit,
      offset,
      hasMore: offset + limit < total
    }
  }, 200, corsHeaders);
}

async function handleGrammar(request, env, corsHeaders) {
  const url = new URL(request.url);
  const limit = parseInt(url.searchParams.get('limit')) || 100;
  const offset = parseInt(url.searchParams.get('offset')) || 0;
  const level = url.searchParams.get('level'); // JLPT level
  
  const data = await getDataFromR2(env, 'data/clean/grammar_pattern.json');
  
  if (!data) {
    return jsonResponse({ error: 'Grammar data not found' }, 404, corsHeaders);
  }
  
  let grammar = data;
  
  // Filter by JLPT level
  if (level) {
    grammar = grammar.filter(g => g.jlpt_level === level);
  }
  
  // Pagination
  const total = grammar.length;
  const paginatedGrammar = grammar.slice(offset, offset + limit);
  
  return jsonResponse({
    data: paginatedGrammar,
    pagination: {
      total,
      limit,
      offset,
      hasMore: offset + limit < total
    }
  }, 200, corsHeaders);
}

// Utility functions

async function getDataFromR2(env, key) {
  try {
    const object = await env.PELAPELA_DATA.get(key);
    
    if (!object) {
      return null;
    }
    
    const text = await object.text();
    return JSON.parse(text);
  } catch (error) {
    console.error(`Error fetching ${key} from R2:`, error);
    return null;
  }
}

function jsonResponse(data, status = 200, additionalHeaders = {}) {
  return new Response(JSON.stringify(data, null, 2), {
    status,
    headers: {
      'Content-Type': 'application/json',
      ...additionalHeaders
    }
  });
}
