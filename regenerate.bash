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

# 检查 protoc 命令是否存在
if ! command -v protoc &> /dev/null; then
    echo "错误: protoc 未安装，请先安装 protoc 工具。"
    exit 1
fi

echo "==> 开始生成代码..."

# 遍历所有 .proto 文件，排除指定文件
for proto_file in $(find . -name "*.proto" | sed "s|^\./||"); do
    # 排除不需要处理的文件
    if [[ "$proto_file" != "github.com/cargod-bj/b2c-proto-common/common/common.proto" ]] && \
       [[ "$proto_file" != "google/protobuf/any.proto" ]] && \
       [[ "$proto_file" != "hello/hello.proto" ]]; then

        echo "处理文件: $proto_file"

        # 检查 .proto 文件是否有读权限
        if [[ ! -r "$proto_file" ]]; then
            echo "错误: 无法读取文件 $proto_file，请检查权限。"
            continue
        fi

        # 执行 protoc 命令，生成代码
        protoc \
            --proto_path=. \
            --go_out=paths=source_relative:. \
            --go-grpc_out=paths=source_relative:. \
            --go-http_out=paths=source_relative:. \
            --validate_out=paths=source_relative,lang=go:. \
            "$proto_file"

        if [[ $? -ne 0 ]]; then
            echo "错误: 处理文件 $proto_file 失败。"
            exit 1
        fi
    fi
done

echo "==> 代码生成完成！"

# 遍历所有生成的 .pb.go 文件，去除 ,omitempty 标志
echo "==> 开始清理 ,omitempty 标记..."

for pb_go_file in $(find . -name "*.pb.go" | sed "s|^\./||"); do
    echo "清理文件: $pb_go_file"
    sed 's/,omitempty//g' "$pb_go_file" > "$pb_go_file.tmp" && mv "$pb_go_file.tmp" "$pb_go_file"
done

echo "==> 清理完成！"
echo "🎉 所有任务已完成！"