#!/usr/bin/env bash

function genVidSubtitlesWithWhisper() {
	local input_file=""
	local output_file=""
	local model="small.en"
	local language="English"
	local burn_in=false
	local subtitle_format="vtt"
	local gpu_device="cuda"
	local video_codec="copy"
	local organize_files=true
	local help_text="Usage: auto_subtitle -i input.mp4 [-o output.mp4] [-m model] [-l language] [-f format] [-d device] [-b] [-c codec] [-n] [-h]

Options:
    -i, --input     Input video file (required)
    -o, --output    Output video file (default: input_subtitled.ext)
    -m, --model     Whisper model (default: small.en)
                    Options: tiny, base, small, medium, large, tiny.en, base.en, small.en, medium.en, large-v2, large-v3
    -l, --language  Language (default: English)
    -f, --format    Subtitle format (default: srt)
                    Options: srt, vtt, txt, tsv, json, ass, lrc
    -d, --device    GPU device (default: cuda)
                    Options: cuda, cuda:0, cuda:1, etc.
    -b, --burn-in   Burn subtitles into video (default: false - adds as track)
    -c, --codec     Video codec for output (default: copy)
                    Options: copy, h264_nvenc, hevc_nvenc, libx264, libx265
    -n, --no-organize  Don't organize files into a directory (default: organize files)
    -h, --help      Show this help message

File Organization:
    By default, creates a directory named after the input video and organizes:
    - original_video/
      ├── original_video.ext (copy of original)
      ├── original_video_subtitled.ext (processed video)
      └── original_video.srt (subtitle file)

Note: GPU acceleration is always enabled. Optimized for NVIDIA GPUs.

Examples:
    auto_subtitle -i video.mp4
    auto_subtitle -i video.mp4 -o captioned.mp4 -m base.en -f vtt
    auto_subtitle -i video.mp4 -n  # Don't organize into directory
    auto_subtitle -i video.mov -b -c h264_nvenc  # Burn subs with NVENC encoding"

	# Parse command line arguments
	while [[ $# -gt 0 ]]; do
		case $1 in
		-i | --input)
			input_file="$2"
			shift 2
			;;
		-o | --output)
			output_file="$2"
			shift 2
			;;
		-m | --model)
			model="$2"
			shift 2
			;;
		-l | --language)
			language="$2"
			shift 2
			;;
		-f | --format)
			subtitle_format="$2"
			shift 2
			;;
		-d | --device)
			gpu_device="$2"
			shift 2
			;;
		-b | --burn-in)
			burn_in=true
			shift
			;;
		-c | --codec)
			video_codec="$2"
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

	# Check for required input file
	if [[ -z "$input_file" ]]; then
		echo "Error: Input file is required"
		echo "$help_text"
		return 1
	fi

	# Check if input file exists
	if [[ ! -f "$input_file" ]]; then
		echo "Error: Input file '$input_file' does not exist"
		return 1
	fi

	# Get absolute path for input file
	input_file="$(realpath "$input_file")"
	local input_dir
	input_dir="$(dirname "$input_file")"
	local input_basename
	input_basename="$(basename "$input_file")"
	local input_name="${input_basename%.*}"
	local input_ext="${input_basename##*.}"

	# Set up directory structure if organizing files
	local work_dir="$input_dir"
	local project_dir=""

	if [[ "$organize_files" == true ]]; then
		project_dir="$input_dir/$input_name"
		work_dir="$project_dir"

		echo "📁 Setting up project directory: $project_dir"

		if [[ -d "$project_dir" ]]; then
			echo "⚠️  Directory already exists: $project_dir"
			read -p "Continue and potentially overwrite files? [y/N]: " -n 1 -r
			echo
			if [[ ! $REPLY =~ ^[Yy]$ ]]; then
				echo "❌ Operation cancelled"
				return 1
			fi
		fi

		# Create project directory
		if ! mkdir -p "$project_dir"; then
			echo "❌ Error: Could not create directory: $project_dir"
			return 1
		fi

		echo "✅ Project directory created: $project_dir"
	fi

	# Set file paths based on organization preference
	local working_input_file=""
	local temp_subtitle=""
	local final_output_file=""

	if [[ "$organize_files" == true ]]; then
		# Copy original file to project directory
		working_input_file="$work_dir/$input_basename"
		temp_subtitle="$work_dir/${input_name}.${subtitle_format}"

		if [[ -z "$output_file" ]]; then
			if [[ "$burn_in" == true ]]; then
				final_output_file="$work_dir/${input_name}_subtitled.mp4"
			else
				final_output_file="$work_dir/${input_name}_subtitled.${input_ext}"
			fi
		else
			# If custom output specified, put it in project dir but keep the name
			local output_basename
			output_basename="$(basename "$output_file")"
			final_output_file="$work_dir/$output_basename"
		fi

		# Copy original file to project directory if it's not already there
		if [[ "$input_file" != "$working_input_file" ]]; then
			echo "📋 Copying original file to project directory..."
			if ! cp "$input_file" "$working_input_file"; then
				echo "❌ Error: Could not copy input file to project directory"
				return 1
			fi
			echo "✅ Original file copied to: $working_input_file"
		fi
	else
		# Use original locations
		working_input_file="$input_file"
		temp_subtitle="${input_file%.*}.${subtitle_format}"

		if [[ -z "$output_file" ]]; then
			if [[ "$burn_in" == true ]]; then
				final_output_file="${input_file%.*}_subtitled.mp4"
			else
				final_output_file="${input_file%.*}_subtitled.${input_ext}"
			fi
		else
			final_output_file="$output_file"
		fi
	fi

	# Check for required executables and GPU support
	echo "🚀 Checking dependencies and GPU setup..."

	local missing_deps=()

	if ! command -v whisper &>/dev/null; then
		missing_deps+=("whisper (openai-whisper)")
	fi

	if ! command -v ffmpeg &>/dev/null; then
		missing_deps+=("ffmpeg")
	fi

	if ! command -v nvidia-smi &>/dev/null; then
		missing_deps+=("nvidia-smi (NVIDIA drivers)")
	fi

	# Report missing dependencies
	if [[ ${#missing_deps[@]} -gt 0 ]]; then
		echo "❌ Error: Missing required dependencies:"
		for dep in "${missing_deps[@]}"; do
			echo "  - $dep"
		done
		echo ""
		echo "Installation instructions:"
		echo "1. Install NVIDIA drivers and CUDA toolkit"
		echo "2. Install ffmpeg with NVENC support:"
		echo "   Ubuntu/Debian: sudo apt update && sudo apt install ffmpeg"
		echo "   Or compile with: --enable-cuda-nvcc --enable-cuvid --enable-nvenc"
		echo "3. Install Whisper with CUDA support:"
		echo "   pip install openai-whisper"
		echo "   pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118"
		return 1
	fi

	echo "✅ All dependencies found"

	# Check NVIDIA GPU status
	echo "🔍 Checking NVIDIA GPU status..."
	if nvidia-smi &>/dev/null; then
		echo "✅ NVIDIA GPU detected:"
		nvidia-smi --query-gpu=name,memory.total,memory.free --format=csv,noheader,nounits | while IFS=, read -r name total free; do
			echo "  - $name (Memory: ${free}MB free / ${total}MB total)"
		done
	else
		echo "⚠️  Warning: nvidia-smi failed. GPU may not be available."
	fi

	# Validate CUDA device
	if [[ "$gpu_device" =~ ^cuda(:[0-9]+)?$ ]]; then
		echo "✅ Using GPU device: $gpu_device"
	else
		echo "⚠️  Warning: Invalid CUDA device '$gpu_device', using 'cuda' as fallback"
		gpu_device="cuda"
	fi

	# Check PyTorch CUDA support
	echo "🔍 Verifying PyTorch CUDA support..."
	if python3 -c "import torch; print('✅ CUDA available:', torch.cuda.is_available()); print('✅ CUDA devices:', torch.cuda.device_count())" 2>/dev/null; then
		echo "✅ PyTorch CUDA support confirmed"
	else
		echo "⚠️  Warning: PyTorch CUDA support not detected. Install with:"
		echo "   pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118"
	fi
	echo ""

	# Validate whisper model
	local valid_models=("tiny" "base" "small" "medium" "large" "large-v2" "large-v3" "tiny.en" "base.en" "small.en" "medium.en")
	local model_valid=false
	for valid_model in "${valid_models[@]}"; do
		if [[ "$model" == "$valid_model" ]]; then
			model_valid=true
			break
		fi
	done

	if [[ "$model_valid" == false ]]; then
		echo "⚠️  Warning: '$model' may not be a valid Whisper model"
		echo "Valid models: ${valid_models[*]}"
	fi

	# Validate subtitle format
	local valid_formats=("srt" "vtt" "txt" "tsv" "json" "ass" "lrc")
	local format_valid=false
	for valid_format in "${valid_formats[@]}"; do
		if [[ "$subtitle_format" == "$valid_format" ]]; then
			format_valid=true
			break
		fi
	done

	if [[ "$format_valid" == false ]]; then
		echo "❌ Error: Invalid subtitle format '$subtitle_format'"
		echo "Valid formats: ${valid_formats[*]}"
		return 1
	fi

	# Check NVENC support if using hardware encoding
	if [[ "$video_codec" =~ nvenc ]]; then
		echo "🔍 Checking NVENC support..."
		if ffmpeg -hide_banner -encoders 2>/dev/null | grep -q "$video_codec"; then
			echo "✅ Hardware encoder '$video_codec' available"
		else
			echo "⚠️  Warning: Hardware encoder '$video_codec' not available, falling back to libx264"
			video_codec="libx264"
		fi
	fi

	# Auto-select NVENC for burn-in operations if codec is 'copy'
	if [[ "$burn_in" == true && "$video_codec" == "copy" ]]; then
		if ffmpeg -hide_banner -encoders 2>/dev/null | grep -q "h264_nvenc"; then
			video_codec="h264_nvenc"
			echo "🚀 Auto-selected H.264 NVENC for burn-in operation"
		else
			video_codec="libx264"
			echo "🔄 Using CPU encoder libx264 for burn-in operation"
		fi
	fi

	echo "📋 Processing Configuration:"
	echo "  📁 Input: $working_input_file"
	echo "  📁 Output: $final_output_file"
	echo "  🗂️  Project directory: $([ "$organize_files" == true ] && echo "$project_dir" || echo "None (files in original location)")"
	echo "  🤖 Whisper model: $model"
	echo "  🗣️  Language: $language"
	echo "  📝 Subtitle format: $subtitle_format"
	echo "  🎮 GPU device: $gpu_device"
	echo "  🎬 Video codec: $video_codec"
	echo "  🔥 Burn-in subtitles: $burn_in"
	echo ""

	# Step 1: Generate subtitle transcription with GPU acceleration
	echo "⚡ Step 1: Generating subtitles with Whisper (GPU accelerated)..."

	local whisper_cmd="whisper \"$working_input_file\" --model \"$model\" --language \"$language\" -f \"$subtitle_format\" --device \"$gpu_device\" --output_dir \"$work_dir\""

	echo "🔧 Running: $whisper_cmd"

	if ! eval "$whisper_cmd"; then
		echo "❌ Error: Failed to generate subtitles"
		return 1
	fi

	# Check if subtitle file was created
	if [[ ! -f "$temp_subtitle" ]]; then
		echo "❌ Error: Subtitle file was not created at expected location: $temp_subtitle"
		return 1
	fi

	echo "✅ Subtitles generated: $temp_subtitle"
	echo ""

	# Step 2: Combine video and subtitles with GPU acceleration
	echo "⚡ Step 2: Processing video with ffmpeg (GPU accelerated)..."

	# Build base ffmpeg command with NVIDIA GPU acceleration
	local ffmpeg_cmd="ffmpeg -y -hwaccel cuda -hwaccel_output_format cuda"

	ffmpeg_cmd+=" -i \"$working_input_file\""

	if [[ "$burn_in" == true ]]; then
		# Burn subtitles into the video
		echo "🔥 Burning subtitles into video with GPU acceleration..."

		local subtitle_filter=""
		case "$subtitle_format" in
		srt | ass)
			subtitle_filter="subtitles=$temp_subtitle"
			;;
		vtt)
			subtitle_filter="subtitles=$temp_subtitle"
			;;
		*)
			echo "⚠️  Warning: Format '$subtitle_format' may not work well with burning. Consider using SRT or ASS."
			subtitle_filter="subtitles=$temp_subtitle"
			;;
		esac

		# For subtitle burning, we need to download from GPU to CPU for subtitle filter, then back to GPU
		ffmpeg_cmd+=" -vf \"hwdownload,format=nv12,$subtitle_filter,hwupload_cuda\""

		# Set video codec with optimal NVENC settings
		case "$video_codec" in
		h264_nvenc)
			ffmpeg_cmd+=" -c:v h264_nvenc -preset p4 -tune hq -rc vbr -cq 23 -b:v 0 -maxrate 10M -bufsize 20M"
			;;
		hevc_nvenc)
			ffmpeg_cmd+=" -c:v hevc_nvenc -preset p4 -tune hq -rc vbr -cq 28 -b:v 0 -maxrate 8M -bufsize 16M"
			;;
		libx264)
			# CPU fallback
			ffmpeg_cmd=" ffmpeg -y -i \"$working_input_file\" -vf \"$subtitle_filter\" -c:v libx264 -preset medium -crf 23"
			;;
		libx265)
			# CPU fallback
			ffmpeg_cmd=" ffmpeg -y -i \"$working_input_file\" -vf \"$subtitle_filter\" -c:v libx265 -preset medium -crf 28"
			;;
		esac

		ffmpeg_cmd+=" -c:a copy \"$final_output_file\""

	else
		# Add subtitles as a separate track
		echo "📎 Adding subtitles as a separate track..."

		ffmpeg_cmd+=" -i \"$temp_subtitle\" -c:v copy -c:a copy"

		# Set subtitle codec based on format and container
		local subtitle_codec="mov_text" # default for MP4
		local output_ext="${final_output_file##*.}"

		case "$output_ext" in
		mkv)
			case "$subtitle_format" in
			srt) subtitle_codec="subrip" ;;
			ass) subtitle_codec="ass" ;;
			vtt) subtitle_codec="webvtt" ;;
			*) subtitle_codec="subrip" ;;
			esac
			;;
		mp4)
			subtitle_codec="mov_text"
			;;
		*)
			case "$subtitle_format" in
			srt) subtitle_codec="subrip" ;;
			ass) subtitle_codec="ass" ;;
			vtt) subtitle_codec="webvtt" ;;
			*) subtitle_codec="subrip" ;;
			esac
			;;
		esac

		ffmpeg_cmd+=" -c:s $subtitle_codec \"$final_output_file\""
	fi

	echo "🔧 Running: $ffmpeg_cmd"

	if ! eval "$ffmpeg_cmd"; then
		echo "❌ Error: Failed to process video with ffmpeg"
		rm -f "$temp_subtitle"
		return 1
	fi

	echo "✅ Video processing complete"
	echo ""

	# Display project structure and file information
	if [[ "$organize_files" == true ]]; then
		echo "📊 Project Structure:"
		echo "📁 $project_dir/"
		echo "  ├── 📹 $(basename "$working_input_file") (original video)"
		echo "  ├── 🎬 $(basename "$final_output_file") (subtitled video)"
		echo "  └── 📝 $(basename "$temp_subtitle") (subtitle file)"
		echo ""

		# Show directory size
		if command -v du &>/dev/null; then
			echo "📏 Project directory size: $(du -sh "$project_dir" | cut -f1)"
		fi
	else
		echo "📊 Generated Files:"
		echo "  🎬 Subtitled video: $final_output_file"
		echo "  📝 Subtitle file ($subtitle_format): $temp_subtitle"
	fi

	# Show individual file sizes
	if command -v du &>/dev/null; then
		echo ""
		echo "📏 Individual File Sizes:"
		echo "  📁 Original video: $(du -h "$working_input_file" | cut -f1)"
		echo "  📁 Subtitled video: $(du -h "$final_output_file" | cut -f1)"
		echo "  📝 Subtitle file: $(du -h "$temp_subtitle" | cut -f1)"
	fi

	# Show current GPU memory usage
	echo ""
	echo "🎮 Current GPU Memory Usage:"
	nvidia-smi --query-gpu=memory.used,memory.total --format=csv,noheader,nounits | while IFS=, read -r used total; do
		local percent=$((used * 100 / total))
		echo "  💾 GPU Memory: ${used}MB / ${total}MB (${percent}%)"
	done
	echo ""

	# Clean up or organize final files
	if [[ "$organize_files" == true ]]; then
		echo "🗂️  All files organized in project directory: $project_dir"

		# Optionally create a README file
		local readme_file="$project_dir/README.md"
		cat >"$readme_file" <<EOF
