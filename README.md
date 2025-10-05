# Unstruct Platform — Meta Repository

A single place to understand, navigate, and operate the **entire Unstruct system**:  
**file-loader → pdf-processor → text-extractor → text-embedder → text-rag**, plus **Terraform infra**.

---

## 🔭 What this repo is (and isn’t)
- ✅ A **map**, docs hub, and orchestration layer.  
- ✅ Links to all service repos + infrastructure.  
- ✅ One-click developer quickstarts, architecture diagrams, and runbooks.  
- ❌ Not a monorepo — service code stays in their own repositories.

---

## 🗺️ Repository map

| Domain       | Repository                                                                 | CI/CD                      | Cloud Resources |
|---------------|----------------------------------------------------------------------------|-----------------------------|-----------------|
| Ingestion     | [mbellary/file-loader](https://github.com/mbellary/file-loader)         | GA: build, test, publish    | S3 (raw), SQS (ingestion), DynamoDB (offsets) |
| Processor     | [mbellary/pdf-processor](https://github.com/mbellary/pdf-processor)     | GA: build, test, deploy ECS | S3 (processed), SQS (work), Redis (cache) |
| Extraction    | [mbellary/text-extractor](https://github.com/mbellary/text-extractor)   | GA: build, test, publish    | S3 (pages), SQS (tasks) |
| Embeddings    | [mbellary/text-embedder](https://github.com/mbellary/text-embedder)     | GA: build, test, deploy     | DynamoDB (vectors*), S3 (models), Bedrock |
| Search / RAG  | [mbellary/text-rag](https://github.com/mbellary/text-rag)               | GA: build, test, deploy     | OpenSearch (search index), Redis (hot cache) |
| Infra (TF)    | [YOUR-ORG/infra-terraform](https://github.com/YOUR-ORG/infra-terraform) | GA: plan/apply via OIDC     | VPC, ECS, S3, SQS, DynamoDB, Redis, OpenSearch |

> *If vectors live outside DynamoDB, adjust to OpenSearch KNN or a vector DB.*

---

## 🧩 System Architecture

```mermaid
flowchart LR
  subgraph Source
    U[(Users)]
    Drop[(S3 Uploads)]
  end

  U -->|Documents| Loader
  Drop --> Loader

  Loader[file-loader]\n(S3 + SQS) --> Processor[pdf-processor]\n(ECS Tasks)
  Processor --> Extractor[text-extractor]\n(asyncio + parallelism)
  Extractor --> Embedder[text-embedder]\n(Bedrock/Titan)
  Embedder -->|Vectors| RAG[text-rag]\n(OpenSearch/Redis)
  RAG --> U

  subgraph Infra
    VPC[(VPC)]
    TF[(Terraform)]
    Redis[(Redis)]
    OS[(OpenSearch)]
    DDB[(DynamoDB)]
    S3[(S3)]
    SQS[(SQS)]
  end
  TF --- VPC & Redis & OS & DDB & S3 & SQS
```

---

## 🚀 Quickstart

1. **Clone** this meta-repo and initialize submodules:
   ```bash
   git clone git@github.com:YOUR-ORG/unstruct-platform.git
   cd unstruct-platform
   ./scripts/bootstrap.sh
   ```
2. **Browse** the linked modules (`modules/file-loader`, etc.) or use the table above.
3. (Optional) **Run a local demo** using emulators:
   ```bash
   docker compose -f compose/local-dev.compose.yaml up -d
   ```

---

## 🛠️ CI/CD Overview

- Each microservice manages its own **GitHub Actions** for build/test/deploy.  
- This meta-repo provides:
  - **Fan-out dispatch workflows** (`Dispatch to Service Repos`)
  - **Nightly status roll-up** & link checks.
- Terraform infra repo uses **AWS OIDC** for secure deployments.

---

## 🧱 Bootstrap Script (for submodules)

Save as `scripts/bootstrap.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

# ---- REPOSITORY URLs ----
INGESTION_URL="git@github.com:mbellary/file-loader.git"
PROCESSOR_URL="git@github.com:mbellary/pdf-processor.git"
EXTRACTION_URL="git@github.com:mbellary/text-extractor.git"
EMBEDDINGS_URL="git@github.com:mbellary/text-embedder.git"
SEARCH_URL="git@github.com:mbellary/text-rag.git"
INFRA_URL="git@github.com:YOUR-ORG/infra-terraform.git"

mkdir -p modules

add_or_update() {
  local name="$1" url="$2"
  if [ -d "modules/$name" ]; then
    echo "[update] $name"
    git submodule update --init --recursive --remote "modules/$name"
  else
    echo "[add] $name ← $url"
    git submodule add "$url" "modules/$name"
  fi
}

add_or_update file-loader      "$INGESTION_URL"
add_or_update pdf-processor    "$PROCESSOR_URL"
add_or_update text-extractor   "$EXTRACTION_URL"
add_or_update text-embedder    "$EMBEDDINGS_URL"
add_or_update text-rag         "$SEARCH_URL"
add_or_update infra            "$INFRA_URL"
```

---

## 🔐 Security & Secrets

- No production secrets should exist here — provide `.env.example` only.  
- Use **AWS OIDC** for GitHub Actions.  
- ECS tasks assume **IAM task roles** at runtime for S3, SQS, DynamoDB, OpenSearch, etc.

---

## 🧠 Architecture Decisions (ADR)

Keep track of design decisions under `docs/adr/` — for example:
- ADR-0001: Submodules vs Links-Only structure  
- ADR-0002: Redis caching scope  
- ADR-0003: Parallel ingestion & `asyncio` strategy  

---

## 📒 Runbooks

- **Ingestion stuck?** → Check `SQS` backlog and DynamoDB offset table.  
- **403 to OpenSearch?** → Verify IAM role, signature, and VPC endpoint.  
- **Worker fails in ECS?** → Inspect CloudWatch logs or run `aws ecs describe-tasks`.

---

## 🤝 Contributing

- Open issues here for **platform-level concerns** (cross-repo orchestration, architecture).  
- For service-specific bugs or enhancements, open issues directly in their respective repos.

---

## 📌 Roadmap

- ✅ Unified architecture diagrams  
- ✅ Shared local dev compose file  
- 🔜 Backstage developer portal using `catalog/`  
- 🔜 Centralized metrics dashboards & trace collection  

---

## 🧭 Tips & Gotchas

- If teammates dislike submodules, use the **Links-Only variant** (no `/modules`, just repo URLs).  
- Keep this repo **lightweight** — no build artifacts or docker images.  
- Store diagrams in `docs/diagrams/` using Mermaid or PlantUML, and auto-export to `images/` during releases.

---

> © 2025 Mohammed Ali — Unstruct Platform  
> _Meta-repository for cross-service orchestration, documentation, and developer onboarding._
