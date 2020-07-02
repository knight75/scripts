gp() {
    local first_arg="$1" \
          second_arg="$2"

    shift 2

    git push git@github.com:knight75/"$@".git
}
