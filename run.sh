#!/bin/bash
escape_for_markdown() {
  local input=$1
    # Escape double quotes
    printf "%s" "$input" | sed 's/"/\\"/g'
}

# Get the directory of the script
script_dir="$(dirname "$0")"

# Check if run.sh exists in the current directory
if [ ! -e "$script_dir/run.sh" ]> dev/null;then
    echo "Switching to the root directory of the project."
    cd "$script_dir" || exit
fi

dir=$(date +%Y)
languages=("go" "javascript" "rust")

# Check if question day is provided
if [ -z "$1" ]; then
    echo "Question day is required."
    exit 1
fi

# Check if question already exists
if [ -d "./$year/$1" ]; then
    echo "Question already exists."
    exit 1
fi

# Check if question name is provided
if [ -z "$2" ]; then
    echo "Question name is required."
    exit 1
fi

# Process and export the sub_dir variable
export sub_dir=$(echo "$1" | iconv -t ascii//TRANSLIT | sed -E 's/[~\^]+//g' | sed -E 's/[^a-zA-Z0-9]+/-/g' | sed -E 's/^-+\|-+$//g' | sed -E 's/^-+//g' | sed -E 's/-+$//g' | tr A-Z a-z)
description=$(escape_for_markdown "$2")
export description

# Create directories and initialize files
mkdir -p "./$dir/$sub_dir"
echo "## $1" > "./$dir/$sub_dir/index.md"
if [ "$2" ]; then
    echo -e "\n$description" >> "./$dir/$sub_dir/index.md"
fi

# Copy language templates
for i in "${languages[@]}"; do
    mkdir -p "./$dir/$sub_dir/$i"
    if [ -d "./templates/$i" ]; then
        cp -n -R "./templates/$i/" "./$dir/$sub_dir/$i"
    fi
done

# Change directory to the first language and initialize Go module
cd "./$dir/$sub_dir/${languages[0]}" || exit
go mod init "github.com/africhild/advent-of-code/$dir/$sub_dir/${languages[0]}"