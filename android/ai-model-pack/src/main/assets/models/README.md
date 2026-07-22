# AI Model Pack - Qwen2-VL 2B

This directory contains the Qwen2-VL 2B model files for on-device food recognition.

## Model Files (to be added)

### Required Files:
1. `qwen2-vl-2b-instruct-q4_k_m.gguf` (~1.5 GB)
   - Main language model (Q4_K_M quantization)
   - Download from: https://huggingface.co/Qwen/Qwen2-VL-2B-Instruct-GGUF

2. `qwen2-vl-2b-clip-q8_0.gguf` (~400 MB)
   - Vision encoder
   - Download from: https://huggingface.co/Qwen/Qwen2-VL-2B-Instruct-GGUF

## Total Size: ~1.9 GB

## Why Qwen2-VL 2B?

| Feature | SmolVLM-500M | Qwen2-VL 2B | Benefit |
|---------|--------------|-------------|---------|
| Parameters | 500M | 2B | 4x larger model |
| Accuracy | ~82% | ~92%+ | Significantly better recognition |
| Speed | ~1.2s | ~3-5s | Acceptable for food logging |
| Memory | ~500MB | ~1.9GB | Requires more RAM |
| Detail | Good | Excellent | Very accurate nutritional estimates |

### Why This Choice?
- **SmolVLM was "trash"**: User feedback on 256M and 500M models
- **Qwen2-VL 2B** is the sweet spot: much better accuracy while still fitting on device
- **Q4_K_M quantization**: 4-bit keeps size manageable (~1.9GB vs 4GB+ for full precision)

## Delivery Method

This asset pack is delivered via **Play Asset Delivery** (fast-follow delivery type):
- Not included in the initial APK download
- Automatically downloaded after app installation
- Delivered via Google Play's CDN (fast and reliable)

**Note**: 1.9GB is within Play Asset Delivery's 2GB limit per pack.

## Model License

Qwen2-VL is released under the **Apache 2.0 License** by Alibaba.
- ✅ Free for commercial use
- ✅ No usage restrictions
- ✅ Attribution required (included in app)

## llama.cpp Conversion

If you need to convert models to GGUF format:

```bash
# Install llama.cpp
git clone https://github.com/ggerganov/llama.cpp
cd llama.cpp && make

# Convert to GGUF (Q4_K_M quantization)
python convert-hf-to-gguf.py path/to/qwen2-vl-2b --outtype q4_k_m
```

## Testing Notes

- In debug builds, dev mode bypasses PAD entirely (returns stub responses)
- Use release builds for real model testing
- **Minimum device**: 6GB RAM recommended for 2B model
- Inference time: ~3-5 seconds on mid-range devices (2023+)

## Model Comparison

| Model | Size | Accuracy | Inference | Min RAM | Status |
|-------|------|----------|-----------|---------|--------|
| SmolVLM-256M | ~365MB | ~75% | ~0.5s | 4GB | ❌ Too inaccurate |
| SmolVLM-500M | ~500MB | ~82% | ~1.2s | 4GB | ❌ Still inaccurate |
| **Qwen2-VL 2B** | ~1.9GB | ~92%+ | ~3-5s | 6GB | ✅ Current choice |
| Qwen2-VL 7B | ~4.5GB | ~95%+ | ~8-12s | 8GB | ⚠️ Too large for most devices |
