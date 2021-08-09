#include <vector>

int main() {
  int sum = 0;
  std::vector<int> A{1, 2, 3, 4};

  // for loop
  for (auto i = 0; i < A.size(); i++)
    sum += A[i];

  // range-based for loop
  for (auto v : A)
    sum += v;

  // std::transform
  decltype(A) s;
  std::transform(
      A.begin(), A.end(), std::back_inserter(s),
      [&s](decltype(A)::value_type v) { return s.empty() ? v : s.back() + v; });
  sum = s.back();

  // std::for_each
  std::for_each(A.begin(), A.end(), [&sum](int &v) { sum += v; });

  struct Sum {
    void operator()(int n) { sum += n; }
    int sum{0};
  };
  sum = (std::for_each(A.begin(), A.end(), Sum())).sum;
}