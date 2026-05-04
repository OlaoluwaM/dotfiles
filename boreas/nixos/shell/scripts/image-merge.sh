#!/usr/bin/env bash

function mergeImages() {
	local dir="."
	local output=""
	local append_flag="-append"
	local help_text="Usage: mergeImages [-d directory] [-o output] [-H] [-h]

Options:
    -d, --dir        Directory containing images (default: current directory)
    -o, --output     Output file path (default: merged.png in the target directory)
    -H, --horizontal Merge horizontally instead of vertically
    -h, --help       Show this help message

Supported formats: png, jpg, jpeg, webp, gif, bmp, tiff, tif
Images are merged in natural sort order."

	while [[ $# -gt 0 ]]; do
		case $1 in
		-d | --dir)
			dir="$2"
			shift 2
			;;
		-o | --output)
			output="$2"
			shift 2
			;;
		-H | --horizontal)
			append_flag="+append"
			shift
			;;
		-h | --help)
			echo "$help_text"
			return 0
			;;
		*)
			echo "Error: Unknown option $1"
			echo "$help_text"
			return 1
			;;
		esac
	done

	if [[ ! -d "$dir" ]]; then
		echo "Error: '$dir' is not a directory"
		return 1
	fi

	if ! command -v magick &>/dev/null; then
		echo "Error: ImageMagick (magick) is required but not installed"
		return 1
	fi

	local images=()
	while IFS= read -r -d '' file; do
		images+=("$file")
	done < <(find "$dir" -maxdepth 1 -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' -o -iname '*.gif' -o -iname '*.bmp' -o -iname '*.tiff' -o -iname '*.tif' \) -print0 | sort -zV)

	if [[ ${#images[@]} -eq 0 ]]; then
		echo "Error: No images found in '$dir'"
		return 1
	fi

	if [[ ${#images[@]} -lt 2 ]]; then
		echo "Error: Need at least 2 images to merge, found ${#images[@]}"
		return 1
	fi

	# Verify filenames have a numeric component that implies ordering.
	# Without numbers, there's no way to know the intended sequence.
	local has_order=true
	local offending=()
	for img in "${images[@]}"; do
		local base
		base="$(basename "$img")"
		local name="${base%.*}"
		if [[ ! "$name" =~ [0-9] ]]; then
			has_order=false
			offending+=("$base")
		fi
	done

	if [[ "$has_order" == false ]]; then
		echo "Error: No clear sort order — these filenames contain no numbers:"
		printf '  %s\n' "${offending[@]}"
		echo "Rename files with a numeric prefix/suffix to indicate merge order (e.g. 01-intro.png, 02-body.png)."
		return 1
	fi

	[[ -z "$output" ]] && output="$dir/merged.png"

	if magick "${images[@]}" "$append_flag" "$output"; then
		echo "Merged ${#images[@]} images into $output"
	else
		echo "Error: Failed to merge images"
		return 1
	fi
}
