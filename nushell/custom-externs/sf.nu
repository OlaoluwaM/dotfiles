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
