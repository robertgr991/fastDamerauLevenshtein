import unittest
import fastDamerauLevenshtein


class TestDamerauLevenshtein(unittest.TestCase):
    def test_damerauLevenshtein(self):
        assert fastDamerauLevenshtein.damerauLevenshtein("ca", "abc", False) == 2.0
        assert fastDamerauLevenshtein.damerauLevenshtein("a cat", "a abct", False) == 2.0
        assert fastDamerauLevenshtein.damerauLevenshtein(["ab", "cd"], ["ab"], False) == 1.0
        assert fastDamerauLevenshtein.damerauLevenshtein("car", "cars") == 0.75
        assert fastDamerauLevenshtein.damerauLevenshtein("", "", False) == 0.0
        assert fastDamerauLevenshtein.damerauLevenshtein("", "") == 1.0
        assert fastDamerauLevenshtein.damerauLevenshtein([], [], False) == 0.0
        assert fastDamerauLevenshtein.damerauLevenshtein([], []) == 1.0


if __name__ == '__main__':
    unittest.main()
