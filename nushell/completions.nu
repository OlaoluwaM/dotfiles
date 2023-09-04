# External completer example https://www.nushell.sh/cookbook/external_completers.html

# This completer will use carapace by default
let external_completer = {|spans|
    let expanded_alias = (scope aliases | where name == $spans.0 | get -i 0 | get -i expansion)
    let spans = (if $expanded_alias != null  {
        $spans | skip 1 | prepend ($expanded_alias | split words)
    } else { $spans })

    let zoxide_completer = {|spans|
    $spans | skip 1 | zoxide query -l $in | lines | where {|x| $x != $env.PWD}
    }

    let fish_completer = {|spans|
        fish --command $'complete "--do-complete=($spans | str join " ")"'
        | $"value(char tab)description(char newline)" + $in
        | from tsv --flexible --no-infer
    }

    let carapace_completer = {|spans: list<string>|
        carapace $spans.0 nushell $spans
        | from json
        | if ($in | default [] | where value =~ '^-.*ERR$' | is-empty) { $in } else { null }
    }

    {
        # carapace completions are incorrect for nu
        nu: $fish_completer
        # fish completes commits and branch names in a nicer way
        git: $fish_completer
        # carapace doesn't have completions for asdf
        asdf: $fish_completer
        # Zoxide Completions
        __zoxide_z: $zoxide_completer
        __zoxide_zi: $zoxide_completer
    } | get -i $spans.0 | default $carapace_completer | do $in $spans
}
