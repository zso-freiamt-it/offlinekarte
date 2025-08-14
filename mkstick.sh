d="$1"
if [ -z "$1" ]; then
    echo "Provide stick folder"
    exit 1
fi
echo "Cleaning stick"
rm -rf "$d"/*
echo "Copying"
cp -R ./release "$d"/
cp -R ./install-scripts/* "$d"/
echo "Sync"
sync
