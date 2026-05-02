#!/usr/bin/env bash

# Generate transcripts/subtitles from audio files via OpenAI Whisper.
# Companion to genVidSubtitlesWithWhisper — no ffmpeg, no codec, no NVENC.

# Portable single-line prompt (bash + zsh). Defined here so this script is
# usable on its own, but harmless to redefine if the video script is also loaded.
_prompt() {
	printf '%s' "$1" >&2
	IFS= read -r "${2:-REPLY}"
}

_require_option_value() {
	local option_name="$1"
	local option_value="${2-}"

	if [[ -z "$option_value" || "$option_value" == -* ]]; then
		echo "Error: Option $option_name requires a value"
		return 1
	fi
}

function genAudioSubtitlesWithWhisper() {
	local input_file=""
	local model="medium.en"
	local language="English"
	local subtitle_format="all"
	local gpu_device="cuda"
	local organize_files=true
	local help_text="Usage: genAudioSubtitlesWithWhisper -i input.mp3 [-m model] [-l language] [-f format] [-d device] [-n] [-h]

Options:
    -i, --input     Input audio file (required)
    -m, --model     Whisper model (default: medium.en)
                    Options: tiny, base, small, medium, large, large-v2, large-v3, turbo, large-v3-turbo, tiny.en, base.en, small.en, medium.en
    -l, --language  Language (default: English)
    -f, --format    Subtitle format (default: all)
                    Options: srt, vtt, txt, tsv, json, ass, lrc, all
    -d, --device    Compute device (default: cuda)
                    Options: cuda, cuda:0, cuda:1, cpu
    -n, --no-organize  Don't organize files into a directory (default: organize)
    -h, --help      Show this help

File Organization:
    By default, creates a directory next to the input audio containing the
    transcript outputs. The original audio is not moved or copied.
    - audio_basename/
      ├── audio_basename.srt
      ├── audio_basename.vtt
      └── audio_basename.txt

Examples:
    genAudioSubtitlesWithWhisper -i interview.mp3
    genAudioSubtitlesWithWhisper -i lecture.m4a -f srt -m medium.en
    genAudioSubtitlesWithWhisper -i podcast.opus -n   # dump next to source"

	while [[ $# -gt 0 ]]; do
		case $1 in
		-i | --input)
			_require_option_value "$1" "${2-}" || {
				echo "$help_text"
				return 1
			}
			input_file="$2"
			shift 2
			;;
		-m | --model)
			_require_option_value "$1" "${2-}" || {
				echo "$help_text"
				return 1
			}
			model="$2"
			shift 2
			;;
		-l | --language)
			_require_option_value "$1" "${2-}" || {
				echo "$help_text"
				return 1
			}
			language="$2"
			shift 2
			;;
		-f | --format)
			_require_option_value "$1" "${2-}" || {
				echo "$help_text"
				return 1
			}
			subtitle_format="$2"
			shift 2
			;;
		-d | --device)
			_require_option_value "$1" "${2-}" || {
				echo "$help_text"
				return 1
			}
			gpu_device="$2"
			shift 2
			;;
		-n | --no-organize)
			organize_files=false
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

	if [[ -z "$input_file" ]]; then
		echo "Error: Input file is required"
		echo "$help_text"
		return 1
	fi

	if [[ ! -f "$input_file" ]]; then
		echo "Error: Input file '$input_file' does not exist"
		return 1
	fi

	# Validate subtitle format
	local valid_formats=("srt" "vtt" "txt" "tsv" "json" "ass" "lrc" "all")
	local format_valid=false
	local f
	for f in "${valid_formats[@]}"; do
		if [[ "$subtitle_format" == "$f" ]]; then
			format_valid=true
			break
		fi
	done
	if [[ "$format_valid" == false ]]; then
		echo "❌ Error: Invalid subtitle format '$subtitle_format'"
		echo "Valid formats: ${valid_formats[*]}"
		return 1
	fi

	# Validate model (warning only — whisper itself is the source of truth)
	local valid_models=("tiny" "base" "small" "medium" "large" "large-v2" "large-v3" "turbo" "large-v3-turbo" "tiny.en" "base.en" "small.en" "medium.en")
	local model_valid=false
	local m
	for m in "${valid_models[@]}"; do
		if [[ "$model" == "$m" ]]; then
			model_valid=true
			break
		fi
	done
	if [[ "$model_valid" == false ]]; then
		echo "⚠️  Warning: '$model' may not be a valid Whisper model"
		echo "Valid models: ${valid_models[*]}"
	fi

	# Validate device shape
	if [[ ! "$gpu_device" =~ ^(cuda(:[0-9]+)?|cpu)$ ]]; then
		echo "⚠️  Invalid device '$gpu_device', falling back to 'cuda'"
		gpu_device="cuda"
	fi

	# Resolve paths
	input_file="$(realpath "$input_file")"
	local input_dir input_basename input_name
	input_dir="$(dirname "$input_file")"
	input_basename="$(basename "$input_file")"
	input_name="${input_basename%.*}"

	# Decide output dir
	local work_dir="$input_dir"
	local project_dir=""
	if [[ "$organize_files" == true ]]; then
		project_dir="$input_dir/$input_name"
		work_dir="$project_dir"

		echo "📁 Setting up project directory: $project_dir"

		if [[ -d "$project_dir" ]]; then
			echo "⚠️  Directory already exists: $project_dir"
			local reply=""
			_prompt "Continue and potentially overwrite files? [y/N]: " reply
			if [[ ! $reply =~ ^[Yy] ]]; then
				echo "❌ Operation cancelled"
				return 1
			fi
		fi

		if ! mkdir -p "$project_dir"; then
			echo "❌ Error: Could not create directory: $project_dir"
			return 1
		fi
	fi

	# Dependency check
	local missing_deps=()

	if ! command -v whisper &>/dev/null; then
		missing_deps+=("whisper (openai-whisper)")
	fi

	if ! command -v ffmpeg &>/dev/null; then
		missing_deps+=("ffmpeg")
	fi

	if [[ ${#missing_deps[@]} -gt 0 ]]; then
		echo "❌ Error: Missing required dependencies:"
		local dep
		for dep in "${missing_deps[@]}"; do
			echo "  - $dep"
		done
		echo ""
		echo "Install: pip install openai-whisper"
		echo "Install ffmpeg with your system package manager"
		return 1
	fi

	echo "📋 Configuration:"
	echo "  📁 Input: $input_file"
	echo "  🗂️  Output dir: $work_dir"
	echo "  🤖 Whisper model: $model"
	echo "  🗣️  Language: $language"
	echo "  📝 Format: $subtitle_format"
	echo "  🎮 Device: $gpu_device"
	echo ""

	local whisper_cmd=(
		whisper "$input_file"
		--model "$model"
		--language "$language"
		-f "$subtitle_format"
		--device "$gpu_device"
		--output_dir "$work_dir"
	)

	echo "🔧 Running: ${whisper_cmd[*]}"
	echo ""

	if ! "${whisper_cmd[@]}"; then
		echo "❌ Error: Whisper failed"
		return 1
	fi

	echo ""
	echo "✅ Transcription complete"
	echo "📊 Outputs in: $work_dir"
	if command -v du &>/dev/null; then
		local outfile
		for outfile in "$work_dir/$input_name".*; do
			[[ -f "$outfile" && "$outfile" != "$input_file" ]] || continue
			echo "  📝 $(basename "$outfile") ($(du -h "$outfile" | cut -f1))"
		done
	fi
}
