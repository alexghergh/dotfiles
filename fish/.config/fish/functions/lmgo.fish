function lmgo -d "LLM inference through llama-swap (llama.cpp as a local backend). See also llama-swap-config.yaml."
    # set log path
    set -l default_log_path "$XDG_DATA_HOME/llama-swap"

    # use env variables if set
    if set -q LLAMA_SWAP_LOG_PATH
        set -f log_path $LLAMA_SWAP_LOG_PATH
    else
        set -f log_path $default_log_path
    end

    echo -s "Starting llama-swap (llama.cpp backend) server"
    echo -s "Logging to '$log_path/server.log'."

    set -l llamaswap_bin "$HOME"/packages/llama-swap/build/llama-swap-linux-arm64

    if not test -x $llamaswap_bin
        echo -es "Error: llama-swap server binary not found or not executable."
        echo -es "\tWas looking for $llamaswap_bin."
        return 1
    end

    $llamaswap_bin \
        -listen :11435 \
        -config "$HOME"/.config/fish/functions/llama-swap-config.yaml \
    &>> "$log_path/server.log"

    if not test $status -eq 0
        echo -s "Error: Failed to start the server. See '$log_path/server.log'."
        return 1
    end
end
