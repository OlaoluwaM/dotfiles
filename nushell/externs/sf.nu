######################################################### Completions Start ###################################################################
def fnm-node-version [] {
  ^fnm ls-remote | lines | each {|line| $line | str trim } | reverse
}

# From https://github.com/nushell/nu_scripts/blob/main/custom-completions/git/git-completions.nu
def "nu-complete git remotes" [] {
  ^git remote | lines | each { |line| $line | str trim }
}

# From https://github.com/nushell/nu_scripts/blob/main/custom-completions/git/git-completions.nu
# Yield local branches like `main`, `feature/typo_fix`
def "nu-complete git local branches" [] {
  ^git branch | lines | each { |line| $line | str replace '* ' "" | str trim }
}
######################################################### Completions Stop ###################################################################


export extern "sf updateNodeToLatest" []
export extern "sf unlockBWVault" []
export extern "sf areWallpapersBackedup" []
export extern "sf backupInstalledCrates" []
export extern "sf backupGlobalNpmPkgs" []
export extern "sf quote" []
export extern "sf backupGHExtensions" []

export extern "sf newRemoteBranch" [
    branchName?: string@"nu-complete git local branches",
    remote?: string@"nu-complete git remotes"
]

export extern "sf generatePsswd" [
    length?: number
]

export extern "sf updateNodeTo" [
  nodeVersion: string@"fnm-node-version"
]

export extern "sf twn" [
  duration: string
]

export extern "sf downloadFile" [
  url: string
  filename?: string              # Name to use when saving downloaded content
]

export extern "sf pkg" [
  command: string
]
