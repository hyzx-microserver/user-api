#!/bin/bash
# Copyright 2020 The Go Authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# NOTE: The integration scripts deliberately do not check to
# make sure that the test protos have been regenerated.
# It is intentional that older versions of the .pb.go files
# are checked in to ensure that they continue to function.
#
# Versions used:
#	protoc:        3.14.0
#	protoc-gen-go: v1.30.0
#protoc-gen-go-http 0.0.1

echo "==> 开始生成代码..."
echo "当前工作目录: $(pwd)"

# 检查 protoc 命令是否存在
if ! command -v protoc &> /dev/null; then
    echo "错误: protoc 未安装，请先安装 protoc 工具。"
    exit 1
fi

# 设置环境变量，确保插件路径正确
export PATH=$PATH:$(go env GOPATH)/bin:/usr/local/bin

# 遍历所有 .proto 文件
for proto_file in $(find . -name "*.proto" | sed "s|^\./||"); do
    # 排除指定文件
    if [[ "$proto_file" != "github.com/cargod-bj/b2c-proto-common/common/common.proto" ]] && \
       [[ "$proto_file" != "google/protobuf/any.proto" ]] && \
       [[ "$proto_file" != "hello/hello.proto" ]]; then

        echo "处理文件: $proto_file"

        # 检查文件是否存在且可读
        if [[ ! -r "$proto_file" ]]; then
            echo "错误: 无法读取文件 $proto_file，请检查权限。"
            continue
        fi

        # 执行 protoc 命令
        echo "执行命令: protoc --proto_path=. --go_out=paths=source_relative:. --go-grpc_out=paths=source_relative:. $proto_file"
        protoc \
            --proto_path=. \
            --go_out=paths=source_relative:. \
            --go-grpc_out=paths=source_relative:. \
            "$proto_file"

        # 检查 protoc 命令是否成功
        if [[ $? -ne 0 ]]; then
            echo "错误: 处理文件 $proto_file 失败。"
            exit 1
        fi
    fi
done

echo "==> 代码生成完成！"