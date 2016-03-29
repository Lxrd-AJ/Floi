swift --version
if swift build -Xcc -fblocks; then 
	echo "🎉 🎉 🎉 Compiled Successfully"
else
	echo "Failed to Build 😭 😭"
fi
