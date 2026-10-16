# orchestra

[English](README.md) | **Português (BR)**

Um plugin do Claude Code com pipelines de orquestração multi-modelo. Subagentes do Claude fazem o trabalho; Hermes, OpenClaw e Gemini podem servir como checagens independentes opcionais.

São dois pipelines (artigos científicos e software) e duas skills utilitárias pequenas.

## Pipelines

### Pesquisa (maestra `research`)

De uma hipótese a um manuscrito com citações verificadas. A maestra organiza as etapas, guarda um arquivo de estado em `research/<slug>/` e retoma de onde parou. Cada etapa também funciona sozinha.

| Etapa | Skill | O que faz |
| --- | --- | --- |
| 1 | `interview` | Entrevista socrática, uma pergunta por vez, que transforma uma ideia em um brief preciso e encontra seus pontos fracos |
| 2 | `literature` | Revisão de literatura montada como wiki estilo Obsidian, mais uma pasta de PDFs de acesso aberto, com as afirmações conferidas em fontes primárias |
| 3 | `proposal` | Escreve a proposta do artigo e a refina com você e com uma revisão adversarial |
| 4 | `plan` | Roteiro de tarefas para o manuscrito e o código, organizado para o máximo de paralelismo, com critérios de aceitação |
| 5 | `build` | Pares construtor/crítico de subagentes executam o roteiro com o método gauntlet-loop |
| 6 | `cite-check` | Verifica se cada referência existe, se os metadados estão certos e se a obra citada sustenta a frase |
| 7 | `polish` | Remove padrões de escrita de IA protegendo equações, citações, números e ressalvas justificadas |

### Desenvolvimento (maestra `develop`)

De uma ideia de software a código construído.

| Etapa | Skill | O que faz |
| --- | --- | --- |
| 1 | `spec-interview` | Extração socrática de requisitos em uma especificação testável com identificadores |
| 2 | `design-vault` | Desenha o software como um cofre Obsidian: módulos, funções, tipos e decisões como notas ligadas, rastreadas até requisitos e testes |
| 3 | `dev-plan` | Plano de implementação com máximo paralelismo a partir do grafo do cofre, com testes reservados |
| 4 | `build` | Executa o plano e sincroniza o cofre após cada onda |

## Skills utilitárias

- **`one-shot`**: entrevista você para transformar uma tarefa em especificação, pergunta qual modelo coordena e qual modelo os subagentes usam, e roda um ciclo até os critérios de sucesso serem cumpridos. Para tarefas focadas que não precisam de um pipeline completo.
- **`your-words`**: comece o pedido com `/your-words` e o Claude primeiro diz o que entendeu, o que ficou incerto e como seria o sucesso, e depois segue com a tarefa.

## Instalação

```
/plugin marketplace add dshguilherme/orchestra
/plugin install orchestra
```

Para desenvolvimento: `claude --plugin-dir <caminho-deste-repositório>`.

## Uso

Digite o nome da skill como comando, ou apenas descreva o que quer:

```
/research        # partir de uma hipótese
/develop         # partir de uma ideia de software
/interview       # só testar uma ideia
/one-shot <tarefa>
/your-words <pedido>
```

## Requisitos e observações

- `polish` precisa da skill separada [avoid-ai-writing](https://github.com/conorbronsdon/avoid-ai-writing). Ela é calibrada para inglês; em outros idiomas o resultado é menos confiável.
- `scripts/ask.ps1` (Windows PowerShell) envia uma pergunta ao Hermes, OpenClaw ou Gemini, se estiverem instalados. `-List` mostra quais estão disponíveis. Sem eles os pipelines funcionam do mesmo jeito, só sem a checagem externa.
- Aos modelos externos vão apenas perguntas, nunca o cofre, arquivos de memória ou credenciais.
- Os pipelines rodam muitos agentes e consomem bastante do seu limite de uso. Use em projetos que valham a pena.

## Créditos

Veja [NOTICE.md](NOTICE.md).
