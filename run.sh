swift --version
if swift build -Xcc -fblocks; then 
	.build/debug/Main
else
	echo "Failed to Build"
fi
