# Состояние ДО исправлений

| Файл | Содержимое |
|------|------------|
| `cargo_test.txt` | `cargo test` — паника в `sums_even_numbers` (off-by-one UB) |
| `baseline_bench.txt` | baseline bench; `slow_fib(32)` не завершился за 15+ мин |
| `criterion_bench.txt` | criterion `criterion_broken`: slow_fib (16/18/20), slow_dedup; sum_even и fib(32) пропущены (UB / экспонента) |
| `gdb_session.txt` | GDB: логический баг `average_positive` (5.0 vs 10.0) |

Ожидаемые падения: `sums_even_numbers`, `averages_only_positive`.
