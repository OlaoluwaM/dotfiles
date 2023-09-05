def fnm-node-version [] {
  ^fnm ls-remotes | lines | each {|line| $line | str trim}
}
