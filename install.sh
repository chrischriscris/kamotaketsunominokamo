#!/usr/bin/env bash

echo "Installing kamotake"

echo "  Installing dependencies"
make >> /dev/null

# Verifies if the make command was successful
if [ $? -eq 0 ]; then
    cd kamotake && bundle install >> /dev/null

    # Verifies if the bundle install command wasn't successful
    if [ $? -ne 0 ]; then
        echo "  Error installing dependencies"
        cd ..
        return 1
    fi

    cd ..
    cd kamotake-web && bundle install >> /dev/null

    # Verifies if the bundle install command wasn't successful
    if [ $? -ne 0 ]; then
        echo "  Error installing dependencies"
        cd ..
        return 1
    fi

    cd ..
    echo "  Dependencies installed"
else
    echo "  Error installing dependencies"
    return 1
fi

echo "  Adding kamotake executables to PATH in this session"

# Verifies if the directory is already in the PATH
if [[ ":$PATH:" == *":$PWD/kamotake/bin:"* ]]; then
    echo "    They're already there"
else
    export PATH=$PWD/kamotake/bin:$PATH
fi

echo "  Adding kamotake-web executables to PATH in this session"
if [[ ":$PATH:" == *":$PWD/kamotake-web/bin:"* ]]; then
    echo "    They're already there"
else
    export PATH=$PWD/kamotake-web/bin:$PATH
fi

echo "Done, you're good to go!"
