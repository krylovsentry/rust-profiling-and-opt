# Артефакты broken-app

Структура для проверки «до» и «после» исправлений.

```
artifacts/
├── README.md              ← этот файл
├── REPORT.md              ← полный отчёт
├── reference_commit.txt   ← hash reference-app
├── environment.txt        ← среда, ограничения Windows, как запускать Docker-скрипты
│
├── before/                ← исходное сломанное состояние
│   ├── cargo_test.txt     ← cargo test (падения)
│   ├── baseline_bench.txt ← baseline bench (частично)
│   ├── criterion_bench.txt
│   └── gdb_session.txt    ← GDB на баге average_positive
│
├── after/                 ← после фиксов и оптимизаций
│   ├── cargo_test.txt
│   ├── baseline_bench.txt
│   ├── criterion_bench.txt
│   ├── miri.txt
│   ├── valgrind.txt
│   ├── asan.txt
│   ├── tsan.txt
│   ├── clippy.txt
│   ├── perf_report.txt
│   └── perf_run.log
│
└── plots/
    ├── flamegraph.svg
    ├── perf.data
    └── criterion/
        ├── sum_even.svg
        ├── slow_fib.svg
        └── slow_dedup.svg
```

## Быстрый прогон (Linux / Docker)

```bash
bash scripts/organize-artifacts.sh   # упорядочить файлы
bash scripts/gdb-debug.sh            # GDB → before/gdb_session.txt
bash scripts/docker-checks.sh        # sanitizers + perf → after/
```

## Windows

Нативно: `cargo test`, `cargo +nightly miri test`, `cargo clippy`.  
Valgrind / ASan / TSan / perf: `docker run --privileged --security-opt seccomp=unconfined -v "%cd%:/app" -w /app postgres:16 bash scripts/docker-checks.sh`
