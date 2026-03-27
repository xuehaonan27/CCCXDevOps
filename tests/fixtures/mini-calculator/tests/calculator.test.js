const { describe, it } = require('node:test');
const assert = require('node:assert');
const { add, subtract } = require('../src/calculator');

describe('calculator', () => {
  it('adds two numbers', () => {
    assert.strictEqual(add(2, 3), 5);
    assert.strictEqual(add(-1, 1), 0);
    assert.strictEqual(add(0, 0), 0);
  });

  it('subtracts two numbers', () => {
    assert.strictEqual(subtract(5, 3), 2);
    assert.strictEqual(subtract(1, 1), 0);
    assert.strictEqual(subtract(0, 5), -5);
  });
});
