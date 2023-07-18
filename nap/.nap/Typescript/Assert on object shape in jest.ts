
// Context: When you want to assert that some data matches some shape without specifying exact values

// https://github.com/facebook/jest/issues/2143
// https://github.com/facebook/jest/issues/2143#issuecomment-416611135


expect({ foo: 'bar', baz: 'qux' }).toMatchObject({
  foo: expect.anything(),
  baz: expect.any(String)
})
