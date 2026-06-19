//! Criterion «до» — сломанные slow_fib / slow_dedup.
//! sum_even_broken (UB off-by-one) не бенчмаркается — падает при прогреве; см. cargo_test.txt.
use criterion::{criterion_group, criterion_main, BatchSize, Criterion, BenchmarkId};
use std::time::Duration;

#[inline(never)]
fn slow_fib_broken(n: u64) -> u64 {
    match n {
        0 => 0,
        1 => 1,
        _ => slow_fib_broken(n - 1) + slow_fib_broken(n - 2),
    }
}

#[inline(never)]
fn slow_dedup_broken(values: &[u64]) -> Vec<u64> {
    let mut out = Vec::new();
    for v in values {
        let mut seen = false;
        for existing in &out {
            if existing == v {
                seen = true;
                break;
            }
        }
        if !seen {
            out.push(*v);
            out.sort_unstable();
        }
    }
    out
}

fn bench_fib(c: &mut Criterion) {
    let mut group = c.benchmark_group("slow_fib_broken");
    group.sample_size(10);
    group.measurement_time(Duration::from_secs(5));
    group.warm_up_time(Duration::from_secs(2));
    // fib(32): >15 мин (см. baseline_bench.txt). Сравниваем малые n и фиксируем рост.
    for n in [16u64, 18, 20] {
        group.bench_with_input(BenchmarkId::from_parameter(n), &n, |b, &n_val| {
            let n_ptr = &n_val as *const u64;
            b.iter(|| {
                let n = unsafe { std::ptr::read_volatile(n_ptr) };
                std::hint::black_box(slow_fib_broken(n))
            });
        });
    }
    group.finish();
}

fn bench_dedup(c: &mut Criterion) {
    let data: Vec<u64> = (0..5_000).flat_map(|n| [n, n]).collect();
    let mut group = c.benchmark_group("slow_dedup_broken");
    group.sample_size(10);
    group.measurement_time(Duration::from_secs(5));
    group.bench_function("10k_dup", |b| {
        b.iter_batched(
            || data.clone(),
            |v| {
                let _ = slow_dedup_broken(&v);
            },
            BatchSize::SmallInput,
        )
    });
    group.finish();
}

criterion_group!(benches, bench_fib, bench_dedup);
criterion_main!(benches);
