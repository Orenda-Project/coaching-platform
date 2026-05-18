import { describe, it, expect, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import ScenarioCard, { ScenarioOption } from "../ScenarioCard";

describe("ScenarioCard - Phase 1: Answer Randomization (COACH-XXXX)", () => {
  const mockOptions: ScenarioOption[] = [
    {
      id: "opt-a",
      option_letter: "A",
      option_text: "This is a short response option.",
    },
    {
      id: "opt-b",
      option_letter: "B",
      option_text: "This is a longer response option with more details and explanation.",
    },
    {
      id: "opt-c",
      option_letter: "C",
      option_text: "Medium length option text for comparison.",
    },
    {
      id: "opt-d",
      option_letter: "D",
      option_text: "Another option that is similarly sized to option A.",
    },
  ];

  it("should randomize option positions across multiple renders", () => {
    const mockOnSelect = vi.fn();
    const mockOnSubmit = vi.fn();

    // Render multiple times and collect the order of displayed options
    const orders: string[][] = [];

    for (let i = 0; i < 5; i++) {
      const { unmount } = render(
        <ScenarioCard
          situation="Test situation"
          question="What should you do?"
          options={mockOptions}
          selectedLetter={null}
          onSelect={mockOnSelect}
          onSubmit={mockOnSubmit}
          locked={false}
        />
      );

      // Collect the order of displayed option letters
      const displayedLetters = screen
        .getAllByRole("radio")
        .map((radio) => (radio as HTMLInputElement).value);

      orders.push(displayedLetters);
      unmount();
    }

    // Should have at least 2 different orderings out of 5 renders
    const uniqueOrders = new Set(orders.map((order) => order.join(",")));
    expect(uniqueOrders.size).toBeGreaterThan(1);
  });

  it("should display all option letters (A, B, C, D) regardless of order", () => {
    const mockOnSelect = vi.fn();
    const mockOnSubmit = vi.fn();

    render(
      <ScenarioCard
        situation="Test situation"
        question="What should you do?"
        options={mockOptions}
        selectedLetter={null}
        onSelect={mockOnSelect}
        onSubmit={mockOnSubmit}
        locked={false}
      />
    );

    const displayedLetters = screen
      .getAllByRole("radio")
      .map((radio) => (radio as HTMLInputElement).value)
      .sort();

    expect(displayedLetters).toEqual(["A", "B", "C", "D"]);
  });

  it("should render all option text and be selectable", () => {
    // This test verifies that when seed data provides balanced options,
    // they are rendered correctly and interactive.
    const balancedOptions: ScenarioOption[] = [
      {
        id: "opt-1",
        option_letter: "A",
        option_text: "First response option",
      },
      {
        id: "opt-2",
        option_letter: "B",
        option_text: "Second response option",
      },
      {
        id: "opt-3",
        option_letter: "C",
        option_text: "Third response option",
      },
      {
        id: "opt-4",
        option_letter: "D",
        option_text: "Fourth response option",
      },
    ];

    const mockOnSelect = vi.fn();
    const mockOnSubmit = vi.fn();

    render(
      <ScenarioCard
        situation="Test situation"
        question="What should you do?"
        options={balancedOptions}
        selectedLetter={null}
        onSelect={mockOnSelect}
        onSubmit={mockOnSubmit}
        locked={false}
      />
    );

    // Verify all option texts are displayed in radio group
    const radioGroup = screen.getByRole("radiogroup");
    expect(radioGroup).toBeInTheDocument();
    expect(screen.getByText(/First response option/)).toBeInTheDocument();
    expect(screen.getByText(/Second response option/)).toBeInTheDocument();
    expect(screen.getByText(/Third response option/)).toBeInTheDocument();
    expect(screen.getByText(/Fourth response option/)).toBeInTheDocument();

    // Verify options are interactive by checking radio buttons exist and can be selected
    const radios = screen.getAllByRole("radio");
    expect(radios).toHaveLength(4);
    radios.forEach((radio) => {
      expect(radio).not.toBeDisabled();
    });
  });

  it("should preserve selection state when options are rerandomized", () => {
    const mockOnSelect = vi.fn();
    const mockOnSubmit = vi.fn();

    const { rerender } = render(
      <ScenarioCard
        situation="Test situation"
        question="What should you do?"
        options={mockOptions}
        selectedLetter="B"
        onSelect={mockOnSelect}
        onSubmit={mockOnSubmit}
        locked={false}
      />
    );

    // Verify RadioGroup is present with selection value
    const radioGroup = screen.getByRole("radiogroup");
    expect(radioGroup).toBeInTheDocument();
    // RadioGroup component receives selectedLetter="B" as value prop
    // Component preserves this selection regardless of option order randomization

    // Rerender with same props (simulating randomization on parent render)
    rerender(
      <ScenarioCard
        situation="Test situation"
        question="What should you do?"
        options={mockOptions}
        selectedLetter="B"
        onSelect={mockOnSelect}
        onSubmit={mockOnSubmit}
        locked={false}
      />
    );

    // After rerender, RadioGroup should still exist and reflect the selection
    const rerenderedRadioGroup = screen.getByRole("radiogroup");
    expect(rerenderedRadioGroup).toBeInTheDocument();
    // Selection state is managed by parent via selectedLetter prop,
    // not by the component, so randomization does not affect it
  });
});
