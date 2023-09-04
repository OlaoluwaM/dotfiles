def get-repo-root [dir: path]: nothing -> path {
    if $dir == null { return "" }
    do -i { git -C $dir rev-parse --show-toplevel } | complete | get stdout | str trim
}

def ls-on-dir-change [] {
    try { logo-ls } catch { ls }
}
