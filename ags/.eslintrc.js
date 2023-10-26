module.exports = {
  env: {
    node: true,
    es2021: true,
  },

  extends: ["airbnb-base", "eslint:recommended", "plugin:prettier/recommended"],

  overrides: [
    {
      env: {
        node: true,
      },
      files: [".eslintrc.{js,cjs}"],
      parserOptions: {
        sourceType: "script",
      },
    },
  ],
  parserOptions: {
    ecmaVersion: "latest",
    sourceType: "module",
  },
  rules: {
    semi: ["error", "always"],
    quotes: ["error", "double"],
    "import/extensions": "off",
    "import/no-unresolved": ["error", { ignore: ["cairo"] }],
    "import/no-cycle": [
      "error",
      { ignoreExternal: true, allowUnsafeDynamicCyclicDependency: true },
    ],
    "no-unused-vars": "warn"
  },
};
