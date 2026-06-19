# rust-profiling-and-opt

Практикум: исправление дефектов, верификация (Miri, Valgrind, sanitizers) и оптимизация **broken-app** с опорой на **reference-app**.

## Навигация

| Раздел | Путь | Описание |
|--------|------|----------|
| **broken-app** | [`broken-app/broken-app/`](broken-app/broken-app/) | Исправленный проект: исходники, тесты, бенчмарки |
| **reference-app** | [`reference-app/reference-app/`](reference-app/reference-app/) | Эталонное поведение (без изменений) |
| **Отчёт** | [`broken-app/broken-app/artifacts/REPORT.md`](broken-app/broken-app/artifacts/REPORT.md) | Баги, оптимизации, таблица ускорений |
| **Артефакты** | [`broken-app/broken-app/artifacts/`](broken-app/broken-app/artifacts/) | Логи «до» / «после», графики, flamegraph |
| **Карта артефактов** | [`broken-app/broken-app/artifacts/README.md`](broken-app/broken-app/artifacts/README.md) | Структура `before/`, `after/`, `plots/` |
| **Среда** | [`broken-app/broken-app/artifacts/environment.txt`](broken-app/broken-app/artifacts/environment.txt) | OS, Docker, ограничения Windows |
| **Reference hash** | [`broken-app/broken-app/artifacts/reference_commit.txt`](broken-app/broken-app/artifacts/reference_commit.txt) | путь reference-app |

### Исходники broken-app

| Файл | Назначение |
|------|------------|
| [`src/lib.rs`](broken-app/broken-app/src/lib.rs) | Основная логика |
| [`src/algo.rs`](broken-app/broken-app/src/algo.rs) | Алгоритмы (fib, dedup) |
| [`src/concurrency.rs`](broken-app/broken-app/src/concurrency.rs) | Потоки и атомики |
| [`tests/integration.rs`](broken-app/broken-app/tests/integration.rs) | Интеграционные и регрессионные тесты |
| [`benches/`](broken-app/broken-app/benches/) | baseline, criterion |
| [`scripts/`](broken-app/broken-app/scripts/) | GDB, Valgrind, sanitizers, perf, Docker |

## Быстрый старт

```powershell
# из корня репозитория
cd broken-app/broken-app
cargo test
cargo clippy -- -D warnings
cargo bench --bench criterion
```

Linux / Docker (Valgrind, ASan, TSan, perf):

```bash
cd broken-app/broken-app
bash scripts/docker-checks.sh
```
