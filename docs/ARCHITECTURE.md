# Architecture

```mermaid
flowchart LR
  subgraph main["Main Ractor"]
    CLI["Zat::CLI<br/>options, inputs"] --> Term["Zat::Terminal<br/>width, colors, images"]
    CLI --> Batch["Zat::Batch<br/>only with several files"]
  end
  subgraph pipeline["Pipeline (main Ractor, or each of N pooled workers)"]
    Parse["Zat::Markdown.parse<br/>blocks → inlines"] --> AST[("Node tree<br/>deeply frozen")]
    AST --> Render["Zat::Renderer<br/>+ Table, Highlight, Image"]
  end
  CLI -- "one file" --> Parse
  Batch -- "paths, --jobs N workers" --> Parse
  Term -- "shareable settings" --> Render
  Render -- "one String per document,<br/>written in input order" --> Out["stdout / $PAGER"]
```

- **`Zat::Markdown`** is the parser. It knows nothing about terminals and requires nothing else from Zat, so it can become its own gem. `test/markdown/` runs it in isolation.
- **Only the main Ractor touches the environment** (ENV, TTY, files on stdout). Workers get frozen settings and return frozen strings. That's what makes batch mode a matter of fanning out.
- **Ractors only when there's more than one file.** A single document renders in the main Ractor; startup (~45 ms) dwarfs anything parallelism could save there. Batch mode uses a fixed pool for bounded memory and ordered output.
- **One output buffer per document**, written once. String building is the workload under measurement, so it's kept in one place.

Why things are this way: [decisions.md](decisions.md). The plan and the issue map: [PLANNING.md](PLANNING.md).

*Update this page in the same PR as any change to the shape above.*
