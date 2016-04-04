swift --version
rm -rf .build/debug
if swift build; then 
	echo "🎉 🎉 🎉 Compiled Successfully"
else
	echo "Failed to Build 😭 😭"
fi
