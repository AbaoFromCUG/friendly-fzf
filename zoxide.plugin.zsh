# vim: ft=zsh sw=2 ts=2 et foldmarker=[[[,]]] foldmethod=marker

_fzf_complete_z() {
  _fzf_complete "--multi" "$@" < <(
      zoxide query -a -l -s
  )
}

_fzf_complete_z_post() {
  # Post-process the fzf output to keep only the command name and not the explanation with it
  awk '{print $2}'
}

[ -n "$BASH" ] && complete -F _fzf_complete_z -o default -o bashdefault z
