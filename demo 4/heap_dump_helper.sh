#!/bin/bash

# Heap Dump Helper Script for Spring Boot Applications
# Usage: ./heap_dump_helper.sh <command> [options]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
APP_NAME="DemooApplication"
DUMP_DIR="."
COMPRESSION=false

# Function to print colored output
print_info() {
    echo -e "${BLUE}ℹ ${1}${NC}"
}

print_success() {
    echo -e "${GREEN}✓ ${1}${NC}"
}

print_error() {
    echo -e "${RED}✗ ${1}${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ ${1}${NC}"
}

# Function to display usage
usage() {
    cat << EOF
${BLUE}Heap Dump Helper Script${NC}

Usage: $0 <command> [options]

Commands:
    list                List all running Java processes
    dump <PID>          Create heap dump for process ID
    dump-jcmd <PID>     Create heap dump using jcmd (Java 9+)
    analyze <FILE>      Analyze heap dump with jhat
    compress <FILE>     Compress heap dump file
    copy-remote         Copy heap dump to remote machine
    help                Show this help message

Options:
    -d, --dir DIR       Output directory (default: current directory)
    -z, --compress      Compress the heap dump after creation

Examples:
    # List Java processes
    $0 list

    # Create heap dump for process 12345
    $0 dump 12345

    # Create and compress heap dump
    $0 dump 12345 -z

    # Save to specific directory
    $0 dump 12345 -d /tmp

EOF
}

# Check if Java is available
check_java() {
    if ! command -v java &> /dev/null; then
        print_error "Java is not installed or not in PATH"
        exit 1
    fi

    if ! command -v jps &> /dev/null; then
        print_warning "jps command not found. Setting JAVA_HOME..."
        export JAVA_HOME=$(/usr/libexec/java_home)
    fi
}

# List all Java processes
list_processes() {
    print_info "Java processes running:"
    echo ""
    jps -l
    echo ""
}

# Create heap dump using jmap
create_dump_jmap() {
    local pid=$1
    local output_file="${DUMP_DIR}/heap_dump_${pid}_$(date +%s).hprof"

    print_info "Creating heap dump for PID: $pid"
    print_info "Output file: $output_file"

    if jmap -dump:live,format=b,file="$output_file" "$pid"; then
        print_success "Heap dump created successfully"
        echo "File: $output_file"
        echo "Size: $(ls -lh "$output_file" | awk '{print $5}')"

        if [ "$COMPRESSION" = true ]; then
            compress_file "$output_file"
        fi
    else
        print_error "Failed to create heap dump"
        exit 1
    fi
}

# Create heap dump using jcmd (Java 9+)
create_dump_jcmd() {
    local pid=$1
    local output_file="${DUMP_DIR}/heap_dump_${pid}_$(date +%s).hprof"

    print_info "Creating heap dump for PID: $pid (using jcmd)"
    print_info "Output file: $output_file"

    if jcmd "$pid" GC.heap_dump "$output_file"; then
        print_success "Heap dump created successfully"
        echo "File: $output_file"
        echo "Size: $(ls -lh "$output_file" | awk '{print $5}')"

        if [ "$COMPRESSION" = true ]; then
            compress_file "$output_file"
        fi
    else
        print_error "Failed to create heap dump"
        exit 1
    fi
}

# Compress heap dump file
compress_file() {
    local file=$1

    if [ ! -f "$file" ]; then
        print_error "File not found: $file"
        return 1
    fi

    print_info "Compressing $file..."

    if gzip -v "$file"; then
        print_success "File compressed successfully"
        echo "Original size: $(ls -lh "${file}.gz" | awk '{print $5}')"
    else
        print_error "Failed to compress file"
        return 1
    fi
}

# Analyze heap dump with jhat
analyze_dump() {
    local file=$1

    if [ ! -f "$file" ]; then
        print_error "File not found: $file"
        exit 1
    fi

    print_info "Analyzing heap dump: $file"
    print_info "This may take a while depending on file size..."

    jhat -J-Xmx2g "$file" &

    sleep 2
    print_success "Analysis started. Opening http://localhost:7000 in your browser..."

    # Try to open in browser if available
    if command -v open &> /dev/null; then
        open http://localhost:7000
    elif command -v xdg-open &> /dev/null; then
        xdg-open http://localhost:7000
    else
        print_info "Open http://localhost:7000 in your browser manually"
    fi
}

# Main script logic
main() {
    check_java

    if [ $# -eq 0 ]; then
        usage
        exit 0
    fi

    command=$1
    shift

    case "$command" in
        list)
            list_processes
            ;;
        dump)
            if [ $# -lt 1 ]; then
                print_error "PID required"
                exit 1
            fi
            pid=$1
            shift

            # Parse options
            while [[ $# -gt 0 ]]; do
                case $1 in
                    -d|--dir)
                        DUMP_DIR="$2"
                        shift 2
                        ;;
                    -z|--compress)
                        COMPRESSION=true
                        shift
                        ;;
                    *)
                        shift
                        ;;
                esac
            done

            create_dump_jmap "$pid"
            ;;
        dump-jcmd)
            if [ $# -lt 1 ]; then
                print_error "PID required"
                exit 1
            fi
            pid=$1
            shift

            # Parse options
            while [[ $# -gt 0 ]]; do
                case $1 in
                    -d|--dir)
                        DUMP_DIR="$2"
                        shift 2
                        ;;
                    -z|--compress)
                        COMPRESSION=true
                        shift
                        ;;
                    *)
                        shift
                        ;;
                esac
            done

            create_dump_jcmd "$pid"
            ;;
        analyze)
            if [ $# -lt 1 ]; then
                print_error "File path required"
                exit 1
            fi
            analyze_dump "$1"
            ;;
        compress)
            if [ $# -lt 1 ]; then
                print_error "File path required"
                exit 1
            fi
            compress_file "$1"
            ;;
        help|--help|-h)
            usage
            ;;
        *)
            print_error "Unknown command: $command"
            usage
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
