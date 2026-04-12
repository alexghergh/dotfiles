function lmgo -d "LLM inference through llama-swap (llama.cpp as a local backend). See also llama-swap-config.yaml."
    # set log path
    set -l default_log_path "$XDG_DATA_HOME/llama-swap"
    set -l config_path "$XDG_CONFIG_HOME/fish/functions/llama-swap-config.yaml"

    # use env variables if set
    if set -q LLAMA_SWAP_LOG_PATH
        set -f log_path $LLAMA_SWAP_LOG_PATH
    else
        set -f log_path $default_log_path
    end

    set -l default_port 11435
    echo -s "Starting llama-swap (llama.cpp backend) server. Listening on $default_port..."
    echo -s "Logging to '$log_path/server.log'."

    command mkdir -p $log_path
    or begin
        echo -s "Error: Failed to create log directory '$log_path'."
        return 1
    end

    if not test -f $config_path
        echo -es "Error: llama-swap config not found."
        echo -es "\tWas looking for $config_path."
        return 1
    end

    set -l llamaswap_bin "$PACKAGES/llama-swap/build/llama-swap-linux-arm64"

    if not test -x $llamaswap_bin
        echo -es "Error: llama-swap server binary not found or not executable."
        echo -es "\tWas looking for $llamaswap_bin."
        return 1
    end

    $llamaswap_bin \
        -listen :$default_port \
        -config $config_path \
    &>> "$log_path/server.log"
    set -l lmgo_status $status

    if not test $lmgo_status -eq 0
        echo -s "Error: Failed to start the server. See '$log_path/server.log'."
        return 1
    end

    return $lmgo_status
end