# Subtitle Project: $input_name

## Files
- \`$(basename "$working_input_file")\` - Original video file
- \`$(basename "$final_output_file")\` - Video with subtitles $([ "$burn_in" == true ] && echo "(burned-in)" || echo "(embedded track)")
- \`$(basename "$temp_subtitle")\` - Subtitle file ($subtitle_format format)

## Processing Details
- **Whisper Model**: $model
- **Language**: $language
- **GPU Device**: $gpu_device
- **Video Codec**: $video_codec
- **Subtitle Format**: $subtitle_format
- **Processing Date**: $(date)

$([ "$burn_in" == false ] && echo "## Viewing Subtitles
To view embedded subtitles, use a compatible video player like VLC and enable subtitle tracks in the player settings.")
EOF
		echo "📄 Created README.md with project details"
	else
		read -p "Keep the $subtitle_format subtitle file? [Y/n]: " -n 1 -r
		echo
		if [[ $REPLY =~ ^[Nn]$ ]]; then
			rm -f "$temp_subtitle"
			echo "🗑️  Subtitle file removed"
		else
			echo "💾 Subtitle file kept for manual editing if needed"
		fi
	fi

	echo ""
	echo "🎉 Successfully created subtitled video!"
	echo "⚡ Processed with NVIDIA GPU acceleration ($gpu_device)"

	if [[ "$organize_files" == true ]]; then
		echo "📁 Project location: $project_dir"
		echo "🎬 Main output: $final_output_file"
	else
		echo "🎬 Output file: $final_output_file"
	fi

	if [[ "$burn_in" == false ]]; then
		echo ""
		echo "ℹ️  Note: Subtitles are embedded as a track. Use a player like VLC to view them."
		echo "You may need to enable subtitles in your video player's settings."
	fi

	if [[ "$video_codec" =~ nvenc ]]; then
		echo "🚀 Used NVIDIA NVENC hardware encoding for optimal performance"
	fi
}
