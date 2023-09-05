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


######################################################### Externs Start ###################################################################

################################### sf Externs Start ##########################################
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

export extern "sf updateNodeToLatest" []

export extern "sf unlockBwVault" []

export extern "sf areWallpapersBackedup" []
################################### sf Externs Stop ##########################################

######################################################### Externs Stop ###################################################################
