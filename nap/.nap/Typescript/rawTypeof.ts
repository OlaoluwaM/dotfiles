type RawTypes = Lowercase<
  'Function' | 'Object' | 'Array' | 'Null' | 'Undefined' | 'String' | 'Number' | 'Boolean'
>;
export function rawTypeOf(value: unknown): RawTypes {
  return Object.prototype.toString
    .call(value)
    .replace(/\[|\]|object|\s/g, '')
    .toLocaleLowerCase() as RawTypes;
}
