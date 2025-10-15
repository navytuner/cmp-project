run_container (){
    echo "Starting CMP environment..."
    docker run -itd \
        --platform linux/amd64 \
        -v ${PWD}:/root \
        -w /root \
        --name intcmp_2025 \
        dongukred/intcmp-2025
}

run_container

