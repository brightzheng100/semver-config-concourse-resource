export TMPDIR=${TMPDIR:-/tmp}

function element_exists() {
    element=$1 && shift
	elements=($@)

    for e in "${elements[@]}"
    do
        if [[ "$e" == "$element" ]] ; then
            echo "true"
            return 0
        fi
    done

    echo "false"
}

function verify() {
    name=$1 && shift
    value=$1 && shift
    acceptable=($@)

    if [ -z $value ]; then
        echo "$name must be set \n" && return 0
    fi

    message=""
    if [[ ${#acceptable[@]} > 0 ]]; then
        result="$(element_exists "$value" "${acceptable[@]}")"
        if [[ $result == "false" ]]; then
            message="$name is now set as $value, instead of required: ${acceptable[@]} \n"
        fi
    fi

    echo $message && return 0
}

# m.n.p
function verify_version_pattern() {
    p=$1

    if [ -z "$p" ]; then
        echo "version_pattern must be set \n" && return 0
    fi

    if [[ $p != "m.*.*" ]] && 
        [[ "$p" != "m.n.*" ]] &&
        [[ "$p" != "m.n.p" ]] && 
        [[ "$p" != "*.n.*" ]] &&
        [[ "$p" != "*.*.p" ]]; then
        echo "version_pattern is not valid: $p" && return 0
    fi

    echo "" && return 0
}

function setup_ssh_key() {
    local git_private_key=$1
    local forward_agent=$2 #$(jq -r '.source.forward_agent // false' < $1)

    if [ -s $git_private_key ]; then
        chmod 0600 $git_private_key

        eval $(ssh-agent) >/dev/null 2>&1
        trap "kill $SSH_AGENT_PID" EXIT

        SSH_ASKPASS=$(dirname $0)/askpass.sh DISPLAY= ssh-add $git_private_key >/dev/null

        mkdir -p ~/.ssh
        cat > ~/.ssh/config <<EOF
            StrictHostKeyChecking no
            LogLevel quiet
EOF
        if [ "$forward_agent" = "true" ]; then
        cat >> ~/.ssh/config <<EOF
            ForwardAgent yes
EOF
        fi
        chmod 0600 ~/.ssh/config
  fi
}