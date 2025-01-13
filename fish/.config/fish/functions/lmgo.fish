function lmgo -d "Run an LLM through Llama.cpp's server command."

    # set models path
    set -l default_models_path "$HOME/.llama.cpp/models"

    # use env variables if set
    if set -q LLAMA_CPP_MODELS_PATH
        set -f models_path $LLAMA_CPP_MODELS_PATH
    else
        set -f models_path $default_models_path
    end

    if not test -d $models_path
        echo -s "Error: Models path '$models_path' does not exist!"
        return 1
    end

    # gather model names
    for model_name in (ls "$models_path" 2>/dev/null)
        if string match -q "*.gguf" $model_name
            set -a models_list $model_name
        end
    end

    if not count $models_list >/dev/null
        echo -s "No models found in '$models_path'."
        return
    end

    ## commands
    # list
    # run <llm>

    function _print_usage
        echo -e "Usage: "
        echo -e "\tlmgo list            -- List available LLM's"
        echo -e "\tlmgo run <llm>       -- Run an LLM"
    end

    function _run_server
        # set log path
        set -l default_log_path "$XDG_DATA_HOME/llama.cpp"

        # use env variables if set
        if set -q LLAMA_CPP_LOG_PATH
            set -f log_path $LLAMA_CPP_LOG_PATH
        else
            set -f log_path $default_log_path
        end

        echo -s "Starting llama.cpp server with model '$argv[2]'"
        echo -s "Logging to '$log_path/server.log'."

        set -l llamacpp_bin "$HOME"/packages/llama.cpp/build/bin/llama-server

        if not test -x $llamacpp_bin
            echo -es "Error: llama.cpp server binary not found or not executable."
            echo -es "\tWas looking for $llamacpp_bin."
            return 1
        end

        "$HOME"/packages/llama.cpp/build/bin/llama-server \
            --model "$argv[1]/$argv[2]" \
            --alias $argv[2] \
            --ctx-size 8192 \
            --gpu-layers 1000 \
            --no-webui \
            --port 11435 \
            --log-prefix \
            --log-timestamps \
            --threads 4 \
            --threads-batch 4 \
            --threads-http 4 \
        &>> "$log_path/server.log"

        if not test $status -eq 0
            echo -s "Error: Failed to start the server. See '$log_path/server.log'."
            return 1
        end
    end

    set -l command_name $argv[1]

    if not string length -q $command_name
        _print_usage
        return
    end

    # handle 'list'
    if string match -q "list" $command_name
        echo -s "Listing available models:"
        for model_name in $models_list
            echo -s "- "(string replace ".gguf" "" $model_name)
        end
        return

    # handle 'run'
    else if string match -q "run" $command_name

        # if no model provided, default to first model in the list
        if not string length -q $argv[2]
            echo -s "No model provided. Defaulting to '$models_list[1]'."
            _run_server $models_path $models_list[1]
            return
        end

        # iterate the list
        for model_name in $models_list
            if string match -q "$argv[2].gguf" $model_name
                _run_server $models_path $model_name
                return
            end
        end

        echo -s "Could not find model $argv[2]."
        return 1

    # handle unknown command
    else
        _print_usage
        return
    end
end
