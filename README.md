# linthis-plugin-template Config Plugin

A linthis configuration plugin providing consistent linting and formatting rules.

## Supported Languages

| Language   | Linter/Formatter      | Config File             |
|------------|----------------------|-------------------------|
| Rust       | clippy, rustfmt      | `rust/clippy.toml`, `rust/rustfmt.toml` |
| Python     | ruff                 | `python/ruff.toml`      |
| TypeScript | eslint, prettier     | `typescript/.eslintrc.json`, `typescript/.prettierrc` |
| Go         | golangci-lint        | `go/.golangci.yml`      |
| Java       | checkstyle           | `java/checkstyle.xml`   |
| C/C++      | clang-format, cpplint| `cpp/.clang-format`, `cpp/CPPLINT.cfg` |
| Swift      | swiftlint, swift-format | `swift/.swiftlint.yml`, `swift/.swift-format` |
| Objective-C| clang-format         | `objectivec/.clang-format` |
| SQL        | sqlfluff             | `sql/.sqlfluff`         |
| C#         | dotnet-format        | `csharp/.editorconfig`  |
| Lua        | luacheck, stylua     | `lua/.luacheckrc`, `lua/stylua.toml` |
| CSS        | stylelint, prettier  | `css/.stylelintrc.json`, `css/.prettierrc` |
| Kotlin     | detekt               | `kotlin/.editorconfig`, `kotlin/detekt.yml` |
| Dockerfile | hadolint             | `dockerfile/.hadolint.yaml` |
| Scala      | scalafmt, scalafix   | `scala/.scalafmt.conf`, `scala/.scalafix.conf` |
| Dart       | dart analyzer        | `dart/analysis_options.yaml` |

## Usage

Add to your `.linthis/config.toml`:

```toml
[plugin]
sources = [
    { name = "linthis-plugin-template", url = "https://github.com/your-org/linthis-plugin-template.git" },
]
```

### With Version Pinning

```toml
[plugin]
sources = [
    { name = "linthis-plugin-template", url = "https://github.com/your-org/linthis-plugin-template.git", ref = "v1.0.0" },
]
```

## Customization

To override specific settings, you can:

1. **Layer plugins**: Add your overrides in a second plugin that loads after this one
2. **Local overrides**: Settings in your project's `.linthis/config.toml` override plugin settings
3. **Fork and modify**: Fork this repository and customize the configs

## Configuration Priority

Settings are applied in this order (later overrides earlier):

1. Built-in defaults
2. Plugin configs (in order listed in `sources`)
3. User config (`~/.linthis/config.toml`)
4. Project config (`.linthis/config.toml`)
5. CLI flags

## Contributing

1. Fork this repository
2. Make your changes
3. Test with: `linthis plugin validate .`
4. Submit a pull request

## License

MIT License - See LICENSE file for details.
