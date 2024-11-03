#!/usr/bin/env bash
# Zip subdirectories into cbz files

set +o nounset

while [ $# -gt 0 ]; do
    case "$1" in
        -n)
            dryrun=true
            shift
            ;;
        -d)
            dryrun=true
            shift
            ;;
        -v)
            verbose=true
            shift
            ;;
        *)
            shift
            ;;
    esac
done

zipcbz ()
{
    ECHO=""
    if [ -n "$dryrun" ] || [ -n "$verbose" ]; then
       ECHO="echo"
    fi

    output_dir=$(pwd)

    for dir in */;
    do
        echo "Zipping \"$dir\""
        readarray -t files < <(find "$dir" -type f)
        # -m to delete src files, -j to junk the parent directory (not include it)
        # shellcheck disable=SC2086
        $ECHO zip -0 -r -m -j "${output_dir}/${dir%/}.cbz" ${dryrun:-"${files[@]}"}
        $ECHO rmdir -v "$dir"
    done
}

zipcbz
