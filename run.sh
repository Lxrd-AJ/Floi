swift --version
if swift build; then 
	.build/debug/Main
else
	echo "Failed to Build"
fi
