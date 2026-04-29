import { describe, it, expect } from 'vitest';
import { assignPersona } from './persona';

describe('assignPersona — boundary trio per Test Engineer Agent rules', () => {
  // A ≥ 75
  it('A: 75 (boundary at)', () => expect(assignPersona(75)).toBe('A'));
  it('A: 100 (above)', () => expect(assignPersona(100)).toBe('A'));
  it('B: 74.99 (just below A)', () => expect(assignPersona(74.99)).toBe('B'));

  // B: 70 ≤ x < 75
  it('B: 70 (boundary at)', () => expect(assignPersona(70)).toBe('B'));
  it('B: 74 (within)', () => expect(assignPersona(74)).toBe('B'));
  it('C: 69.99 (just below B)', () => expect(assignPersona(69.99)).toBe('C'));

  // C: 65 ≤ x < 70
  it('C: 65 (boundary at)', () => expect(assignPersona(65)).toBe('C'));
  it('C: 69 (within)', () => expect(assignPersona(69)).toBe('C'));
  it('D: 64.99 (just below C)', () => expect(assignPersona(64.99)).toBe('D'));

  // D: 60 ≤ x < 65
  it('D: 60 (boundary at — also baseline pass floor)', () => expect(assignPersona(60)).toBe('D'));
  it('D: 64 (within)', () => expect(assignPersona(64)).toBe('D'));
  it('E: 59.99 (just below D)', () => expect(assignPersona(59.99)).toBe('E'));

  // E: < 60
  it('E: 0 (floor)', () => expect(assignPersona(0)).toBe('E'));
  it('E: 59 (within)', () => expect(assignPersona(59)).toBe('E'));

  // Edge cases
  it('handles negative input as E (defensive)', () => expect(assignPersona(-1)).toBe('E'));
  it('handles >100 as A (defensive — should not happen but should not crash)', () =>
    expect(assignPersona(150)).toBe('A'));
});
