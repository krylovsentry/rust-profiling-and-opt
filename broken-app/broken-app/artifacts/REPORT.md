# broken-app: отчёт по исправлениям и оптимизациям

Все пути относительно каталога `artifacts/`.

## Среда

- OS: Windows 10 (x86_64-pc-windows-msvc)
- Reference: `reference-app/reference-app/` — см. [`reference_commit.txt`](reference_commit.txt)
- Подробности по инструментам: [`environment.txt`](environment.txt)
- Навигация по артефактам: [`README.md`](README.md)

| Инструмент | Лог |
|------------|-----|
| Miri | [`after/miri.txt`](after/miri.txt) |
| Valgrind | [`after/valgrind.txt`](after/valgrind.txt) |
| ASan | [`after/asan.txt`](after/asan.txt) |
| TSan | [`after/tsan.txt`](after/tsan.txt) |
| Clippy | [`after/clippy.txt`](after/clippy.txt) |
| GDB (до фикса) | [`before/gdb_session.txt`](before/gdb_session.txt) |
| perf + flamegraph | [`after/perf_report.txt`](after/perf_report.txt), [`plots/flamegraph.svg`](plots/flamegraph.svg) |

## Исправленные дефекты

| # | Проблема | Исправление | Регрессионный тест |
|---|----------|-------------|-------------------|
| 1 | off-by-one UB в `sum_even` | `.filter().sum()` | `sums_even_numbers`, `sum_even_empty_slice` |
| 2 | Утечка в `leak_buffer` | `iter().filter().count()` | `counts_non_zero_bytes` |
| 3 | `normalize` — только пробелы | `split_whitespace()` | `normalize_simple`, `normalize_strips_tabs_and_newlines` |
| 4 | `average_positive` — деление на все | фильтр `> 0` | `averages_only_positive` |
| 5 | UAF `use_after_free` | функция удалена | **нет отдельного теста** |
| 6 | data race в `concurrency` | `AtomicU64` | `race_increment_is_correct` |
| 7 | `slow_dedup` O(n²) | `HashSet` + один sort | `dedup_preserves_uniques` |
| 8 | `slow_fib` экспоненциально | итерация O(n) | `fib_small_numbers` |

## Оптимизации

### Алгоритмическая
- **slow_fib**: O(2ⁿ) → O(n)
- **slow_dedup**: O(n²) → O(n)

### Микро
- **leak_buffer**: убраны `Box` / raw pointer
- **slow_dedup**: sort на каждой вставке → один sort в конце
- **sum_even**: убран `unsafe`

## Результаты проверок

| Прогон | Файл | Результат |
|--------|------|-----------|
| До | [`before/cargo_test.txt`](before/cargo_test.txt) | паника `sums_even_numbers` (UB) |
| GDB | [`before/gdb_session.txt`](before/gdb_session.txt) | `average = 5.0`, ожидалось 10.0 |
| После | [`after/cargo_test.txt`](after/cargo_test.txt) | 9/9 passed |
| Miri | [`after/miri.txt`](after/miri.txt) | 9/9, UB нет |
| Valgrind | [`after/valgrind.txt`](after/valgrind.txt) | definitely lost: 0 |
| ASan | [`after/asan.txt`](after/asan.txt) | 9/9 |
| TSan | [`after/tsan.txt`](after/tsan.txt) | 9/9 (`setarch -R` в Docker) |
| Clippy | [`after/clippy.txt`](after/clippy.txt) | без предупреждений |

## Бенчмарки

### baseline (harness, release, 3 прогона)

| | До | После |
|---|-----|-------|
| Файл | [`before/baseline_bench.txt`](before/baseline_bench.txt) | [`after/baseline_bench.txt`](after/baseline_bench.txt) |
| sum_even (50k) | мс (без точных цифр) | ~15–35 µs |
| slow_fib(32) | **не завершён** (>15 мин) | ~100 ns |
| slow_dedup (10k) | секунды (без точных цифр) | ~140–170 µs |

### criterion

| | До (`cargo bench --bench criterion_broken`) | После (`cargo bench --bench criterion`) |
|---|-----|-------|
| Файл | [`before/criterion_bench.txt`](before/criterion_bench.txt) | [`after/criterion_bench.txt`](after/criterion_bench.txt) |
| sum_even (50k) | **пропущен** (UB) | ~33 µs |
| slow_fib | n=16 ~5.9 µs, n=18 ~16 µs, n=20 ~42 µs; **n=32 пропущен** | n=32 ~64 ns |
| slow_dedup (10k dup) | ~11.7 ms | ~247 µs |

Графики criterion (после): [`plots/criterion/`](plots/criterion/).

### Сравнение ускорения (criterion)

| Benchmark | До | После | Speedup |
|-----------|-----|-------|---------|
| slow_fib | ~42 µs (broken n=20) | ~64 ns (fixed n=32) | **~650×** |
| slow_fib(32) | >15 min (baseline) | ~64 ns | практически ∞ |
| slow_dedup (10k) | ~11.7 ms | ~247 µs | **~47×** |
| sum_even | UB, не измерялся | ~33 µs | корректность + безопасность |

### perf + flamegraph

Файлы: [`after/perf_report.txt`](after/perf_report.txt), [`plots/flamegraph.svg`](plots/flamegraph.svg), [`plots/perf.data`](plots/perf.data).

| Функция | Overhead |
|---------|----------|
| `sum_even` | ~52% |
| `slow_dedup` (HashMap::insert) | ~33% |
| `slow_fib` | ~13% |

## Узкие места (до оптимизации)

1. `slow_fib` — экспоненциальная рекурсия
2. `slow_dedup` — O(n²) + sort на каждой вставке
3. `sum_even` — off-by-one UB
4. `leak_buffer` — утечка через `into_raw`

## Структура артефактов

```
artifacts/
├── README.md
├── REPORT.md
├── environment.txt
├── reference_commit.txt
├── before/
│   ├── cargo_test.txt
│   ├── baseline_bench.txt
│   ├── criterion_bench.txt
│   └── gdb_session.txt
├── after/
│   ├── cargo_test.txt
│   ├── baseline_bench.txt
│   ├── criterion_bench.txt
│   ├── miri.txt, valgrind.txt, asan.txt, tsan.txt, clippy.txt
│   └── perf_report.txt, perf_run.log
└── plots/
    ├── flamegraph.svg
    ├── perf.data
    └── criterion/*.svg
```

## Изменённые файлы

- `src/lib.rs`, `src/concurrency.rs`, `src/algo.rs`
- `tests/integration.rs` (9 тестов)
- `benches/criterion.rs`, `benches/criterion_broken.rs`, `benches/baseline.rs`
- `examples/gdb_average_bug.rs`
- `scripts/` — `gdb-debug.sh`, `sanitizers.sh`, `valgrind.sh`, `profile.sh`, `docker-checks.sh`

---
