"""
Unit tests for QuizService._shuffled()

Feature: Baseline assessment options are shuffled
Scope:   QuizService._shuffled() is a @staticmethod — no DB session required.

Covers:
  - Options are not lost or duplicated after shuffle (set-identity check)
  - Shuffle produces more than one distinct ordering across 20 iterations
    (probabilistic — P(all same order with 4 items) ≈ (1/24)^19 ≈ 10^-26)
  - Original list is not mutated by _shuffled()
  - Empty list is handled gracefully (returns empty list, no crash)
  - Single-element list is handled gracefully (returns identical list)
  - Order-number field on each option dict is preserved after shuffle
"""

import sys
import os

# Allow importing from the coaching-api package without an installed editable install.
# Adjust path so `from app.services.quiz_service import QuizService` resolves.
sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

import pytest
from app.services.quiz_service import QuizService


# ---------------------------------------------------------------------------
# Fixtures
# ---------------------------------------------------------------------------

def _make_options(n: int = 4) -> list[dict]:
    """Return a list of n synthetic option dicts that mirror the real shape."""
    return [
        {
            "id": f"opt-{i}",
            "option_text": f"Option text {i}",
            "is_correct": (i == 0),
            "order_number": i,
        }
        for i in range(n)
    ]


# ---------------------------------------------------------------------------
# 1. Set-identity: no options lost or duplicated
# ---------------------------------------------------------------------------

class TestShufflePreservesElements:
    def test_four_options_all_ids_present(self):
        """Shuffling 4 options must return all 4 option IDs — no loss, no duplicate."""
        options = _make_options(4)
        result = QuizService._shuffled(options)

        assert sorted(r["id"] for r in result) == sorted(o["id"] for o in options)

    def test_count_unchanged(self):
        """Returned list must have the same length as the input."""
        options = _make_options(4)
        result = QuizService._shuffled(options)
        assert len(result) == len(options)

    def test_option_text_preserved(self):
        """Every option_text value from the original must appear in the result."""
        options = _make_options(4)
        original_texts = {o["option_text"] for o in options}
        result = QuizService._shuffled(options)
        result_texts = {r["option_text"] for r in result}
        assert original_texts == result_texts

    def test_order_number_field_survives_shuffle(self):
        """The order_number field on each dict must not be stripped during shuffle."""
        options = _make_options(4)
        result = QuizService._shuffled(options)
        for item in result:
            assert "order_number" in item, (
                f"order_number missing on item after shuffle: {item}"
            )

    def test_is_correct_field_survives_shuffle(self):
        """The is_correct field must not be stripped or altered during shuffle."""
        options = _make_options(4)
        correct_before = {o["id"]: o["is_correct"] for o in options}
        result = QuizService._shuffled(options)
        for item in result:
            assert item["is_correct"] == correct_before[item["id"]], (
                f"is_correct changed for option {item['id']} after shuffle"
            )


# ---------------------------------------------------------------------------
# 2. Non-determinism: multiple shuffles produce different orderings
# ---------------------------------------------------------------------------

class TestShuffleNonDeterminism:
    def test_produces_multiple_distinct_orderings(self):
        """
        Over 20 shuffles of a 4-element list, at least 2 distinct orderings
        must appear. With 4! = 24 possible permutations the probability of
        all 20 draws landing on the same permutation is (1/24)^19 < 10^-25.
        """
        options = _make_options(4)
        seen_orders: set[tuple] = set()

        for _ in range(20):
            result = QuizService._shuffled(options)
            order = tuple(r["id"] for r in result)
            seen_orders.add(order)

        assert len(seen_orders) > 1, (
            "After 20 shuffles of a 4-element list, all orderings were identical. "
            "This indicates shuffle is not functioning."
        )

    def test_boundary_two_element_list_may_swap(self):
        """
        A 2-element list has only 2 permutations. Over 50 shuffles at least
        one swap should occur (P(no swap ever) = (1/2)^50 ≈ 10^-15).
        """
        options = _make_options(2)
        original_order = tuple(o["id"] for o in options)
        seen_swapped = False

        for _ in range(50):
            result = QuizService._shuffled(options)
            if tuple(r["id"] for r in result) != original_order:
                seen_swapped = True
                break

        assert seen_swapped, (
            "50 shuffles of a 2-element list never produced a swap. "
            "Shuffle is likely broken."
        )


# ---------------------------------------------------------------------------
# 3. Non-mutation: original list must be unchanged
# ---------------------------------------------------------------------------

class TestShuffleDoesNotMutateOriginal:
    def test_original_list_object_unchanged(self):
        """_shuffled() must not mutate the list it was given."""
        options = _make_options(4)
        original_snapshot = [o["id"] for o in options]

        QuizService._shuffled(options)

        assert [o["id"] for o in options] == original_snapshot, (
            "_shuffled() mutated the original list"
        )

    def test_original_dict_values_unchanged(self):
        """_shuffled() must not mutate the dict values inside the list."""
        options = _make_options(4)
        original_snapshot = {o["id"]: dict(o) for o in options}

        QuizService._shuffled(options)

        for opt in options:
            assert opt == original_snapshot[opt["id"]], (
                f"Dict for option {opt['id']} was mutated by _shuffled()"
            )


# ---------------------------------------------------------------------------
# 4. Edge cases: empty and single-element inputs
# ---------------------------------------------------------------------------

class TestShuffleEdgeCases:
    def test_empty_list_returns_empty_list(self):
        """_shuffled([]) must return [] without raising."""
        result = QuizService._shuffled([])
        assert result == []

    def test_single_element_returns_single_element(self):
        """_shuffled with one item must return a list with that same item."""
        options = _make_options(1)
        result = QuizService._shuffled(options)
        assert len(result) == 1
        assert result[0]["id"] == options[0]["id"]

    def test_returns_new_list_object(self):
        """_shuffled() must return a new list, not the same object."""
        options = _make_options(4)
        result = QuizService._shuffled(options)
        assert result is not options, (
            "_shuffled() returned the same list object — original would be mutated"
        )
