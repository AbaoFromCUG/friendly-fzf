# vim: ft=zsh sw=2 ts=2 et foldmarker=[[[,]]] foldmethod=marker
FZF_PODMAN_PS_FORMAT="table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Ports}}"
FZF_PODMAN_PS_START_FORMAT="table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Image}}"

_fzf_complete_podman() {
  # Get all podman commands
  #
  # Cut below "Management Commands:", then exclude "Management Commands:",
  # "Commands:" and the last line of the help. Then keep the first column and
  # delete empty lines
  podman_COMMANDS=$(podman --help 2>&1 >/dev/null |
    sed -n -e '/Management Commands:/,$p' |
    grep -v "Management Commands:" |
    grep -v "Commands:" |
    grep -v 'COMMAND --help' |
    grep .
  )

  ARGS="$@"
  if [[ $ARGS == 'podman ' ]]; then
    _fzf_complete "--reverse -n 1 --height=80%" "$@" < <(
      echo $podman_COMMANDS
    )
  elif [[ $ARGS == 'podman tag'* || $ARGS == 'podman -f'* || $ARGS == 'podman run'* || $ARGS == 'podman push'* ]]; then
    _fzf_complete "--multi --header-lines=1" "$@" < <(
      podman images --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}\t{{.ID}}\t{{.CreatedSince}}"
    )
  elif [[ $ARGS == 'podman rmi'* || $ARGS == 'podman image rm'* ]]; then
    _fzf_complete "--multi --header-lines=1" "$@" < <(
      podman images --format "table {{.ID}}\t{{.Repository}}\t{{.Tag}}\t{{.Size}}"
    )
  elif [[ $ARGS == 'podman stop'* || $ARGS == 'podman exec'* || $ARGS == 'podman kill'* || $ARGS == 'podman restart'* ]]; then
    _fzf_complete "--multi --header-lines=1 " "$@" < <(
      podman ps --format "${FZF_PODMAN_PS_FORMAT}"
    )  
  elif [[ $ARGS == 'podman logs'* ]]; then
    _fzf_complete "--multi --header-lines=1 --header 'Enter CTRL-O to open log in editor | CTRL-/ to change height\n\n' --bind 'ctrl-/:change-preview-window(80%,border-bottom|)' --bind \"ctrl-o:execute:podman logs {1} | sed 's/\x1b\[[0-9;]*m//g' | cat | ${EDITOR:-vim} -\" --preview-window up:follow --preview 'podman logs --follow --tail=100 {1}' " "$@" < <(
      podman ps -a --format "${FZF_PODMAN_PS_FORMAT}"
    )
  elif [[ $ARGS == 'podman rm'* || $ARGS == 'podman container rm'* ]]; then
    _fzf_complete "--multi --header-lines=1 " "$@" < <(
      podman ps -a --format "${FZF_PODMAN_PS_FORMAT}"
  )
  elif [[ $ARGS == 'podman start'* ]]; then
     _fzf_complete "--multi --header-lines=1 " "$@" < <(
      podman ps -a --format "${FZF_PODMAN_PS_START_FORMAT}"
    )
  fi
}

_fzf_complete_podman_post() {
  # Post-process the fzf output to keep only the command name and not the explanation with it
  awk '{print $1}'
}

[ -n "$BASH" ] && complete -F _fzf_complete_podman -o default -o bashdefault podman
