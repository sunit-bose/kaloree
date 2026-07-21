# SmolVLM Model Files

This directory should contain the SmolVLM-256M model files for on-device food analysis.

## Required Files

Download from HuggingFace: https://huggingface.co/HuggingFaceTB/SmolVLM-256M-Instruct

1. **smolvlm-256m-instruct-q8_0.gguf** (~320 MB)
   - Main language model file
   - Q8_0 quantization for best quality

2. **smolvlm-256m-clip-q8_0.gguf** (~45 MB)
   - CLIP vision encoder
   - Required for image understanding

## Download Instructions

```bash
# Option 1: Using huggingface-cli
pip install huggingface_hub
huggingface-cli download HuggingFaceTB/SmolVLM-256M-Instruct-GGUF \
  smolvlm-256m-instruct-q8_0.gguf \
  --local-dir ./

# Option 2: Manual download
# Visit: https://huggingface.co/HuggingFaceTB/SmolVLM-256M-Instruct-GGUF/tree/main
# Download the Q8_0 quantized files
```

## File Placement

Place both files directly in this directory:
```
android/app/src/main/assets/models/
├── README.md (this file)
├── smolvlm-256m-instruct-q8_0.gguf
└── smolvlm-256m-clip-q8_0.gguf
```

## Expected APK Size

With bundled models:
- Base APK: ~35 MB
- + Model files: ~365 MB
- **Total: ~400 MB**

## Alternative: Play Asset Delivery

For apps exceeding 150 MB, consider Play Asset Delivery:
- See `plans/ON_DEVICE_AI_POC_PLAN.md` for implementation details

## Notes

- Models are loaded at first camera use (~2-5 seconds)
- Requires ~365 MB RAM for inference
- Works completely offline after initial load
