export PROMPT_COMMAND="history -a; history -n"
export LESS='-R -F -X'
export EDITOR=vim

case "$(uname -s)" in
  Darwin) export OS=mac ;;
  Linux)  export OS=linux ;;
esac

if [[ $OS == linux && -n "$CODESPACES" ]]; then
    export NODE_OPTIONS="--max-old-space-size=4096"
fi
