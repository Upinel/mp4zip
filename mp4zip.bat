@echo off
setlocal enabledelayedexpansion

for %%f in (%*) do (
    set "file=%%~f"
    set "directory=%%~dpf"
    set "filename=%%~nf"
    set "output=%%~dpnxf_converted.mp4"

    :: Echo statements for debugging
    echo Processing file: %%f
    echo Directory: !directory!
    echo Filename: !filename!
    echo Output file: !output!

    :: Convert the file
    ffmpeg -i "%%~f" -c:v libx264 -crf 30 -movflags faststart -preset superfast -c:a aac -b:a 128k -y "!output!"

    if errorlevel 0 (
        for %%O in ("%%~f") do set "original_size=%%~zO"
        for %%C in ("!output!") do set "converted_size=%%~zC"

        :: Ensure the sizes are retrieved correctly
        echo Original size: !original_size! bytes
        echo Converted size: !converted_size! bytes

        :: Skip arithmetic if sizes are invalid (0 or empty)
        if defined original_size if defined converted_size if !original_size! NEQ 0 (
            set /A size_difference=original_size-converted_size
            set /A reduction_percentage=size_difference*100/original_size

            if !reduction_percentage! LSS 0 (
                set "reduction_percentage=0"
            )

            echo Reduction: !reduction_percentage!%%
            
            :: Delete original file if converted file is smaller
            if !converted_size! LSS !original_size! (
                del "%%~f"
                echo Deleted original file: %%f
            ) else (
                echo Converted file is not smaller, original file not deleted: %%f
            )
        ) else (
            echo Skipping size comparison due to invalid sizes.
        )
    ) else (
        echo Error converting %%f -- deleting incomplete conversion: !output!
        del "!output!"
    )
)
endlocal
