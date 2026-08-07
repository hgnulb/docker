# Ollama 本地使用

启动服务后还需要按需下载模型：

```bash
make up DIR=ollama
docker compose -f ollama/compose.yaml exec ollama ollama pull qwen3:8b
docker compose -f ollama/compose.yaml exec ollama ollama list
docker compose -f ollama/compose.yaml exec ollama ollama run qwen3:8b
```

API 地址为 `http://127.0.0.1:11434`。模型保存在 `ollama_data` volume 中，通常占用数 GB 到数十 GB；`make clean DIR=ollama CONFIRM=1` 会删除全部模型。

Docker Desktop for macOS 中的 Ollama 通常不能直接使用宿主机 Metal。需要更好的 Apple GPU 性能时，建议在 macOS 原生安装 Ollama，本仓库保留给隔离测试使用。
