#!/bin/sh

if [ -z "$(git status --porcelain)" ]; then
    echo "No git changes."
    return 0
else
    echo "Git changes detected. Please review log and commit changes."
    return 1
fi