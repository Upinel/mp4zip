for f in "$@"
do
    if [[ "$f" == *_converted.mp4 ]]; then
        echo "Skipping already converted file: $f"
        continue
    fi

    directory=$(dirname "$f")
    filename=$(basename "$f")
    extension="${filename##*.}"
    filename="${filename%.*}"
    output="${directory}/${filename}_converted.mp4"

    ffmpeg -i "$f" -c:v libx264 -crf 30 -movflags faststart -preset superfast -c:a aac -b:a 128k -y "$output"

    if [[ $? -eq 0 ]]; then
        original_size=$(stat -c%s "$f")
        converted_size=$(stat -c%s "$output")
        reduction_percentage=$(( (original_size - converted_size) * 100 / original_size ))

        echo "Original size: $(( original_size / 1024 )) KB"
        echo "Converted size: $(( converted_size / 1024 )) KB"
        echo "Reduction: ${reduction_percentage}%"
        if [[ $converted_size -lt $original_size ]]; then
            rm "$f"
            echo "Deleted original file: $f"
        else
            echo "Converted file is not smaller, original file not deleted: $f"
        fi
    else
        echo "Error converting $f"
        rm "$output" # Remove the unsuccessful output file
    fi
done
