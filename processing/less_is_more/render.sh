#!/bin/bash
# Something less is something more
#
# By Alexandre 'kidev' Poumaroux
#
# Thanks a lot to the whole PROCESSING.ORG team for their amazing work !
# Visit www.processing.org to learn how to run this software.
#
# Joined pictures are licensed under CC BY-SA 4.0, see "data/LICENSE".
#
# Copyright (C) 2022 Alexandre 'kidev' Poumaroux
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#/

# Configuration Constants
SOURCE_DIR="./record"
TEMP_DIR="./temp_frames"
OUTPUT_DIR="./output"
OUTPUT_VIDEO="render.mp4"
FPS=30
SOURCE_WIDTH=1000
SOURCE_HEIGHT=1079
CROP_START_Y=$(($SOURCE_HEIGHT-$SOURCE_WIDTH))  # Set to -1 for auto-center

# Video encoding parameters optimized for Instagram + B&W animations
CRF_VALUE=18  # Lower = better quality. 18-23 recommended for Instagram
PRESET="slow"  # slow/medium/fast - slower = better compression
BITRATE="5M"  # Target bitrate
PIXEL_FORMAT="yuv420p"  # Required for maximum compatibility

# Error handling
set -e
trap 'echo "Error on line $LINENO"' ERR

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print status messages
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Validate dependencies
check_dependencies() {
    local deps=("ffmpeg" "convert" "identify")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            print_error "Required dependency '$dep' not found. Please install it."
            exit 1
        fi
    done
}

# Create necessary directories
setup_directories() {
    mkdir -p "$TEMP_DIR" "$OUTPUT_DIR"
    print_status "Created working directories"
}

# Clean temporary files
cleanup() {
    if [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
        print_status "Cleaned up temporary files"
    fi
}

# Calculate crop parameters
calculate_crop() {
    local width=$SOURCE_WIDTH
    local height=$SOURCE_HEIGHT
    local target_size=$width  # Square output

    if [ "$CROP_START_Y" -eq -1 ]; then
        # Auto-center crop
        CROP_START_Y=$(( (height - target_size) / 2 ))
        print_status "Auto-centering crop at Y=$CROP_START_Y"
    else
        # Manual crop position
        if [ "$CROP_START_Y" -lt 0 ] || [ "$CROP_START_Y" -gt $((height - target_size)) ]; then
            print_error "Invalid CROP_START_Y value: $CROP_START_Y"
            print_error "Must be between 0 and $((height - target_size))"
            exit 1
        fi
    fi

    CROP_GEOMETRY="${target_size}x${target_size}+0+${CROP_START_Y}"
    print_status "Crop geometry: $CROP_GEOMETRY"
}

# Process frames with ImageMagick
process_frames() {
    local frame_count=0
    local total_frames=$(ls -1 "$SOURCE_DIR"/frame_*.png 2>/dev/null | wc -l)

    if [ "$total_frames" -eq 0 ]; then
        print_error "No frames found in $SOURCE_DIR"
        exit 1
    fi

    print_status "Processing $total_frames frames..."

    for frame in "$SOURCE_DIR"/frame_*.png; do
        if [ -f "$frame" ]; then
            local basename=$(basename "$frame")
            local output_frame="$TEMP_DIR/$basename"

            # Crop using ImageMagick with optimized settings for quality
            convert "$frame" \
                -crop "$CROP_GEOMETRY" \
                -define png:compression-level=9 \
                -define png:compression-strategy=1 \
                "$output_frame"

            frame_count=$((frame_count + 1))

            # Progress indicator
            if [ $((frame_count % 10)) -eq 0 ]; then
                printf "\rProcessed: %d/%d frames (%.1f%%)" \
                    "$frame_count" "$total_frames" \
                    "$(echo "scale=1; $frame_count * 100 / $total_frames" | bc)"
            fi
        fi
    done

    echo "" # New line after progress
    print_status "Frame processing complete: $frame_count frames"
}

# Create video with FFmpeg
create_video() {
    local input_pattern="$TEMP_DIR/frame_%03d.png"
    local output_path="$OUTPUT_DIR/$OUTPUT_VIDEO"

    print_status "Creating video with FFmpeg..."

    # FFmpeg command optimized for Instagram + B&W animations
    ffmpeg -y \
        -framerate "$FPS" \
        -pattern_type glob \
        -i "$TEMP_DIR/frame_*.png" \
        -c:v libx264 \
        -preset "$PRESET" \
        -crf "$CRF_VALUE" \
        -b:v "$BITRATE" \
        -pix_fmt "$PIXEL_FORMAT" \
        -vf "format=yuv420p" \
        -movflags +faststart \
        -profile:v high \
        -level:v 4.0 \
        -bf 2 \
        -g $((FPS * 2)) \
        -refs 3 \
        -tune animation \
        "$output_path"

    # Verify output
    if [ -f "$output_path" ]; then
        local filesize=$(du -h "$output_path" | cut -f1)
        local duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$output_path")

        print_status "Video created successfully:"
        echo "  File: $output_path"
        echo "  Size: $filesize"
        echo "  Duration: ${duration}s"
        echo "  Resolution: ${SOURCE_WIDTH}x${SOURCE_WIDTH}"
        echo "  FPS: $FPS"
    else
        print_error "Failed to create video"
        exit 1
    fi
}

# Main execution
main() {
    print_status "Starting Instagram animation pipeline..."

    check_dependencies
    setup_directories

    # Set up error handling and cleanup
    trap cleanup EXIT
    trap 'print_error "Script interrupted"; exit 1' INT TERM

    calculate_crop
    process_frames
    create_video

    print_status "Pipeline completed successfully!"
}

# Execute main function
main "$@"
