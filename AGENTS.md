# AGENTS.md

## Providers

- name: Ollama Local
  type: openai
  api_base: http://localhost:11434
  api_key: none
  models:
    - llama2
    - mistral
    - gemma

## Agents

- name: Default Assistant
  provider: Ollama Local
  model: llama2
  description: >
    Asistente principal para explicar código, refactorizar y generar nuevas funciones
    usando el modelo local de Ollama.

- name: Refactor Bot
  provider: Ollama Local
  model: mistral
  description: >
    Especializado en limpieza y optimización de código, con foco en legibilidad y eficiencia.

- name: Creative Helper
  provider: Ollama Local
  model: gemma
  description: >
    Orientado a brainstorming y generación de ideas para nuevas funcionalidades.
