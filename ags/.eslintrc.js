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

  globals: {
    print: "writeable",
  },

  rules: {
    semi: ["error", "always"],
    quotes: ["error", "double"],

    "import/extensions": "off",

    "import/no-unresolved": [
      "error",
      {
        ignore: ["cairo", "gi://Gtk", "gi://Gdk", "gi://GLib", "gi://GObject"],
      },
    ],

    "import/no-cycle": [
      "error",
      { ignoreExternal: true, allowUnsafeDynamicCyclicDependency: true },
    ],

    "no-unused-vars": "warn",
    "import/no-dynamic-require": "off",

    "no-restricted-globals": "off",
    "no-console": ["error", { allow: ["warn", "error"] }],

    "no-underscore-dangle": "off",
    "comma-dangle": "off",
  },
};
