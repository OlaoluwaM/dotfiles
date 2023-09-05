# From https://github.com/nushell/nu_scripts/blob/main/custom-completions/git/git-completions.nu
def "nu-complete git remotes" [] {
  ^git remote | lines | each { |line| $line | str trim }
}

# From https://github.com/nushell/nu_scripts/blob/main/custom-completions/git/git-completions.nu
# Yield local branches like `main`, `feature/typo_fix`
def "nu-complete git local branches" [] {
  ^git branch | lines | each { |line| $line | str replace '\* ' "" | str trim }
}
