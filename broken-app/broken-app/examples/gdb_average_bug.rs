//! Минимальный пример с **исходным** багом в `average_positive` для GDB.
//! Не используется в тестах — только отладка (см. `scripts/gdb-debug.sh`).

/// Баг: среднее по всем элементам, а не только по положительным.
pub fn average_positive_broken(values: &[i64]) -> f64 {
    let sum: i64 = values.iter().sum();
    if values.is_empty() {
        return 0.0;
    }
    sum as f64 / values.len() as f64
}

fn main() {
    let nums = [-5_i64, 5, 15];
    let avg = average_positive_broken(&nums);
    println!("average = {avg}"); // ожидали 10.0, получаем 5.0
}
