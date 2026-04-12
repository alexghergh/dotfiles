function lmgo --description "LLM inference through llama-server router mode. See also llama-server-models.ini."
    # set log path
    set -l default_log_path "$XDG_DATA_HOME/llama-server"
    set -l config_path "$XDG_CONFIG_HOME/fish/functions/llama-server-models.ini"

    # use env variables if set
    if set -q LLAMA_SERVER_LOG_PATH
        set -f log_path $LLAMA_SERVER_LOG_PATH
    else
        set -f log_path $default_log_path
    end

    set -l default_port 11435
    echo -s "Starting llama-server router mode. Listening on $default_port..."
    echo -s "Logging to '$log_path/server.log'."

    command mkdir -p $log_path
    or begin
        echo -s "Error: Failed to create log directory '$log_path'."
        return 1
    end

    if not test -f $config_path
        echo -es "Error: llama-server models preset not found."
        echo -es "\tWas looking for $config_path."
        return 1
    end

    set -l llama_server_bin "$PACKAGES/llama.cpp/build/bin/llama-server"

    if not test -x $llama_server_bin
        echo -es "Error: llama-server binary not found or not executable."
        echo -es "\tWas looking for $llama_server_bin."
        return 1
    end

    $llama_server_bin \
        --host 127.0.0.1 \
        --port $default_port \
        --models-preset $config_path \
        --models-max 1 \
        --sleep-idle-seconds 900 \
        --log-prefix \
        --log-timestamps \
        --threads 4 \
        --threads-batch 4 \
        --threads-http 4 \
        --batch-size 512 \
        --ubatch-size 2048 \
    &>> "$log_path/server.log"
    set -l lmgo_status $status

    if not test $lmgo_status -eq 0
        echo -s "Error: Failed to start the server. See '$log_path/server.log'."
        return 1
    end

    return $lmgo_status
end
