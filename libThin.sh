#!/bin/bash

# 提示用户输入库文件的路径
read -p "Enter the path to the library file: " LIB_PATH

# 获取文件的扩展名
EXTENSION="${LIB_PATH##*.}"

# 检查文件是否是 .framework 或 .a
if [ "$EXTENSION" = "framework" ] || [ "$EXTENSION" = "a" ]; then
# 获取不包含扩展名的文件名
BASENAME=$(basename "$LIB_PATH" ".$EXTENSION")

echo "The base name of the file is: $BASENAME\n"
# 此处可以将文件名存储到变量或写入文件等操作
else
echo "The file is not a .framework or .a file."
exit 1
fi

# 提示用户输入特定的架构
#read -p "Enter the target architecture (e.g., x86_64, arm64): " TARGET_ARCH
TARGET_ARCH="arm64"

# 使用 lipo -info 检查库文件包含的架构
ARCHS=$(lipo -info "$LIB_PATH/$BASENAME")

# 输出库文件包含的架构信息
echo "Architectures in $LIB_PATH:"
echo "$ARCHS"

# 检查是否包含特定的架构
if echo "$ARCHS" | grep -q "$TARGET_ARCH"; then
    echo "$LIB_PATH contains architecture: $TARGET_ARCH\n"
else
    echo "$LIB_PATH does not contain architecture: $TARGET_ARCH"
    exit 1
fi

# 使用 lipo -thin 命令剥离指定架构
# 并输出到与原文件同级目录下的同名文件，不添加后缀
lipo "$LIB_PATH/$BASENAME" -thin "$TARGET_ARCH" -output "${LIB_PATH%.*}"

# 检查上一条命令是否成功执行
if [ $? -eq 0 ]; then
    echo "🍻 Stripping successful. The thinned library is located at: ${LIB_PATH%.*}\n"
else
    echo "🙅 Stripping failed."
    exit 1
fi
