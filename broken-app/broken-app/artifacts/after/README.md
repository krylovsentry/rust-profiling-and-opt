# Состояние ПОСЛЕ исправлений

| Файл | Содержимое |
|------|------------|
| `cargo_test.txt` | 9/9 integration tests |
| `baseline_bench.txt` | release baseline (sum_even, slow_fib, slow_dedup) |
| `criterion_bench.txt` | criterion CSV/summary |
| `miri.txt` | 9/9, без UB |
| `valgrind.txt` | definitely lost: 0 |
| `asan.txt` | AddressSanitizer, 9/9 |
| `tsan.txt` | ThreadSanitizer, 9/9 |
| `clippy.txt` | без предупреждений |
| `perf_report.txt` | perf top symbols |
| `perf_run.log` | полный вывод profile.sh |

Графики: `../plots/flamegraph.svg`, `../plots/criterion/`.
